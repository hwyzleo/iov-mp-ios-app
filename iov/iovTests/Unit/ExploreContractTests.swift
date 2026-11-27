//
//  ExploreContractTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-012 on 2026/11/26.
//

import XCTest
import Alamofire
@testable import iov

/// TC-012-7 / TC-012-8：请求路径、查询参数、条件 GET 与业务错误码契约。
final class ExploreContractTests: XCTestCase {

    private var service: RealExploreService!

    override func setUp() {
        super.setUp()
        AuthEnvironment.shared.sessionRepository.clearSession()
        StubURLProtocol.reset()
        TspManager.networkManagerProvider = { makeStubbedNetworkManager() }
        service = RealExploreService()
    }

    override func tearDown() {
        TspManager.networkManagerProvider = { NetworkManager.shared }
        StubURLProtocol.reset()
        service = nil
        super.tearDown()
    }

    // MARK: - 频道

    func testChannelsRequestPathAndDecoding() {
        StubURLProtocol.handler = { _ in
            .json(exploreEnvelope(data: [exploreChannel("recommend", "推荐", sortNo: 1)]))
        }

        let result = waitChannels()

        XCTAssertEqual(result?.map(\.code), ["recommend"])
        let request = StubURLProtocol.requests.first
        XCTAssertEqual(request?.httpMethod, "GET")
        XCTAssertEqual(request?.url?.path, "/api/mobile/explore/v1/channels")
        XCTAssertEqual(request?.value(forHTTPHeaderField: "X-Client-Type"), "MOBILE")
    }

    func testChannelsBusinessCodeMapsToServiceUnavailable() {
        StubURLProtocol.handler = { _ in
            .json(exploreEnvelope(data: nil, code: "105016"))
        }
        XCTAssertEqual(waitChannelsFailure(), .serviceUnavailable)
    }

    // MARK: - 条件 GET

    func testCurrentPageSendsIfNoneMatchAndCapturesETag() {
        StubURLProtocol.handler = { _ in
            .json(exploreEnvelope(data: explorePage(channelCode: "recommend",
                                                    components: [exploreFeedComponent("feed-1", items: [])])),
                  headers: ["ETag": "\"release-1\"", "Content-Type": "application/json"])
        }

        let outcome = waitPage(channelCode: "recommend", ifNoneMatch: "\"release-0\"")

        guard case let .loaded(page, etag) = outcome else {
            return XCTFail("expected loaded page")
        }
        XCTAssertEqual(page.channelCode, "recommend")
        XCTAssertEqual(etag, "\"release-1\"")

        let request = StubURLProtocol.requests.first
        XCTAssertEqual(request?.url?.path, "/api/mobile/explore/v1/pages/current")
        let components = URLComponents(url: request!.url!, resolvingAgainstBaseURL: false)
        let query = Dictionary(uniqueKeysWithValues: (components?.queryItems ?? []).map { ($0.name, $0.value ?? "") })
        XCTAssertEqual(query["channelCode"], "recommend")
        XCTAssertEqual(query["pageSize"], "10")
        XCTAssertEqual(request?.value(forHTTPHeaderField: "If-None-Match"), "\"release-0\"")
    }

    func testHTTP304WithoutEnvelopeIsNotDecoded() {
        StubURLProtocol.handler = { _ in
            .empty(status: 304, headers: ["ETag": "\"release-1\""])
        }

        let outcome = waitPage(channelCode: "recommend", ifNoneMatch: "\"release-1\"")
        XCTAssertEqual(outcome, .notModified)
        XCTAssertEqual(StubURLProtocol.requests.count, 1)
    }

    func testCurrentPageNoContentCodeMapsToEmptyStateFailure() {
        StubURLProtocol.handler = { _ in
            .json(exploreEnvelope(data: nil, code: "105011"))
        }
        XCTAssertEqual(waitPageFailure(channelCode: "recommend"), .noContent)
    }

    // MARK: - 文章流

    func testArticleFeedSendsExactContextAndCursor() {
        StubURLProtocol.handler = { _ in
            .json(exploreEnvelope(data: exploreFeedPage(items: [exploreArticleItem("a2")],
                                                        hasMore: false)))
        }

        let result = waitFeed(channelCode: "recommend",
                              componentId: "feed-1",
                              releaseId: "release-1",
                              cursor: "opaque.cursor")

        XCTAssertEqual(result?.items.map(\.id), ["a2"])
        let request = StubURLProtocol.requests.first
        XCTAssertEqual(request?.url?.path, "/api/mobile/explore/v1/article-feed")
        let components = URLComponents(url: request!.url!, resolvingAgainstBaseURL: false)
        let query = Dictionary(uniqueKeysWithValues: (components?.queryItems ?? []).map { ($0.name, $0.value ?? "") })
        XCTAssertEqual(query, [
            "channelCode": "recommend",
            "componentId": "feed-1",
            "releaseId": "release-1",
            "cursor": "opaque.cursor",
            "pageSize": "10"
        ])
    }

    func testArticleFeedReleaseChangedAndComponentMismatch() {
        StubURLProtocol.handler = { _ in
            .json(exploreEnvelope(data: exploreFeedPage(releaseId: "release-2", items: [])))
        }
        XCTAssertEqual(waitFeedFailure(), .releaseChanged)

        StubURLProtocol.reset()
        TspManager.networkManagerProvider = { makeStubbedNetworkManager() }
        StubURLProtocol.handler = { _ in
            .json(exploreEnvelope(data: exploreFeedPage(componentId: "feed-2", items: [])))
        }
        XCTAssertEqual(waitFeedFailure(), .invalidArgument)
    }

