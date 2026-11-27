//
//  ExploreTestSupport.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-012 on 2026/11/26.
//

import Foundation
import XCTest
@testable import iov

// MARK: - 响应包络

func exploreEnvelope(data: Any?, code: String = "000000") -> Data {
    var payload: [String: Any] = [
        "code": code,
        "message": code == "000000" ? "ok" : "error",
        "ts": 1_700_000_000_000,
        "timestamp": 1_700_000_000_000
    ]
    if let data = data {
        payload["data"] = data
    }
    return try! JSONSerialization.data(withJSONObject: payload)
}

func exploreJSON(_ payload: Any) -> Data {
    return try! JSONSerialization.data(withJSONObject: payload)
}

// MARK: - 频道 / 图片 / 目标

func exploreChannel(_ code: String, _ name: String, sortNo: Int? = nil) -> [String: Any] {
    var payload: [String: Any] = ["code": code, "name": name]
    if let sortNo = sortNo { payload["sortNo"] = sortNo }
    return payload
}

func exploreImage(_ url: String?, width: Int? = nil, height: Int? = nil) -> [String: Any] {
    var payload: [String: Any] = [:]
    if let url = url { payload["url"] = url }
    if let width = width { payload["width"] = width }
    if let height = height { payload["height"] = height }
    payload["mime"] = "image/png"
    payload["size"] = 1024
    return payload
}

func exploreTargetArticle(_ articleId: String, _ revisionId: String) -> [String: Any] {
    return ["type": "ARTICLE", "articleId": articleId, "revisionId": revisionId]
}

func exploreTargetTopic(_ topicId: String, _ revisionId: String) -> [String: Any] {
    return ["type": "TOPIC", "topicId": topicId, "revisionId": revisionId]
}

func exploreTargetH5(_ url: String) -> [String: Any] {
    return ["type": "H5", "url": url]
}

func exploreTargetNative(_ routeCode: String, _ params: [String: String] = [:]) -> [String: Any] {
    return ["type": "NATIVE", "routeCode": routeCode, "params": params]
}

// MARK: - 条目

func exploreArticleItem(_ itemId: String,
                        sortNo: Int? = nil,
                        title: String? = "标题",
                        summary: String? = "摘要",
                        images: [[String: Any]]? = nil,
                        imageCount: Int? = nil,
                        imageLayout: String? = nil,
                        authorName: String? = nil,
                        authorAvatarUrl: String? = nil,
                        displayAt: String? = nil,
                        target: [String: Any]? = nil) -> [String: Any] {
    var payload: [String: Any] = [
        "schemaVersion": 1,
        "itemType": "ARTICLE",
        "itemId": itemId
    ]
    if let sortNo = sortNo { payload["sortNo"] = sortNo }
    if let title = title { payload["title"] = title }
    if let summary = summary { payload["summary"] = summary }
    if let images = images { payload["images"] = images }
    if let imageCount = imageCount { payload["imageCount"] = imageCount }
    if let imageLayout = imageLayout { payload["imageLayout"] = imageLayout }
    if let authorName = authorName { payload["authorName"] = authorName }
    if let authorAvatarUrl = authorAvatarUrl { payload["authorAvatarUrl"] = authorAvatarUrl }
    if let displayAt = displayAt { payload["displayAt"] = displayAt }
    payload["articleId"] = itemId
    payload["revisionId"] = "rev-\(itemId)"
    payload["sourceType"] = "OFFICIAL"
    payload["target"] = target ?? exploreTargetArticle(itemId, "rev-\(itemId)")
    return payload
}

func exploreBannerItem(_ itemId: String,
                       title: String? = nil,
                       image: [String: Any]? = nil,
                       target: [String: Any]? = nil) -> [String: Any] {
    var payload: [String: Any] = [
        "schemaVersion": 1,
        "itemType": "BANNER",
        "itemId": itemId,
        "bannerId": itemId,
        "revisionId": "rev-\(itemId)"
    ]
    if let title = title { payload["title"] = title }
    if let image = image { payload["image"] = image }
    payload["target"] = target ?? exploreTargetArticle(itemId, "rev-\(itemId)")
    return payload
}

func exploreTopicItem(_ itemId: String,
                      name: String? = nil,
                      summary: String? = nil,
                      cover: [String: Any]? = nil,
                      target: [String: Any]? = nil) -> [String: Any] {
    var payload: [String: Any] = [
        "schemaVersion": 1,
        "itemType": "TOPIC",
        "itemId": itemId,
        "topicId": itemId,
        "revisionId": "rev-\(itemId)"
    ]
    if let name = name { payload["name"] = name }
    if let summary = summary { payload["summary"] = summary }
    if let cover = cover { payload["cover"] = cover }
    payload["target"] = target ?? exploreTargetTopic(itemId, "rev-\(itemId)")
    return payload
}

