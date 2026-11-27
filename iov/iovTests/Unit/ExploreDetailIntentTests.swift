//
//  ExploreDetailIntentTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-012 on 2026/11/26.
//

import XCTest
import Combine
@testable import iov

/// TC-012-6：文章修订详情、UGC 原生委托、专题修订与游标隔离。
final class ExploreDetailIntentTests: XCTestCase {

    func testOfficialArticleLoadsRevisionDetail() {
        let model = CommunityArticleModel()
        let service = FakeExploreService()
        let detail = makeDetail()
        service.enqueueArticle(.success(detail))
        let intent = CommunityArticleIntent(model: model,
                                            articleId: "a1",
                                            revisionId: "r1",
                                            service: service)

        intent.viewOnAppear()

        XCTAssertEqual(service.articleCalls.count, 1)
        XCTAssertEqual(service.articleCalls[0].articleId, "a1")
        XCTAssertEqual(service.articleCalls[0].revisionId, "r1")
        guard case let .content(loaded) = model.contentState else {
            return XCTFail("expected content")
        }
        XCTAssertEqual(loaded.articleId, "a1")
        XCTAssertEqual(loaded.body, .officialHTML("<p>正文</p>"))
    }

    func testUGCReferenceRoutesThroughRegisteredNativeCommand() {
        let registry = ExploreNativeRouteRegistry(registrations: [
            ExploreNativeRouteRegistration(routeCode: "community.article",
                                           allowedParamKeys: []) { _ in
                .orderDetail(orderNo: "UGC")
            }
        ])
        let model = CommunityArticleModel()
        let service = FakeExploreService()
        service.enqueueArticle(.success(makeDetail(body: .ugcReference(sourceContentId: "c1",
                                                                      nativeRouteCode: "community.article"))))
        let intent = CommunityArticleIntent(model: model,
                                            articleId: "a1",
                                            revisionId: "r1",
                                            service: service,
                                            resolver: ExploreTargetResolver(nativeRegistry: registry))
        var routes: [CommunityArticleRouter.ScreenType] = []
        let cancellable = model.routerSubject.screen.sink { routes.append($0) }

        intent.viewOnAppear()

        guard case let .nativeOrderDetail(orderNo) = routes.last else {
            return XCTFail("expected native route")
        }
        XCTAssertEqual(orderNo, "UGC")
        withExtendedLifetime(cancellable) {}
    }

    func testArticleViewReappearDoesNotReloadOrReRoute() {
        let registry = ExploreNativeRouteRegistry(registrations: [
            ExploreNativeRouteRegistration(routeCode: "community.article",
                                           allowedParamKeys: []) { _ in
                .orderDetail(orderNo: "UGC")
            }
        ])
        let model = CommunityArticleModel()
        let service = FakeExploreService()
        service.enqueueArticle(.success(makeDetail(body: .ugcReference(sourceContentId: "c1",
                                                                      nativeRouteCode: "community.article"))))
        let intent = CommunityArticleIntent(model: model,
                                            articleId: "a1",
                                            revisionId: "r1",
                                            service: service,
                                            resolver: ExploreTargetResolver(nativeRegistry: registry))
        var routes: [CommunityArticleRouter.ScreenType] = []
        let cancellable = model.routerSubject.screen.sink { routes.append($0) }

        intent.viewOnAppear()
        intent.viewOnAppear()

        XCTAssertEqual(service.articleCalls.count, 1)
        XCTAssertEqual(routes.count, 1)
        withExtendedLifetime(cancellable) {}
    }

    func testUGCReferenceWithoutMappingShowsUnavailable() {
        let model = CommunityArticleModel()
        let service = FakeExploreService()
        service.enqueueArticle(.success(makeDetail(body: .ugcReference(sourceContentId: "c1",
                                                                      nativeRouteCode: "community.article"))))
        let intent = CommunityArticleIntent(model: model,
                                            articleId: "a1",
                                            revisionId: "r1",
                                            service: service)
        var routes: [CommunityArticleRouter.ScreenType] = []
        let cancellable = model.routerSubject.screen.sink { routes.append($0) }

        intent.viewOnAppear()

        XCTAssertEqual(model.contentState, .unavailable)
        XCTAssertTrue(routes.isEmpty)
        withExtendedLifetime(cancellable) {}
    }

