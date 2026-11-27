//
//  ExploreModelIntentTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-012 on 2026/11/26.
//

import XCTest
import Combine
@testable import iov

/// TC-012-2 / TC-012-7 / TC-012-8：频道、刷新、代次隔离、独立文章流与发布版本恢复。
final class ExploreModelIntentTests: XCTestCase {

    private var model: CommunityModel!
    private var service: FakeExploreService!
    private var intent: CommunityIntent!
    private var routes: [CommunityRouter.ScreenType] = []
    private var routeCancellable: AnyCancellable?

    override func setUp() {
        super.setUp()
        model = CommunityModel()
        service = FakeExploreService()
        intent = CommunityIntent(model: model, service: service)
        routes = []
        routeCancellable = model.routerSubject.screen.sink { [weak self] screen in
            self?.routes.append(screen)
        }
    }

    override func tearDown() {
        routeCancellable?.cancel()
        routeCancellable = nil
        intent = nil
        service = nil
        model = nil
        super.tearDown()
    }

    // MARK: - 初始加载

    func testInitialLoadSelectsFirstChannelAndRequestsPageWithoutETag() {
        service.enqueueChannels(.success([makeChannelState("a"), makeChannelState("b")]))
        service.enqueuePage(.success(.loaded(page: makePageState(channelCode: "a",
                                                                 components: [feedComponent()]),
                                             etag: "e1")))

        intent.viewOnAppear()

        XCTAssertEqual(model.selectedChannelCode, "a")
        XCTAssertEqual(model.contentState, .content)
        XCTAssertEqual(model.page?.channelCode, "a")
        XCTAssertEqual(service.pageCalls, [.init(channelCode: "a", pageSize: 10, ifNoneMatch: nil)])
    }

    func testEmptyChannelsShowEmptyAndNeverRequestPage() {
        service.enqueueChannels(.success([]))

        intent.viewOnAppear()

        XCTAssertEqual(model.contentState, .empty)
        XCTAssertNil(model.page)
        XCTAssertTrue(service.pageCalls.isEmpty)
    }

    func testInitialPageFailureShowsRetryableErrorState() {
        service.enqueueChannels(.success([makeChannelState("a")]))
        service.enqueuePage(.failure(.serviceUnavailable))

        intent.viewOnAppear()

        XCTAssertEqual(model.contentState, .error(.serviceUnavailable))
        XCTAssertNil(model.page)
        XCTAssertNil(model.presentationError)
    }

    func testNoContentBusinessCodeShowsEmpty() {
        service.enqueueChannels(.success([makeChannelState("a")]))
        service.enqueuePage(.failure(.noContent))

        intent.viewOnAppear()

        XCTAssertEqual(model.contentState, .empty)
        XCTAssertNil(model.page)
    }

    // MARK: - 刷新

    func testRefreshFailureKeepsContentAndReportsNonBlockingError() {
        loadInitialPage(etag: "e1")

        service.enqueueChannels(.success([makeChannelState("a")]))
        service.enqueuePage(.failure(.network))
        intent.refresh()

        XCTAssertEqual(model.contentState, .content)
        XCTAssertEqual(model.page?.releaseId, "release-1")
        XCTAssertEqual(model.presentationError, .refresh(.network))
        XCTAssertFalse(model.isRefreshing)
    }

    func testConditionalRefreshSendsETagAndKeepsContentOn304() {
        loadInitialPage(etag: "e1")

        service.enqueueChannels(.success([makeChannelState("a")]))
        service.enqueuePage(.success(.notModified))
        intent.refresh()

        XCTAssertEqual(service.pageCalls.count, 2)
        XCTAssertEqual(service.pageCalls[1].ifNoneMatch, "e1")
        XCTAssertEqual(model.page?.releaseId, "release-1")
        XCTAssertEqual(model.contentState, .content)
        XCTAssertFalse(model.isRefreshing)
    }

    func testRefreshFallsBackToFirstChannelWhenSelectionDisappears() {
        loadInitialPage(channelCode: "b", etag: "e1")

        service.enqueueChannels(.success([makeChannelState("a")]))
        service.enqueuePage(.success(.loaded(page: makePageState(channelCode: "a",
                                                                 components: [feedComponent()]),
                                             etag: "e2")))
        intent.refresh()

        XCTAssertEqual(model.selectedChannelCode, "a")
        XCTAssertEqual(service.pageCalls.last, .init(channelCode: "a", pageSize: 10, ifNoneMatch: nil))
    }

    func testDuplicateViewOnAppearIsBlockedWhileChannelsRequestInFlight() {
        service.holdChannels = true
        intent.viewOnAppear()
        intent.viewOnAppear()
        XCTAssertEqual(service.channelCallCount, 1)
    }