// MARK: - 组件 / 页面

func exploreBannerComponent(_ componentId: String,
                            sortNo: Int = 1,
                            title: String? = nil,
                            intervalSeconds: Int? = nil,
                            items: [[String: Any]]) -> [String: Any] {
    var payload: [String: Any] = [
        "type": "BANNER_CAROUSEL",
        "componentId": componentId,
        "sortNo": sortNo,
        "items": items
    ]
    if let title = title { payload["title"] = title }
    if let intervalSeconds = intervalSeconds { payload["intervalSeconds"] = intervalSeconds }
    return payload
}

func exploreTopicComponent(_ componentId: String,
                           sortNo: Int = 2,
                           title: String? = nil,
                           style: String? = nil,
                           columns: Int? = nil,
                           items: [[String: Any]]) -> [String: Any] {
    var payload: [String: Any] = [
        "type": "TOPIC_GRID",
        "componentId": componentId,
        "sortNo": sortNo,
        "items": items
    ]
    if let title = title { payload["title"] = title }
    if let style = style { payload["style"] = style }
    if let columns = columns { payload["columns"] = columns }
    return payload
}

func exploreFeedComponent(_ componentId: String,
                          sortNo: Int = 3,
                          title: String? = nil,
                          items: [[String: Any]],
                          hasMore: Bool? = nil,
                          nextCursor: String? = nil) -> [String: Any] {
    var payload: [String: Any] = [
        "type": "ARTICLE_FEED",
        "componentId": componentId,
        "sortNo": sortNo,
        "items": items
    ]
    if let hasMore = hasMore { payload["hasMore"] = hasMore }
    if let nextCursor = nextCursor { payload["nextCursor"] = nextCursor }
    if let title = title { payload["title"] = title }
    return payload
}

func explorePage(channelCode: String,
                 channelName: String = "推荐",
                 releaseId: String = "release-1",
                 schemaVersion: Int? = 1,
                 publishedAt: String? = "2026-11-26T10:00:00.123Z",
                 components: [[String: Any]]) -> [String: Any] {
    var payload: [String: Any] = [
        "channel": ["code": channelCode, "name": channelName],
        "releaseId": releaseId,
        "components": components
    ]
    if let schemaVersion = schemaVersion { payload["schemaVersion"] = schemaVersion }
    if let publishedAt = publishedAt { payload["publishedAt"] = publishedAt }
    return payload
}

func exploreFeedPage(releaseId: String = "release-1",
                     componentId: String = "feed-1",
                     items: [[String: Any]],
                     hasMore: Bool? = nil,
                     nextCursor: String? = nil) -> [String: Any] {
    var payload: [String: Any] = [
        "releaseId": releaseId,
        "componentId": componentId,
        "items": items
    ]
    if let hasMore = hasMore { payload["hasMore"] = hasMore }
    if let nextCursor = nextCursor { payload["nextCursor"] = nextCursor }
    return payload
}

func exploreArticleDetail(articleId: String = "a1",
                          revisionId: String = "rev-a1",
                          sourceType: String = "OFFICIAL",
                          title: String? = "标题",
                          summary: String? = "摘要",
                          body: String? = "<p>正文</p>",
                          images: [[String: Any]]? = nil,
                          imageCount: Int? = nil,
                          imageLayout: String? = nil,
                          authorName: String? = "作者",
                          nativeRouteCode: String? = nil) -> [String: Any] {
    var payload: [String: Any] = [
        "articleId": articleId,
        "revisionId": revisionId,
        "sourceType": sourceType
    ]
    if let title = title { payload["title"] = title }
    if let summary = summary { payload["summary"] = summary }
    if let body = body { payload["body"] = body }
    if let images = images { payload["images"] = images }
    if let imageCount = imageCount { payload["imageCount"] = imageCount }
    if let imageLayout = imageLayout { payload["imageLayout"] = imageLayout }
    if let authorName = authorName { payload["authorName"] = authorName }
    if let nativeRouteCode = nativeRouteCode { payload["nativeRouteCode"] = nativeRouteCode }
    payload["displayAt"] = "2026-11-26T10:00:00Z"
    return payload
}

