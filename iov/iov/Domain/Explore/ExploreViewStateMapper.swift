//
//  ExploreViewStateMapper.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-012 on 2026/11/26.
//

import Foundation

/// DTO → UI 状态的纯映射层。
/// - 不依赖 SwiftUI，不访问网络
/// - 对未知枚举 / 缺失可选字段做前向兼容
/// - 不做任何 URL 强制解包
enum ExploreViewStateMapper {

    static let supportedSchemaVersion = 1

    // MARK: - 频道

    static func mapChannels(_ dtos: [ExploreChannelDTO]) -> [ExploreChannelViewState] {
        return dtos.compactMap { dto in
            let code = trimmed(dto.code)
            guard !code.isEmpty else { return nil }
            return ExploreChannelViewState(code: code,
                                           name: dto.name,
                                           sortNo: dto.sortNo ?? 0)
        }
    }

    // MARK: - 页面

    static func mapPage(_ dto: ExplorePageDTO) -> Result<ExplorePageViewState, ExploreFailure> {
        guard let schemaVersion = dto.schemaVersion else {
            return .failure(.invalidResponse)
        }
        guard schemaVersion == supportedSchemaVersion else {
            return .failure(.unsupportedSchemaVersion(schemaVersion))
        }
        let channelCode = trimmed(dto.channel?.code ?? "")
        let releaseId = trimmed(dto.releaseId ?? "")
        guard !channelCode.isEmpty, !releaseId.isEmpty else {
            return .failure(.invalidResponse)
        }

        let rawComponents = dto.components ?? []
        var mapped: [(sortNo: Int, index: Int, component: ExploreComponentViewState)] = []
        for (index, raw) in rawComponents.enumerated() {
            guard let componentId = nonEmpty(raw.componentId) else { continue }
            let sortNo = raw.sortNo ?? index
            let component = ExploreComponentViewState(
                id: componentId,
                sortNo: sortNo,
                title: nonEmpty(raw.title),
                content: mapComponentContent(raw)
            )
            mapped.append((sortNo, index, component))
        }
        mapped.sort { lhs, rhs in
            if lhs.sortNo == rhs.sortNo { return lhs.index < rhs.index }
            return lhs.sortNo < rhs.sortNo
        }

        return .success(ExplorePageViewState(
            schemaVersion: schemaVersion,
            channelCode: channelCode,
            channelName: dto.channel?.name ?? "",
            releaseId: releaseId,
            publishedAt: parseDate(dto.publishedAt),
            components: mapped.map(\.component)
        ))
    }

    // MARK: - 信息流

    static func mapFeedPage(
        _ dto: ExploreFeedPageDTO,
        expectedReleaseId: String,
        expectedComponentId: String
    ) -> Result<ExploreFeedPageViewState, ExploreFailure> {
        guard let releaseId = nonEmpty(dto.releaseId),
              let componentId = nonEmpty(dto.componentId) else {
            return .failure(.invalidResponse)
        }
        guard releaseId == expectedReleaseId else {
            return .failure(.releaseChanged)
        }
        guard componentId == expectedComponentId else {
            return .failure(.invalidArgument)
        }

        let items = (dto.items ?? []).compactMap(mapArticleItem)
        let nextCursor = nonEmpty(dto.nextCursor)
        let hasMore = (dto.hasMore ?? false) && nextCursor != nil
        return .success(ExploreFeedPageViewState(
            releaseId: releaseId,
            componentId: componentId,
            items: items,
            hasMore: hasMore,
            nextCursor: hasMore ? nextCursor : nil
        ))
    }

    // MARK: - 文章详情

    static func mapArticleDetail(
        _ dto: ExploreArticleDetailDTO,
        expectedArticleId: String,
        expectedRevisionId: String
    ) -> Result<ExploreArticleDetailViewState, ExploreFailure> {
        guard let articleId = nonEmpty(dto.articleId),
              let revisionId = nonEmpty(dto.revisionId) else {
            return .failure(.invalidResponse)
        }
        guard articleId == expectedArticleId, revisionId == expectedRevisionId else {
            return .failure(.invalidResponse)
        }

        let sourceType = (dto.sourceType ?? "").uppercased()
        let body: ExploreArticleBody
        switch sourceType {
        case "OFFICIAL":
            guard let html = nonEmpty(dto.body) else {
                return .failure(.contentUnavailable)
            }
            body = .officialHTML(html)
        case "UGC_REFERENCE":
            body = .ugcReference(sourceContentId: nonEmpty(dto.sourceContentId),
                                 nativeRouteCode: nonEmpty(dto.nativeRouteCode))
        default:
            // 未知来源不允许猜测为官方正文或回退到其他内容
            return .failure(.contentUnavailable)
        }

        let images = mapImages(dto.images)
        let imageCount = effectiveImageCount(declared: dto.imageCount, images: images)
        return .success(ExploreArticleDetailViewState(
            articleId: articleId,
            revisionId: revisionId,
            title: nonEmpty(dto.title),
            summary: nonEmpty(dto.summary),
            cover: mapImage(dto.cover),
            images: images,
            imageCount: imageCount,
            imageLayout: resolveImageLayout(declared: dto.imageLayout, count: imageCount),
            authorName: nonEmpty(dto.authorName),
            authorAvatarURL: validRemoteURL(dto.authorAvatarUrl),
            displayAt: parseDate(dto.displayAt),
            body: body
        ))
    }

