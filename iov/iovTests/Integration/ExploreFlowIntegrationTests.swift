//
//  ExploreFlowIntegrationTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-012 on 2026/11/26.
//

import XCTest
import Alamofire
@testable import iov

/// TC-012-11（本地替身部分）：共享网络层 → RealExploreService → Intent/Model 的完整链路。
/// 真实 CMS → SGW → App 验收在环境就绪前仍为未执行。
final class ExploreFlowIntegrationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        AuthEnvironment.shared.sessionRepository.clearSession()
        StubURLProtocol.reset()
        TspManager.networkManagerProvider = { makeStubbedNetworkManager() }
    }

    override func tearDown() {
        TspManager.networkManagerProvider = { NetworkManager.shared }
        StubURLProtocol.reset()
        super.tearDown()
    }

    func testChannelRefresh304AndCursorPagingFlow() {
        let pageCount = LockedCounter()
        StubURLProtocol.handler = { request in
            let path = request.url?.path ?? ""
            if path.hasSuffix("/channels") {
                return .json(exploreEnvelope(data: [exploreChannel("recommend", "推荐")]))
            }
            if path.hasSuffix("/pages/current") {
                let index = pageCount.next()
                if index == 1 {
                    return .json(exploreEnvelope(data: explorePage(
                        channelCode: "recommend",
                        components: [exploreFeedComponent("feed-1",
                                                          items: [exploreArticleItem("a1")],
                                                          hasMore: true,
                                                          nextCursor: "cursor-1")]
                    )), headers: ["ETag": "\"release-1\"", "Content-Type": "application/json"])
                }
                return .empty(status: 304, headers: ["ETag": "\"release-1\""])
            }
            if path.hasSuffix("/article-feed") {
                return .json(exploreEnvelope(data: exploreFeedPage(items: [exploreArticleItem("a2")],
                                                                   hasMore: false)))
            }
            return .json(Data(), status: 404)
        }

        let model = CommunityModel()
        let intent = CommunityIntent(model: model)
        intent.viewOnAppear()
        waitUntil(timeout: 5, description: "initial content") {
            if case .content = model.contentState { return true }
            return false
        }
        XCTAssertEqual(model.page?.feed(componentId: "feed-1")?.items.map(\.id), ["a1"])

        intent.refresh()
        waitUntil(timeout: 5, description: "304 refresh") {
            return pageCount.value == 2 && !model.isRefreshing
        }
        XCTAssertEqual(model.page?.feed(componentId: "feed-1")?.items.map(\.id), ["a1"], "304 必须保留内容")

        let pageRequests = StubURLProtocol.requests.filter { $0.url?.path.hasSuffix("/pages/current") == true }
        XCTAssertEqual(pageRequests.count, 2)
        XCTAssertNil(pageRequests[0].value(forHTTPHeaderField: "If-None-Match"))
        XCTAssertEqual(pageRequests[1].value(forHTTPHeaderField: "If-None-Match"), "\"release-1\"")

        intent.loadMore(componentId: "feed-1")
        waitUntil(timeout: 5, description: "feed appended") {
            model.page?.feed(componentId: "feed-1")?.items.count == 2
        }
        XCTAssertEqual(model.page?.feed(componentId: "feed-1")?.items.map(\.id), ["a1", "a2"])
        let feedRequest = StubURLProtocol.requests.first { $0.url?.path.hasSuffix("/article-feed") == true }
        let components = URLComponents(url: feedRequest!.url!, resolvingAgainstBaseURL: false)
        let query = Dictionary(uniqueKeysWithValues: (components?.queryItems ?? []).map { ($0.name, $0.value ?? "") })
        XCTAssertEqual(query["cursor"], "cursor-1")
        XCTAssertEqual(query["componentId"], "feed-1")
        XCTAssertEqual(query["releaseId"], "release-1")
    }

    func testReleaseChangedReloadsPageAndDropsOldCursor() {
        let pageCount = LockedCounter()
        StubURLProtocol.handler = { request in
            let path = request.url?.path ?? ""
            if path.hasSuffix("/channels") {
                return .json(exploreEnvelope(data: [exploreChannel("recommend", "推荐")]))
            }
            if path.hasSuffix("/pages/current") {
                if pageCount.next() == 1 {
                    return .json(exploreEnvelope(data: explorePage(
                        channelCode: "recommend",
                        components: [exploreFeedComponent("feed-1",
                                                          items: [exploreArticleItem("a1")],
                                                          hasMore: true,
                                                          nextCursor: "cursor-1")]
                    )), headers: ["ETag": "\"release-1\"", "Content-Type": "application/json"])
                }
                return .json(exploreEnvelope(data: explorePage(
                    channelCode: "recommend",
                    releaseId: "release-2",
                    components: [exploreFeedComponent("feed-1",
                                                      items: [exploreArticleItem("a9")],
                                                      hasMore: false)]
                )), headers: ["ETag": "\"release-2\"", "Content-Type": "application/json"])
            }
            if path.hasSuffix("/article-feed") {
                return .json(exploreEnvelope(data: nil, code: "105017"))
            }
            return .json(Data(), status: 404)
        }

        let model = CommunityModel()
        let intent = CommunityIntent(model: model)
        intent.viewOnAppear()
        waitUntil(timeout: 5, description: "initial") {
            if case .content = model.contentState { return true }
            return false
        }

        intent.loadMore(componentId: "feed-1")
        waitUntil(timeout: 5, description: "reload after 105017") {
            model.page?.releaseId == "release-2" && !model.isRefreshing
        }

        XCTAssertEqual(model.page?.feed(componentId: "feed-1")?.items.map(\.id), ["a9"])
        let pageRequests = StubURLProtocol.requests.filter { $0.url?.path.hasSuffix("/pages/current") == true }
        XCTAssertEqual(pageRequests.count, 2)
        XCTAssertNil(pageRequests[1].value(forHTTPHeaderField: "If-None-Match"))
        let feedRequests = StubURLProtocol.requests.filter { $0.url?.path.hasSuffix("/article-feed") == true }
        XCTAssertEqual(feedRequests.count, 1, "不得重试旧游标")
    }

    func testArticleAndTopicDetailFlow() {
        StubURLProtocol.handler = { request in
            let path = request.url?.path ?? ""
            if path.contains("/articles/a1/revisions/r1") {
                return .json(exploreEnvelope(data: exploreArticleDetail(articleId: "a1",
                                                                        revisionId: "r1",
                                                                        body: "<p>正文</p>")))
            }
            if path.contains("/topics/t1/revisions/rev-t1") {
                let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
                let cursor = components?.queryItems?.first(where: { $0.name == "cursor" })?.value
                if cursor == nil {
                    return .json(exploreEnvelope(data: exploreTopicDetail(cover: exploreImage("https://example.com/card.png"),
                                                                           images: [exploreImage("https://example.com/detail-1.png"),
                                                                                    exploreImage("https://example.com/detail-2.png")],
                                                                           imageCount: 2,
                                                                           imageLayout: "TWO_COLUMNS",
                                                                           items: [exploreArticleItem("a1")],
                                                                           hasMore: true,
                                                                           nextCursor: "topic-c1")))
                }
                return .json(exploreEnvelope(data: exploreTopicDetail(items: [exploreArticleItem("a2")],
                                                                       hasMore: false)))
            }
            return .json(Data(), status: 404)
        }

        let articleModel = CommunityArticleModel()
        let articleIntent = CommunityArticleIntent(model: articleModel,
                                                   articleId: "a1",
                                                   revisionId: "r1")
        articleIntent.viewOnAppear()
        waitUntil(timeout: 5, description: "article") {
            if case .content = articleModel.contentState { return true }
            return false
        }
        guard case let .content(article) = articleModel.contentState else {
            return XCTFail("expected article content")
        }
        XCTAssertEqual(article.body, .officialHTML("<p>正文</p>"))

        let topicModel = CommunityTopicModel()
        let topicIntent = CommunityTopicIntent(model: topicModel,
                                                topicId: "t1",
                                                revisionId: "rev-t1")
        topicIntent.viewOnAppear()
        waitUntil(timeout: 5, description: "topic first page") {
            if case .content = topicModel.contentState { return true }
            return false
        }
        XCTAssertEqual(topicModel.topic?.items.map(\.id), ["a1"])

        topicIntent.loadMore()
        waitUntil(timeout: 5, description: "topic second page") {
            topicModel.topic?.items.count == 2
        }
        XCTAssertEqual(topicModel.topic?.items.map(\.id), ["a1", "a2"])
        XCTAssertFalse(topicModel.topic?.hasMore ?? true)
        XCTAssertEqual(topicModel.topic?.images.map(\.url?.lastPathComponent),
                       ["detail-1.png", "detail-2.png"],
                       "分页不得丢失首屏图集")
        XCTAssertEqual(topicModel.topic?.imageCount, 2)
        XCTAssertEqual(topicModel.topic?.imageLayout, .twoColumns)
    }
}

private final class LockedCounter {
    private let lock = NSLock()
    private var count = 0

    var value: Int {
        lock.lock(); defer { lock.unlock() }
        return count
    }

    func next() -> Int {
        lock.lock(); defer { lock.unlock() }
        count += 1
        return count
    }
}