func exploreTopicDetail(topicId: String = "t1",
                        revisionId: String = "rev-t1",
                        name: String? = "专题",
                        summary: String? = "概要",
                        cover: [String: Any]? = nil,
                        images: [[String: Any]]? = nil,
                        imageCount: Int? = nil,
                        imageLayout: String? = nil,
                        items: [[String: Any]],
                        hasMore: Bool? = nil,
                        nextCursor: String? = nil) -> [String: Any] {
    var payload: [String: Any] = [
        "topicId": topicId,
        "revisionId": revisionId,
        "items": items
    ]
    if let name = name { payload["name"] = name }
    if let summary = summary { payload["summary"] = summary }
    if let cover = cover { payload["cover"] = cover }
    // images 传 nil 表示字段缺失（旧服务），传 [] 表示新契约明确无详情图
    if let images = images { payload["images"] = images }
    if let imageCount = imageCount { payload["imageCount"] = imageCount }
    if let imageLayout = imageLayout { payload["imageLayout"] = imageLayout }
    if let hasMore = hasMore { payload["hasMore"] = hasMore }
    if let nextCursor = nextCursor { payload["nextCursor"] = nextCursor }
    return payload
}

// MARK: - 解码 / 映射快捷方法

func decodeExplore<T: Decodable>(_ type: T.Type, _ payload: Any) throws -> T {
    let data = try JSONSerialization.data(withJSONObject: payload)
    return try TspManager.makeDecoder().decode(type, from: data)
}

func mapExplorePage(_ payload: [String: Any]) throws -> ExplorePageViewState {
    let dto = try decodeExplore(ExplorePageDTO.self, payload)
    switch ExploreViewStateMapper.mapPage(dto) {
    case let .success(page):
        return page
    case let .failure(failure):
        throw failure
    }
}

// MARK: - ViewState 构造

func makeChannelState(_ code: String, _ name: String = "推荐", sortNo: Int = 0) -> ExploreChannelViewState {
    return ExploreChannelViewState(code: code, name: name, sortNo: sortNo)
}

func makeArticleCard(_ id: String,
                     title: String? = "标题",
                     target: ExploreTargetViewState = .invalid,
                     images: [ExploreImageViewState] = [],
                     imageCount: Int = 0,
                     imageLayout: ExploreImageLayout? = nil) -> ExploreArticleCardViewState {
    return ExploreArticleCardViewState(
        id: id,
        sortNo: 0,
        title: title,
        summary: nil,
        authorName: nil,
        authorAvatarURL: nil,
        displayAt: nil,
        images: images,
        imageCount: imageCount,
        imageLayout: imageLayout,
        target: target
    )
}

func makeFeedComponentState(_ id: String,
                            items: [ExploreArticleCardViewState],
                            hasMore: Bool = false,
                            nextCursor: String? = nil,
                            sortNo: Int = 1,
                            title: String? = nil) -> ExploreComponentViewState {
    return ExploreComponentViewState(
        id: id,
        sortNo: sortNo,
        title: title,
        content: .articleFeed(ExploreArticleFeedComponentViewState(items: items,
                                                                   hasMore: hasMore,
                                                                   nextCursor: nextCursor))
    )
}

func makePageState(channelCode: String = "recommend",
                   releaseId: String = "release-1",
                   components: [ExploreComponentViewState]) -> ExplorePageViewState {
    return ExplorePageViewState(
        schemaVersion: 1,
        channelCode: channelCode,
        channelName: "推荐",
        releaseId: releaseId,
        publishedAt: nil,
        components: components
    )
}

// MARK: - 服务替身

final class FakeExploreService: ExploreServiceProtocol {

    struct PageCall: Equatable {
        let channelCode: String
        let pageSize: Int
        let ifNoneMatch: String?
    }

    struct FeedCall: Equatable {
        let channelCode: String
        let componentId: String
        let releaseId: String
        let cursor: String?
        let pageSize: Int
    }

    struct TopicCall: Equatable {
        let topicId: String
        let revisionId: String
        let cursor: String?
        let pageSize: Int
    }

    var channelResults: [Result<[ExploreChannelViewState], ExploreFailure>] = []
    var pageResults: [Result<ExplorePageLoadOutcome, ExploreFailure>] = []
    var feedResults: [Result<ExploreFeedPageViewState, ExploreFailure>] = []
    var articleResults: [Result<ExploreArticleDetailViewState, ExploreFailure>] = []
    var topicResults: [Result<ExploreTopicDetailViewState, ExploreFailure>] = []