    // MARK: - 专题详情

    static func mapTopicDetail(
        _ dto: ExploreTopicDetailDTO,
        expectedTopicId: String,
        expectedRevisionId: String
    ) -> Result<ExploreTopicDetailViewState, ExploreFailure> {
        guard let topicId = nonEmpty(dto.topicId),
              let revisionId = nonEmpty(dto.revisionId) else {
            return .failure(.invalidResponse)
        }
        guard topicId == expectedTopicId, revisionId == expectedRevisionId else {
            return .failure(.invalidResponse)
        }

        let items = (dto.items ?? []).compactMap(mapArticleItem)
        let nextCursor = nonEmpty(dto.nextCursor)
        let hasMore = (dto.hasMore ?? false) && nextCursor != nil
        let cover = mapImage(dto.cover)
        let images = mapTopicDetailImages(dto.images, cover: cover)
        let imageCount = effectiveImageCount(declared: dto.imageCount, images: images)
        return .success(ExploreTopicDetailViewState(
            topicId: topicId,
            revisionId: revisionId,
            name: nonEmpty(dto.name),
            summary: nonEmpty(dto.summary),
            cover: cover,
            images: images,
            imageCount: imageCount,
            // 无可见图片时不建立媒体容器，避免声明数量凭空生成布局
            imageLayout: images.isEmpty ? nil : resolveImageLayout(declared: dto.imageLayout, count: imageCount),
            items: items,
            hasMore: hasMore,
            nextCursor: hasMore ? nextCursor : nil
        ))
    }

    /// D-013-1 / D-013-3：新契约只消费 `images`；仅字段缺失时才以合法 `cover` 单图兼容。
    static func mapTopicDetailImages(_ dtos: [ExploreImageDTO]?,
                                     cover: ExploreImageViewState?) -> [ExploreImageViewState] {
        if let dtos = dtos {
            // 显式集合（含空数组）即事实，不插入、不前置 cover
            return mapImages(dtos)
        }
        guard let cover = cover, cover.isAvailable else { return [] }
        return [cover]
    }

    // MARK: - 条目

    static func mapArticleItem(_ dto: ExploreItemDTO) -> ExploreArticleCardViewState? {
        guard (dto.itemType ?? "").uppercased() == "ARTICLE",
              let itemId = nonEmpty(dto.itemId) else {
            return nil
        }
        let images = mapImages(dto.images)
        let imageCount = effectiveImageCount(declared: dto.imageCount, images: images)
        return ExploreArticleCardViewState(
            id: itemId,
            sortNo: dto.sortNo ?? 0,
            title: nonEmpty(dto.title),
            summary: nonEmpty(dto.summary),
            authorName: nonEmpty(dto.authorName),
            authorAvatarURL: validRemoteURL(dto.authorAvatarUrl),
            displayAt: parseDate(dto.displayAt),
            images: images,
            imageCount: imageCount,
            imageLayout: resolveImageLayout(declared: dto.imageLayout, count: imageCount),
            target: mapTarget(dto.target)
        )
    }

    // MARK: - 组件内容

    static func mapComponentContent(_ dto: ExploreComponentDTO) -> ExploreComponentContentViewState {
        switch (dto.type ?? "").uppercased() {
        case "BANNER_CAROUSEL":
            return .banner(mapBannerComponent(dto))
        case "TOPIC_GRID":
            return .topicGrid(mapTopicGridComponent(dto))
        case "ARTICLE_FEED":
            return .articleFeed(makeArticleFeed(dto))
        default:
            return .unknown
        }
    }

    static func mapBannerComponent(_ dto: ExploreComponentDTO) -> ExploreBannerComponentViewState {
        let interval = dto.intervalSeconds ?? 5
        let safeInterval = (3...10).contains(interval) ? interval : 5
        let items = (dto.items ?? []).compactMap { item -> ExploreBannerItemViewState? in
            guard (item.itemType ?? "").uppercased() == "BANNER",
                  let itemId = nonEmpty(item.itemId) else {
                return nil
            }
            return ExploreBannerItemViewState(
                id: itemId,
                title: nonEmpty(item.title),
                image: mapImage(item.image),
                target: mapTarget(item.target)
            )
        }
        return ExploreBannerComponentViewState(intervalSeconds: safeInterval, items: items)
    }