    func testArticleUnavailableFailureAndMissingIdentifiersDoNotRequest() {
        let model = CommunityArticleModel()
        let service = FakeExploreService()
        service.enqueueArticle(.failure(.contentUnavailable))
        let intent = CommunityArticleIntent(model: model,
                                            articleId: "a1",
                                            revisionId: "r1",
                                            service: service)
        intent.viewOnAppear()
        XCTAssertEqual(model.contentState, .unavailable)

        let emptyModel = CommunityArticleModel()
        let emptyService = FakeExploreService()
        let emptyIntent = CommunityArticleIntent(model: emptyModel,
                                                 articleId: "",
                                                 revisionId: "",
                                                 service: emptyService)
        emptyIntent.viewOnAppear()
        XCTAssertEqual(emptyModel.contentState, .unavailable)
        XCTAssertTrue(emptyService.articleCalls.isEmpty)
    }

    func testTopicFirstPageAndIndependentCursorPaging() {
        let model = CommunityTopicModel()
        let service = FakeExploreService()
        let first = makeTopic(items: [makeArticleCard("a1")],
                              hasMore: true,
                              nextCursor: "topic-c1")
        service.enqueueTopic(.success(first))
        let intent = CommunityTopicIntent(model: model,
                                          topicId: "t1",
                                          revisionId: "tr1",
                                          service: service)

        intent.viewOnAppear()

        XCTAssertEqual(service.topicCalls, [.init(topicId: "t1",
                                                  revisionId: "tr1",
                                                  cursor: nil,
                                                  pageSize: 10)])
        XCTAssertEqual(model.contentState, .content)
        XCTAssertEqual(model.topic?.items.map(\.id), ["a1"])

        service.enqueueTopic(.success(makeTopic(items: [makeArticleCard("a1"), makeArticleCard("a2")],
                                                hasMore: false,
                                                nextCursor: nil)))
        intent.loadMore()

        XCTAssertEqual(service.topicCalls.last, .init(topicId: "t1",
                                                      revisionId: "tr1",
                                                      cursor: "topic-c1",
                                                      pageSize: 10))
        XCTAssertEqual(model.topic?.items.map(\.id), ["a1", "a2"])
        XCTAssertEqual(model.topic?.hasMore, false)
        XCTAssertNil(model.topic?.nextCursor)

        intent.loadMore()
        XCTAssertEqual(service.topicCalls.count, 2, "hasMore=false 后不得继续请求")
    }

    func testTopicPagingFailureKeepsLoadedItemsAndReportsError() {
        let model = CommunityTopicModel()
        let service = FakeExploreService()
        service.enqueueTopic(.success(makeTopic(items: [makeArticleCard("a1")],
                                                hasMore: true,
                                                nextCursor: "c1")))
        let intent = CommunityTopicIntent(model: model,
                                          topicId: "t1",
                                          revisionId: "tr1",
                                          service: service)
        intent.viewOnAppear()

        service.enqueueTopic(.failure(.invalidArgument))
        intent.loadMore()

        XCTAssertEqual(model.topic?.items.map(\.id), ["a1"])
        XCTAssertEqual(model.presentationError, .invalidArgument)
        XCTAssertFalse(model.isLoadingMore)
    }

    func testTopicItemTapPassesItsOwnArticleRevision() {
        let model = CommunityTopicModel()
        let service = FakeExploreService()
        service.enqueueTopic(.success(makeTopic(items: [makeArticleCard("a1")],
                                                hasMore: false,
                                                nextCursor: nil)))
        let intent = CommunityTopicIntent(model: model,
                                          topicId: "t1",
                                          revisionId: "tr1",
                                          service: service)
        var routes: [CommunityTopicRouter.ScreenType] = []
        let cancellable = model.routerSubject.screen.sink { routes.append($0) }
        intent.viewOnAppear()

        intent.onTapItem(target: .article(ArticleRevisionRef(articleId: "child-a",
                                                             revisionId: "child-r")))

        guard case let .article(articleId, revisionId) = routes.last else {
            return XCTFail("expected article route")
        }
        XCTAssertEqual(articleId, "child-a")
        XCTAssertEqual(revisionId, "child-r")
        withExtendedLifetime(cancellable) {}
    }

    // MARK: - 专题详情图集（CR-013）

    func testTopicPagingKeepsFirstPageDetailMedia() {
        let model = CommunityTopicModel()
        let service = FakeExploreService()
        service.enqueueTopic(.success(makeTopic(items: [makeArticleCard("a1")],
                                                hasMore: true,
                                                nextCursor: "c1",
                                                images: [image("detail-1"), image("detail-2")],
                                                imageCount: 2,
                                                imageLayout: .twoColumns)))
        let intent = CommunityTopicIntent(model: model,
                                          topicId: "t1",
                                          revisionId: "tr1",
                                          service: service)
        intent.viewOnAppear()

        service.enqueueTopic(.success(makeTopic(items: [makeArticleCard("a1"), makeArticleCard("a2")],
                                                hasMore: false,
                                                nextCursor: nil,
                                                images: [],
                                                imageCount: 0,
                                                imageLayout: nil)))
        intent.loadMore()

        XCTAssertEqual(model.topic?.items.map(\.id), ["a1", "a2"])
        XCTAssertEqual(model.topic?.images.map(\.url?.absoluteString),
                       ["https://example.com/detail-1.png", "https://example.com/detail-2.png"])
        XCTAssertEqual(model.topic?.imageCount, 2)
        XCTAssertEqual(model.topic?.imageLayout, .twoColumns)
        XCTAssertNil(model.topic?.nextCursor)
    }

