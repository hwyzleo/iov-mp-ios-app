//
//  ExploreViewState.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-012 on 2026/11/26.
//

import Foundation

// MARK: - 频道

struct ExploreChannelViewState: Identifiable, Equatable {
    var id: String { code }
    let code: String
    let name: String
    let sortNo: Int
}

// MARK: - 图片

/// 图片：非法 URL / 非法尺寸转为不可用，渲染层不得强制解包
struct ExploreImageViewState: Equatable {
    let url: URL?
    let width: Int?
    let height: Int?
    let mime: String?
    let size: Int64?

    var isAvailable: Bool { url != nil }
}

enum ExploreImageLayout: String, Equatable {
    case single = "SINGLE"
    case twoColumns = "TWO_COLUMNS"
    case oneLargeTwoSmall = "ONE_LARGE_TWO_SMALL"
    case twoByTwo = "TWO_BY_TWO"
    case threeColumns = "THREE_COLUMNS"
    case nineGridWithCount = "NINE_GRID_WITH_COUNT"
}

// MARK: - 跳转目标

struct ArticleRevisionRef: Hashable {
    let articleId: String
    let revisionId: String
}

struct TopicRevisionRef: Hashable {
    let topicId: String
    let revisionId: String
}

/// 条目目标：仅做结构化映射；HTTPS / NATIVE 白名单校验由 `ExploreTargetResolver` 负责。
enum ExploreTargetViewState: Equatable {
    case article(ArticleRevisionRef)
    case topic(TopicRevisionRef)
    case h5(URL)
    case native(routeCode: String, params: [String: String])
    case invalid
}

// MARK: - 组件条目

struct ExploreBannerItemViewState: Identifiable, Equatable {
    let id: String
    let title: String?
    let image: ExploreImageViewState?
    let target: ExploreTargetViewState
}

struct ExploreTopicItemViewState: Identifiable, Equatable {
    let id: String
    let topicId: String?
    let name: String?
    let summary: String?
    let cover: ExploreImageViewState?
    let target: ExploreTargetViewState
}

struct ExploreArticleCardViewState: Identifiable, Equatable {
    let id: String
    let sortNo: Int
    let title: String?
    let summary: String?
    let authorName: String?
    let authorAvatarURL: URL?
    let displayAt: Date?
    let images: [ExploreImageViewState]
    let imageCount: Int
    let imageLayout: ExploreImageLayout?
    let target: ExploreTargetViewState
}

// MARK: - 组件

enum ExploreTopicGridStyle: Equatable {
    case adaptiveGrid(columns: Int)
    case horizontalScroll
    case imageTextList
}

struct ExploreBannerComponentViewState: Equatable {
    let intervalSeconds: Int
    let items: [ExploreBannerItemViewState]
}

struct ExploreTopicGridComponentViewState: Equatable {
    let style: ExploreTopicGridStyle
    let items: [ExploreTopicItemViewState]
}

struct ExploreArticleFeedComponentViewState: Equatable {
    let items: [ExploreArticleCardViewState]
    let hasMore: Bool
    let nextCursor: String?
}

enum ExploreComponentContentViewState: Equatable {
    case banner(ExploreBannerComponentViewState)
    case topicGrid(ExploreTopicGridComponentViewState)
    case articleFeed(ExploreArticleFeedComponentViewState)
    case unknown
}

struct ExploreComponentViewState: Identifiable, Equatable {
    let id: String
    let sortNo: Int
    let title: String?
    let content: ExploreComponentContentViewState
}

// MARK: - 页面

struct ExplorePageViewState: Equatable {
    let schemaVersion: Int
    let channelCode: String
    let channelName: String
    let releaseId: String
    let publishedAt: Date?
    let components: [ExploreComponentViewState]

    /// 是否存在可渲染组件（未知组件不参与页面空态判定）
    var hasRenderableComponent: Bool {
        components.contains { component in
            if case .unknown = component.content {
                return false
            }
            return true
        }
    }

    func feed(componentId: String) -> ExploreArticleFeedComponentViewState? {
        guard let component = components.first(where: { $0.id == componentId }),
              case let .articleFeed(feed) = component.content else {
            return nil
        }
        return feed
    }
}

// MARK: - 文章详情

enum ExploreArticleBody: Equatable {
    case officialHTML(String)
    case ugcReference(sourceContentId: String?, nativeRouteCode: String?)
}

struct ExploreArticleDetailViewState: Equatable {
    let articleId: String
    let revisionId: String
    let title: String?
    let summary: String?
    let cover: ExploreImageViewState?
    let images: [ExploreImageViewState]
    let imageCount: Int
    let imageLayout: ExploreImageLayout?
    let authorName: String?
    let authorAvatarURL: URL?
    let displayAt: Date?
    let body: ExploreArticleBody

    /// 详情顶部轮播用图：过滤非法 URL；图集全部不可用时退回兼容 cover
    var galleryImages: [ExploreImageViewState] {
        let available = images.filter(\.isAvailable)
        if !available.isEmpty { return available }
        if let cover = cover, cover.isAvailable { return [cover] }
        return []
    }
}

// MARK: - 专题详情

struct ExploreTopicDetailViewState: Equatable {
    let topicId: String
    let revisionId: String
    let name: String?
    let summary: String?
    /// 兼容元数据，不再作为新契约详情图集的隐式数据源
    let cover: ExploreImageViewState?
    let images: [ExploreImageViewState]
    let imageCount: Int
    let imageLayout: ExploreImageLayout?
    let items: [ExploreArticleCardViewState]
    let hasMore: Bool
    let nextCursor: String?

    /// 详情顶部轮播用图：过滤非法 URL，避免占位图进入轮播
    var galleryImages: [ExploreImageViewState] {
        return images.filter(\.isAvailable)
    }
}

// MARK: - 分页结果

struct ExploreFeedPageViewState: Equatable {
    let releaseId: String
    let componentId: String
    let items: [ExploreArticleCardViewState]
    let hasMore: Bool
    let nextCursor: String?
}

// MARK: - 错误与状态

enum ExploreFailure: Error, Equatable {
    case network
    case serviceUnavailable
    case contentUnavailable
    case noContent
    case invalidArgument
    case releaseChanged
    case unsupportedSchemaVersion(Int)
    case invalidResponse
    case invalidTarget
    case unauthorized
    case unknown
}

enum ExploreContentState: Equatable {
    case loading
    case content
    case empty
    case error(ExploreFailure)
}

enum ExplorePresentationError: Equatable {
    case refresh(ExploreFailure)
    case feed(componentId: String, failure: ExploreFailure)
    case target(ExploreFailure)
}