    func testArticleFeedReleaseChangedBusinessCode() {
        StubURLProtocol.handler = { _ in
            .json(exploreEnvelope(data: nil, code: "105017"))
        }
        XCTAssertEqual(waitFeedFailure(), .releaseChanged)
    }

    // MARK: - 详情路径

    func testArticleDetailPathIsPercentEncoded() {
        StubURLProtocol.handler = { _ in
            .json(exploreEnvelope(data: exploreArticleDetail(articleId: "a/b c", revisionId: "r/1")))
        }

        let result = waitArticle(articleId: "a/b c", revisionId: "r/1")

        XCTAssertEqual(result?.articleId, "a/b c")
        let request = StubURLProtocol.requests.first
        let encodedPath = URLComponents(url: request!.url!, resolvingAgainstBaseURL: false)?.percentEncodedPath
        XCTAssertEqual(encodedPath,
                       "/api/mobile/explore/v1/articles/a%2Fb%20c/revisions/r%2F1")
    }

    func testArticleDetailNotFoundCodeMapsToContentUnavailable() {
        StubURLProtocol.handler = { _ in
            .json(exploreEnvelope(data: nil, code: "105010"))
        }
        XCTAssertEqual(waitArticleFailure(), .contentUnavailable)
    }

    func testTopicDetailSendsCursorAndPageSize() {
        StubURLProtocol.handler = { _ in
            .json(exploreEnvelope(data: exploreTopicDetail(items: [exploreArticleItem("a1")],
                                                           hasMore: false)))
        }

        let result = waitTopic(cursor: "topic.cursor")

        XCTAssertEqual(result?.items.map(\.id), ["a1"])
        let request = StubURLProtocol.requests.first
        XCTAssertEqual(request?.url?.path, "/api/mobile/explore/v1/topics/t1/revisions/rev-t1")
        let components = URLComponents(url: request!.url!, resolvingAgainstBaseURL: false)
        let query = Dictionary(uniqueKeysWithValues: (components?.queryItems ?? []).map { ($0.name, $0.value ?? "") })
        XCTAssertEqual(query, ["cursor": "topic.cursor", "pageSize": "10"])
    }

    // MARK: - 解码失败

    func testMalformedJSONMapsToInvalidResponse() {
        StubURLProtocol.handler = { _ in
            .json(Data("not json".utf8))
        }
        XCTAssertEqual(waitChannelsFailure(), .invalidResponse)
    }

    // MARK: - Helpers

    private func waitChannels() -> [ExploreChannelViewState]? {
        let expectation = expectation(description: "channels")
        var output: [ExploreChannelViewState]?
        service.loadChannels { result in
            if case let .success(channels) = result { output = channels }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
        return output
    }

    private func waitChannelsFailure() -> ExploreFailure? {
        let expectation = expectation(description: "channels failure")
        var output: ExploreFailure?
        service.loadChannels { result in
            if case let .failure(failure) = result { output = failure }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
        return output
    }

    private func waitPage(channelCode: String, ifNoneMatch: String?) -> ExplorePageLoadOutcome? {
        let expectation = expectation(description: "page")
        var output: ExplorePageLoadOutcome?
        service.loadCurrentPage(channelCode: channelCode,
                                pageSize: 10,
                                ifNoneMatch: ifNoneMatch) { result in
            if case let .success(outcome) = result { output = outcome }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
        return output
    }

    private func waitPageFailure(channelCode: String) -> ExploreFailure? {
        let expectation = expectation(description: "page failure")
        var output: ExploreFailure?
        service.loadCurrentPage(channelCode: channelCode,
                                pageSize: 10,
                                ifNoneMatch: nil) { result in
            if case let .failure(failure) = result { output = failure }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
        return output
    }

    private func waitFeed(channelCode: String = "recommend",
                          componentId: String = "feed-1",
                          releaseId: String = "release-1",
                          cursor: String? = nil) -> ExploreFeedPageViewState? {
        let expectation = expectation(description: "feed")
        var output: ExploreFeedPageViewState?
        service.loadArticleFeed(channelCode: channelCode,
                                componentId: componentId,
                                releaseId: releaseId,
                                cursor: cursor,
                                pageSize: 10) { result in
            if case let .success(page) = result { output = page }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
        return output
    }

    private func waitFeedFailure() -> ExploreFailure? {
        let expectation = expectation(description: "feed failure")
        var output: ExploreFailure?
        service.loadArticleFeed(channelCode: "recommend",
                                componentId: "feed-1",
                                releaseId: "release-1",
                                cursor: nil,
                                pageSize: 10) { result in
            if case let .failure(failure) = result { output = failure }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
        return output
    }

    private func waitArticle(articleId: String, revisionId: String) -> ExploreArticleDetailViewState? {
        let expectation = expectation(description: "article")
        var output: ExploreArticleDetailViewState?
        service.loadArticleDetail(articleId: articleId, revisionId: revisionId) { result in
            if case let .success(detail) = result { output = detail }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
        return output
    }

    private func waitArticleFailure() -> ExploreFailure? {
        let expectation = expectation(description: "article failure")
        var output: ExploreFailure?
        service.loadArticleDetail(articleId: "a1", revisionId: "rev-a1") { result in
            if case let .failure(failure) = result { output = failure }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
        return output
    }

    private func waitTopic(cursor: String?) -> ExploreTopicDetailViewState? {
        let expectation = expectation(description: "topic")
        var output: ExploreTopicDetailViewState?
        service.loadTopicDetail(topicId: "t1",
                                revisionId: "rev-t1",
                                cursor: cursor,
                                pageSize: 10) { result in
            if case let .success(topic) = result { output = topic }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
        return output
    }
}