    func testTopicPagingIgnoresOtherRevisionMediaAndArticles() {
        let model = CommunityTopicModel()
        let service = FakeExploreService()
        service.enqueueTopic(.success(makeTopic(items: [makeArticleCard("a1")],
                                                hasMore: true,
                                                nextCursor: "c1",
                                                images: [image("detail-1")],
                                                imageCount: 1,
                                                imageLayout: .single)))
        let intent = CommunityTopicIntent(model: model,
                                          topicId: "t1",
                                          revisionId: "tr1",
                                          service: service)
        intent.viewOnAppear()

        service.enqueueTopic(.success(makeTopic(topicId: "t1",
                                                revisionId: "tr2",
                                                items: [makeArticleCard("other")],
                                                hasMore: false,
                                                nextCursor: nil,
                                                images: [image("other-1"), image("other-2"), image("other-3")],
                                                imageCount: 3,
                                                imageLayout: .oneLargeTwoSmall)))
        intent.loadMore()

        XCTAssertEqual(model.topic?.items.map(\.id), ["a1"])
        XCTAssertEqual(model.topic?.images.map(\.url?.absoluteString),
                       ["https://example.com/detail-1.png"])
        XCTAssertEqual(model.topic?.imageCount, 1)
        XCTAssertEqual(model.topic?.imageLayout, .single)
        XCTAssertEqual(model.topic?.hasMore, true, "其他修订的响应不得覆盖当前分页状态")
    }

    func testTopicRefreshReplacesDetailMedia() {
        let model = CommunityTopicModel()
        let service = FakeExploreService()
        service.enqueueTopic(.success(makeTopic(items: [makeArticleCard("a1")],
                                                hasMore: false,
                                                nextCursor: nil,
                                                images: [image("detail-1")],
                                                imageCount: 1,
                                                imageLayout: .single)))
        let intent = CommunityTopicIntent(model: model,
                                          topicId: "t1",
                                          revisionId: "tr1",
                                          service: service)
        intent.viewOnAppear()

        service.enqueueTopic(.success(makeTopic(items: [makeArticleCard("a9")],
                                                hasMore: false,
                                                nextCursor: nil,
                                                images: [],
                                                imageCount: 0,
                                                imageLayout: nil)))
        intent.retry()

        XCTAssertEqual(model.topic?.items.map(\.id), ["a9"])
        XCTAssertEqual(model.topic?.images.count, 0)
        XCTAssertEqual(model.topic?.imageCount, 0)
        XCTAssertNil(model.topic?.imageLayout)
    }

    // MARK: - Helpers

    private func makeDetail(body: ExploreArticleBody = .officialHTML("<p>正文</p>")) -> ExploreArticleDetailViewState {
        return ExploreArticleDetailViewState(
            articleId: "a1",
            revisionId: "r1",
            title: "标题",
            summary: "摘要",
            cover: nil,
            images: [],
            imageCount: 0,
            imageLayout: nil,
            authorName: "作者",
            authorAvatarURL: nil,
            displayAt: nil,
            body: body
        )
    }

    private func makeTopic(topicId: String = "t1",
                           revisionId: String = "tr1",
                           items: [ExploreArticleCardViewState],
                           hasMore: Bool,
                           nextCursor: String?,
                           images: [ExploreImageViewState] = [],
                           imageCount: Int = 0,
                           imageLayout: ExploreImageLayout? = nil) -> ExploreTopicDetailViewState {
        return ExploreTopicDetailViewState(
            topicId: topicId,
            revisionId: revisionId,
            name: "专题",
            summary: nil,
            cover: nil,
            images: images,
            imageCount: imageCount,
            imageLayout: imageLayout,
            items: items,
            hasMore: hasMore,
            nextCursor: nextCursor
        )
    }

    private func image(_ name: String) -> ExploreImageViewState {
        return ExploreImageViewState(url: URL(string: "https://example.com/\(name).png"),
                                     width: 1600,
                                     height: 900,
                                     mime: "image/png",
                                     size: 1024)
    }
}