    private(set) var channelCallCount = 0
    private(set) var pageCalls: [PageCall] = []
    private(set) var feedCalls: [FeedCall] = []
    private(set) var articleCalls: [(articleId: String, revisionId: String)] = []
    private(set) var topicCalls: [TopicCall] = []

    var holdPage = false
    var holdFeed = false
    var holdChannels = false

    private var heldPage: [(Result<ExplorePageLoadOutcome, ExploreFailure>) -> Void] = []
    private var heldFeed: [(Result<ExploreFeedPageViewState, ExploreFailure>) -> Void] = []
    private var heldChannels: [(Result<[ExploreChannelViewState], ExploreFailure>) -> Void] = []

    func enqueueChannels(_ result: Result<[ExploreChannelViewState], ExploreFailure>) {
        channelResults.append(result)
    }

    func enqueuePage(_ result: Result<ExplorePageLoadOutcome, ExploreFailure>) {
        pageResults.append(result)
    }

    func enqueueFeed(_ result: Result<ExploreFeedPageViewState, ExploreFailure>) {
        feedResults.append(result)
    }

    func enqueueArticle(_ result: Result<ExploreArticleDetailViewState, ExploreFailure>) {
        articleResults.append(result)
    }

    func enqueueTopic(_ result: Result<ExploreTopicDetailViewState, ExploreFailure>) {
        topicResults.append(result)
    }

    func completeHeldPage(_ result: Result<ExplorePageLoadOutcome, ExploreFailure>) {
        guard !heldPage.isEmpty else { return }
        heldPage.removeFirst()(result)
    }

    func completeHeldFeed(_ result: Result<ExploreFeedPageViewState, ExploreFailure>) {
        guard !heldFeed.isEmpty else { return }
        heldFeed.removeFirst()(result)
    }

    func completeHeldChannels(_ result: Result<[ExploreChannelViewState], ExploreFailure>) {
        guard !heldChannels.isEmpty else { return }
        heldChannels.removeFirst()(result)
    }

    func loadChannels(completion: @escaping (Result<[ExploreChannelViewState], ExploreFailure>) -> Void) {
        channelCallCount += 1
        if holdChannels {
            heldChannels.append(completion)
            return
        }
        guard !channelResults.isEmpty else {
            completion(.success([]))
            return
        }
        completion(channelResults.removeFirst())
    }

    func loadCurrentPage(channelCode: String,
                         pageSize: Int,
                         ifNoneMatch: String?,
                         completion: @escaping (Result<ExplorePageLoadOutcome, ExploreFailure>) -> Void) {
        pageCalls.append(PageCall(channelCode: channelCode, pageSize: pageSize, ifNoneMatch: ifNoneMatch))
        if holdPage {
            heldPage.append(completion)
            return
        }
        guard !pageResults.isEmpty else {
            completion(.failure(.invalidResponse))
            return
        }
        completion(pageResults.removeFirst())
    }

    func loadArticleFeed(channelCode: String,
                         componentId: String,
                         releaseId: String,
                         cursor: String?,
                         pageSize: Int,
                         completion: @escaping (Result<ExploreFeedPageViewState, ExploreFailure>) -> Void) {
        feedCalls.append(FeedCall(channelCode: channelCode,
                                  componentId: componentId,
                                  releaseId: releaseId,
                                  cursor: cursor,
                                  pageSize: pageSize))
        if holdFeed {
            heldFeed.append(completion)
            return
        }
        guard !feedResults.isEmpty else {
            completion(.failure(.invalidResponse))
            return
        }
        completion(feedResults.removeFirst())
    }

    func loadArticleDetail(articleId: String,
                           revisionId: String,
                           completion: @escaping (Result<ExploreArticleDetailViewState, ExploreFailure>) -> Void) {
        articleCalls.append((articleId, revisionId))
        guard !articleResults.isEmpty else {
            completion(.failure(.invalidResponse))
            return
        }
        completion(articleResults.removeFirst())
    }

    func loadTopicDetail(topicId: String,
                         revisionId: String,
                         cursor: String?,
                         pageSize: Int,
                         completion: @escaping (Result<ExploreTopicDetailViewState, ExploreFailure>) -> Void) {
        topicCalls.append(TopicCall(topicId: topicId,
                                    revisionId: revisionId,
                                    cursor: cursor,
                                    pageSize: pageSize))
        guard !topicResults.isEmpty else {
            completion(.failure(.invalidResponse))
            return
        }
        completion(topicResults.removeFirst())
    }
}
