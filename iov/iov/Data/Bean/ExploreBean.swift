//
//  ExploreBean.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-012 on 2026/11/26.
//

import Foundation

// MARK: - 频道

/// 探索页频道（`GET /api/mobile/explore/v1/channels`）
struct ExploreChannelDTO: Codable, Equatable {
    var code: String
    var name: String
    var sortNo: Int?

    enum CodingKeys: String, CodingKey {
        case code, name, sortNo
    }
}

// MARK: - 页面

/// 页面内嵌频道（不含排序，排序由频道接口提供）
struct ExplorePageChannelDTO: Codable, Equatable {
    var code: String?
    var name: String?

    enum CodingKeys: String, CodingKey {
        case code, name
    }
}

/// 当前页面（`GET /api/mobile/explore/v1/pages/current`）
struct ExplorePageDTO: Codable {
    var schemaVersion: Int?
    var channel: ExplorePageChannelDTO?
    var releaseId: String?
    var publishedAt: String?
    var components: [ExploreComponentDTO]?

    enum CodingKeys: String, CodingKey {
        case schemaVersion, channel, releaseId, publishedAt, components
    }
}

/// 组件：配置字段与组件平铺，没有嵌套 `config`
struct ExploreComponentDTO: Codable {
    var type: String?
    var componentId: String?
    var sortNo: Int?
    var title: String?
    var style: String?
    var columns: Int?
    var intervalSeconds: Int?
    var items: [ExploreItemDTO]?
    var hasMore: Bool?
    var nextCursor: String?

    enum CodingKeys: String, CodingKey {
        case type, componentId, sortNo, title, style, columns, intervalSeconds
        case items, hasMore, nextCursor
    }
}

/// 条目：ARTICLE / BANNER / TOPIC 字段并集，全部按可选处理
struct ExploreItemDTO: Codable {
    var schemaVersion: Int?
    var itemType: String?
    var itemId: String?
    var sortNo: Int?
    var target: ExploreTargetDTO?

    // ARTICLE
    var articleId: String?
    var revisionId: String?
    var sourceType: String?
    var title: String?
    var summary: String?
    var cover: ExploreImageDTO?
    var images: [ExploreImageDTO]?
    var imageCount: Int?
    var imageLayout: String?
    var authorName: String?
    var authorAvatarUrl: String?
    var displayAt: String?

    // BANNER
    var bannerId: String?
    var image: ExploreImageDTO?

    // TOPIC
    var topicId: String?
    var name: String?

    enum CodingKeys: String, CodingKey {
        case schemaVersion, itemType, itemId, sortNo, target
        case articleId, revisionId, sourceType, title, summary, cover, images
        case imageCount, imageLayout, authorName, authorAvatarUrl, displayAt
        case bannerId, image
        case topicId, name
    }
}

/// 图片（非法 URL / 尺寸由映射层转为不可用，不在 DTO 强制解包）
struct ExploreImageDTO: Codable, Equatable {
    var url: String?
    var width: Int?
    var height: Int?
    var mime: String?
    var size: Int64?

    enum CodingKeys: String, CodingKey {
        case url, width, height, mime, size
    }
}

/// 类型化跳转目标（判别联合）
struct ExploreTargetDTO: Codable {
    var type: String?
    var articleId: String?
    var revisionId: String?
    var topicId: String?
    var url: String?
    var routeCode: String?
    var params: [String: String]?

    enum CodingKeys: String, CodingKey {
        case type, articleId, revisionId, topicId, url, routeCode, params
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        articleId = try container.decodeIfPresent(String.self, forKey: .articleId)
        revisionId = try container.decodeIfPresent(String.self, forKey: .revisionId)
        topicId = try container.decodeIfPresent(String.self, forKey: .topicId)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        routeCode = try container.decodeIfPresent(String.self, forKey: .routeCode)
        // 参数必须是字符串键值；非法结构只让目标不可解析，不让整页解析失败
        params = try? container.decodeIfPresent([String: String].self, forKey: .params)
    }
}

// MARK: - 文章详情

struct ExploreArticleDetailDTO: Codable {
    var articleId: String?
    var revisionId: String?
    var sourceType: String?
    var title: String?
    var summary: String?
    var cover: ExploreImageDTO?
    var images: [ExploreImageDTO]?
    var imageCount: Int?
    var imageLayout: String?
    var authorName: String?
    var authorAvatarUrl: String?
    var displayAt: String?
    var contentHash: String?
    var publishedAt: String?
    var contentType: String?
    var body: String?
    var sourceContentId: String?
    var nativeRouteCode: String?

    enum CodingKeys: String, CodingKey {
        case articleId, revisionId, sourceType, title, summary, cover, images
        case imageCount, imageLayout, authorName, authorAvatarUrl, displayAt
        case contentHash, publishedAt, contentType, body
        case sourceContentId, nativeRouteCode
    }
}

// MARK: - 专题详情

struct ExploreTopicDetailDTO: Codable {
    var topicId: String?
    var revisionId: String?
    var name: String?
    var summary: String?
    var cover: ExploreImageDTO?
    /// 详情可见图集：nil 表示旧服务未提供（可用 cover 单图兼容），[] 表示新契约明确无详情图
    var images: [ExploreImageDTO]?
    var imageCount: Int?
    var imageLayout: String?
    var target: ExploreTargetDTO?
    var items: [ExploreItemDTO]?
    var hasMore: Bool?
    var nextCursor: String?

    enum CodingKeys: String, CodingKey {
        case topicId, revisionId, name, summary, cover
        case images, imageCount, imageLayout
        case target, items, hasMore, nextCursor
    }
}

// MARK: - 信息流分页

struct ExploreFeedPageDTO: Codable {
    var releaseId: String?
    var componentId: String?
    var items: [ExploreItemDTO]?
    var hasMore: Bool?
    var nextCursor: String?

    enum CodingKeys: String, CodingKey {
        case releaseId, componentId, items, hasMore, nextCursor
    }
}