    func testDuplicateRefreshIsBlockedWhilePageRequestInFlight() {
        service.holdPage = true
        service.enqueueChannels(.success([makeChannelState("a")]))
        intent.viewOnAppear()
        XCTAssertEqual(service.channelCallCount, 1)
        XCTAssertEqual(service.pageCalls.count, 1)

        intent.refresh()

        XCTAssertEqual(service.channelCallCount, 1, "页面请求进行中不得重复刷新")
        XCTAssertEqual(service.pageCalls.count, 1)
    }

    // MARK: - 代次隔离

    func testStalePageResponseDoesNotOverrideNewlySelectedChannel() {
        service.holdPage = true
        service.enqueueChannels(.success([makeChannelState("a"), makeChannelState("b")]))
        intent.viewOnAppear()
        XCTAssertEqual(service.pageCalls.count, 1)

        intent.selectChannel(code: "b")
        XCTAssertEqual(model.selectedChannelCode, "b")
        XCTAssertNil(model.page)
        XCTAssertEqual(model.contentState, .loading)
        XCTAssertEqual(service.pageCalls.count, 2)

        service.completeHeldPage(.success(.loaded(page: makePageState(channelCode: "a",
                                                                      components: [feedComponent()]),
                                                  etag: "ea")))
        XCTAssertNil(model.page, "旧频道响应不得覆盖当前状态")
        XCTAssertEqual(model.contentState, .loading)

        service.completeHeldPage(.success(.loaded(page: makePageState(channelCode: "b",
                                                                      components: [feedComponent()]),
                                                  etag: "eb")))
        XCTAssertEqual(model.page?.channelCode, "b")
        XCTAssertEqual(model.contentState, .content)
    }

    // MARK: - 文章流分页

    func testLoadMoreSendsExactContextAndAppendsWithoutDuplicates() {
        loadInitialPage(components: [feedComponent(items: [makeArticleCard("a1")],
                                                   hasMore: true,
                                                   nextCursor: "c1")],
                        etag: "e1")

        service.enqueueFeed(.success(ExploreFeedPageViewState(
            releaseId: "release-1",
            componentId: "feed-1",
            items: [makeArticleCard("a1"), makeArticleCard("a2")],
            hasMore: true,
            nextCursor: "c2"
        )))
        intent.loadMore(componentId: "feed-1")

        XCTAssertEqual(service.feedCalls, [
            .init(channelCode: "a",
                  componentId: "feed-1",
                  releaseId: "release-1",
                  cursor: "c1",
                  pageSize: 10)
        ])
        let feed = model.page?.feed(componentId: "feed-1")
        XCTAssertEqual(feed?.items.map(\.id), ["a1", "a2"])
        XCTAssertEqual(feed?.hasMore, true)
        XCTAssertEqual(feed?.nextCursor, "c2")
        XCTAssertFalse(model.loadingMoreComponentIds.contains("feed-1"))
    }

    func testLoadMoreIsBlockedWhileSameComponentInFlight() {
        loadInitialPage(components: [feedComponent(items: [makeArticleCard("a1")],
                                                   hasMore: true,
                                                   nextCursor: "c1")],
                        etag: "e1")
        service.holdFeed = true

        intent.loadMore(componentId: "feed-1")
        intent.loadMore(componentId: "feed-1")

        XCTAssertEqual(service.feedCalls.count, 1)
        XCTAssertTrue(model.loadingMoreComponentIds.contains("feed-1"))
    }

    func testFeedFailureKeepsLoadedItemsAndReportsNonBlockingError() {
        loadInitialPage(components: [feedComponent(items: [makeArticleCard("a1")],
                                                   hasMore: true,
                                                   nextCursor: "c1")],
                        etag: "e1")

        service.enqueueFeed(.failure(.invalidArgument))
        intent.loadMore(componentId: "feed-1")

        XCTAssertEqual(model.page?.feed(componentId: "feed-1")?.items.map(\.id), ["a1"])
        XCTAssertEqual(model.presentationError, .feed(componentId: "feed-1", failure: .invalidArgument))
        XCTAssertFalse(model.loadingMoreComponentIds.contains("feed-1"))
    }

    func testReleaseChangedDiscardsOldPaginationAndReloadsCurrentPage() {
        loadInitialPage(components: [feedComponent(items: [makeArticleCard("a1")],
                                                   hasMore: true,
                                                   nextCursor: "c1")],
                        etag: "e1")

        service.enqueuePage(.success(.loaded(page: makePageState(channelCode: "a",
                                                                 releaseId: "release-2",
                                                                 components: [feedComponent(items: [makeArticleCard("a9")])]),
                                             etag: "e2")))
        service.enqueueFeed(.failure(.releaseChanged))
        intent.loadMore(componentId: "feed-1")

        XCTAssertEqual(service.feedCalls.count, 1, "不得重试旧游标")
        XCTAssertEqual(service.pageCalls.count, 2)
        XCTAssertNil(service.pageCalls[1].ifNoneMatch, "发布版本变化后不得携带旧 ETag")
        XCTAssertEqual(model.page?.releaseId, "release-2")
        XCTAssertEqual(model.page?.feed(componentId: "feed-1")?.items.map(\.id), ["a9"])
    }