    static func mapTopicGridComponent(_ dto: ExploreComponentDTO) -> ExploreTopicGridComponentViewState {
        let style: ExploreTopicGridStyle
        switch (dto.style ?? "ADAPTIVE_GRID").uppercased() {
        case "ADAPTIVE_GRID":
            let columns = [2, 3, 4].contains(dto.columns ?? 4) ? (dto.columns ?? 4) : 4
            style = .adaptiveGrid(columns: columns)
        case "HORIZONTAL_SCROLL":
            style = .horizontalScroll
        case "IMAGE_TEXT_LIST":
            style = .imageTextList
        default:
            style = .adaptiveGrid(columns: 4)
        }

        let items = (dto.items ?? []).compactMap { item -> ExploreTopicItemViewState? in
            guard (item.itemType ?? "").uppercased() == "TOPIC",
                  let itemId = nonEmpty(item.itemId) else {
                return nil
            }
            return ExploreTopicItemViewState(
                id: itemId,
                topicId: nonEmpty(item.topicId),
                name: nonEmpty(item.name),
                summary: nonEmpty(item.summary),
                cover: mapImage(item.cover),
                target: mapTarget(item.target)
            )
        }
        return ExploreTopicGridComponentViewState(style: style, items: items)
    }

    static func makeArticleFeed(_ dto: ExploreComponentDTO) -> ExploreArticleFeedComponentViewState {
        let items = (dto.items ?? []).compactMap(mapArticleItem)
        let nextCursor = nonEmpty(dto.nextCursor)
        let hasMore = (dto.hasMore ?? false) && nextCursor != nil
        return ExploreArticleFeedComponentViewState(items: items,
                                                    hasMore: hasMore,
                                                    nextCursor: hasMore ? nextCursor : nil)
    }

    // MARK: - 目标

    static func mapTarget(_ dto: ExploreTargetDTO?) -> ExploreTargetViewState {
        guard let dto = dto else { return .invalid }
        switch (dto.type ?? "").uppercased() {
        case "ARTICLE":
            guard let articleId = nonEmpty(dto.articleId),
                  let revisionId = nonEmpty(dto.revisionId) else {
                return .invalid
            }
            return .article(ArticleRevisionRef(articleId: articleId, revisionId: revisionId))
        case "TOPIC":
            guard let topicId = nonEmpty(dto.topicId),
                  let revisionId = nonEmpty(dto.revisionId) else {
                return .invalid
            }
            return .topic(TopicRevisionRef(topicId: topicId, revisionId: revisionId))
        case "H5":
            guard let raw = nonEmpty(dto.url), let url = URL(string: raw) else {
                return .invalid
            }
            return .h5(url)
        case "NATIVE":
            guard let routeCode = nonEmpty(dto.routeCode) else {
                return .invalid
            }
            return .native(routeCode: routeCode, params: dto.params ?? [:])
        default:
            return .invalid
        }
    }

    // MARK: - 图片与布局

    static func mapImage(_ dto: ExploreImageDTO?) -> ExploreImageViewState? {
        guard let dto = dto else { return nil }
        let width = (dto.width ?? 0) > 0 ? dto.width : nil
        let height = (dto.height ?? 0) > 0 ? dto.height : nil
        let size = (dto.size ?? 0) > 0 ? dto.size : nil
        return ExploreImageViewState(
            url: validRemoteURL(dto.url),
            width: width,
            height: height,
            mime: nonEmpty(dto.mime),
            size: size
        )
    }

    static func mapImages(_ dtos: [ExploreImageDTO]?) -> [ExploreImageViewState] {
        return (dtos ?? []).map { mapImage($0) ?? ExploreImageViewState(url: nil,
                                                                      width: nil,
                                                                      height: nil,
                                                                      mime: nil,
                                                                      size: nil) }
    }

    static func effectiveImageCount(declared: Int?, images: [ExploreImageViewState]) -> Int {
        return max(max(declared ?? 0, images.count), 0)
    }

    /// 服务端布局仅在可识别且与数量兼容时采用，否则按数量推导
    static func resolveImageLayout(declared: String?, count: Int) -> ExploreImageLayout? {
        guard count > 0 else { return nil }
        if let declared = declared,
           let layout = ExploreImageLayout(rawValue: declared.uppercased()),
           isCompatible(layout, count: count) {
            return layout
        }
        switch count {
        case 1: return .single
        case 2: return .twoColumns
        case 3: return .oneLargeTwoSmall
        case 4: return .twoByTwo
        case 5...9: return .threeColumns
        default: return .nineGridWithCount
        }
    }

    static func isCompatible(_ layout: ExploreImageLayout, count: Int) -> Bool {
        switch layout {
        case .single: return count == 1
        case .twoColumns: return count == 2
        case .oneLargeTwoSmall: return count == 3
        case .twoByTwo: return count == 4
        case .threeColumns: return (5...9).contains(count)
        case .nineGridWithCount: return count >= 9
        }
    }

    // MARK: - Helpers

    static func parseDate(_ text: String?) -> Date? {
        guard let text = nonEmpty(text) else { return nil }
        return TspManager.parseTimestamp(from: text)
    }

    static func validRemoteURL(_ text: String?) -> URL? {
        guard let raw = nonEmpty(text),
              let url = URL(string: raw),
              let scheme = url.scheme?.lowercased(),
              scheme == "https" || scheme == "http",
              let host = url.host,
              !host.isEmpty else {
            return nil
        }
        return url
    }

    static func nonEmpty(_ text: String?) -> String? {
        guard let text = text else { return nil }
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }

    private static func trimmed(_ text: String) -> String {
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