    func testRetryPresentationErrorReissuesFeedRequest() {
        loadInitialPage(components: [feedComponent(items: [makeArticleCard("a1")],
                                                   hasMore: true,
                                                   nextCursor: "c1")],
                        etag: "e1")
        service.enqueueFeed(.failure(.serviceUnavailable))
        intent.loadMore(componentId: "feed-1")
        XCTAssertNotNil(model.presentationError)

        service.enqueueFeed(.success(ExploreFeedPageViewState(
            releaseId: "release-1",
            componentId: "feed-1",
            items: [makeArticleCard("a2")],
            hasMore: false,
            nextCursor: nil
        )))
        intent.retryPresentationError()

        XCTAssertEqual(service.feedCalls.count, 2)
        XCTAssertNil(model.presentationError)
        XCTAssertEqual(model.page?.feed(componentId: "feed-1")?.items.map(\.id), ["a1", "a2"])
    }

    // MARK: - 目标跳转

    func testTapTypedTargetsRoutesWithoutGlobalState() {
        loadInitialPage(etag: "e1")

        intent.onTapItem(target: .article(ArticleRevisionRef(articleId: "a1", revisionId: "r1")))
        guard case let .article(articleId, revisionId) = routes.last else {
            return XCTFail("expected article route")
        }
        XCTAssertEqual(articleId, "a1")
        XCTAssertEqual(revisionId, "r1")

        intent.onTapItem(target: .topic(TopicRevisionRef(topicId: "t1", revisionId: "tr1")))
        guard case let .topic(topicId, topicRevisionId) = routes.last else {
            return XCTFail("expected topic route")
        }
        XCTAssertEqual(topicId, "t1")
        XCTAssertEqual(topicRevisionId, "tr1")

        let webURL = URL(string: "https://example.com/a")!
        intent.onTapItem(target: .h5(webURL))
        guard case let .web(url) = routes.last else {
            return XCTFail("expected web route")
        }
        XCTAssertEqual(url, webURL)
    }

    func testInsecureH5AndUnregisteredNativeShowInvalidTargetError() {
        loadInitialPage(etag: "e1")

        intent.onTapItem(target: .h5(URL(string: "http://example.com/a")!))
        XCTAssertEqual(model.presentationError, .target(.invalidTarget))
        XCTAssertTrue(routes.isEmpty)

        intent.onTapItem(target: .native(routeCode: "order.detail", params: ["orderNo": "O1"]))
        XCTAssertEqual(model.presentationError, .target(.invalidTarget))
        XCTAssertTrue(routes.isEmpty)
    }

    func testRegisteredNativeRouteRoutesThroughExistingCommand() {
        let registry = ExploreNativeRouteRegistry(registrations: [
            ExploreNativeRouteRegistration(routeCode: "order.detail",
                                           allowedParamKeys: ["orderNo"]) { params in
                guard let orderNo = params["orderNo"], !orderNo.isEmpty else { return nil }
                return .orderDetail(orderNo: orderNo)
            }
        ])
        let customModel = CommunityModel()
        var customRoutes: [CommunityRouter.ScreenType] = []
        let cancellable = customModel.routerSubject.screen.sink { customRoutes.append($0) }
        let customIntent = CommunityIntent(model: customModel,
                                           service: service,
                                           resolver: ExploreTargetResolver(nativeRegistry: registry))

        customIntent.onTapItem(target: .native(routeCode: "order.detail", params: ["orderNo": "O1"]))

        guard case let .nativeOrderDetail(orderNo) = customRoutes.last else {
            return XCTFail("expected native order detail route")
        }
        XCTAssertEqual(orderNo, "O1")
        withExtendedLifetime(cancellable) {}
    }

    // MARK: - Helpers

    private func feedComponent(items: [ExploreArticleCardViewState] = [makeArticleCard("a1")],
                               hasMore: Bool = false,
                               nextCursor: String? = nil) -> ExploreComponentViewState {
        return makeFeedComponentState("feed-1",
                                      items: items,
                                      hasMore: hasMore,
                                      nextCursor: nextCursor)
    }

    private func loadInitialPage(channelCode: String = "a",
                                 releaseId: String = "release-1",
                                 components: [ExploreComponentViewState]? = nil,
                                 etag: String?) {
        service.enqueueChannels(.success([makeChannelState(channelCode)]))
        service.enqueuePage(.success(.loaded(page: makePageState(channelCode: channelCode,
                                                                 releaseId: releaseId,
                                                                 components: components ?? [feedComponent()]),
                                             etag: etag)))
        intent.viewOnAppear()
        XCTAssertEqual(model.contentState, .content)
    }
}
