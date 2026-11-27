//
//  ExploreCardViews.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-012 on 2026/11/26.
//

import SwiftUI
import Kingfisher

// MARK: - 远程图片（安全可选 URL）

struct ExploreRemoteImage: View {
    let image: ExploreImageViewState?
    /// 固定高度；设置 `aspectRatio` 时忽略该值
    var height: CGFloat? = 160
    /// 自适应比例（例如 1 表示正方形），用于网格布局
    var aspectRatio: CGFloat?
    var cornerRadius: CGFloat = ExploreTheme.Radius.card
    var accessibilityLabel: String?

    init(image: ExploreImageViewState?,
         height: CGFloat? = 160,
         aspectRatio: CGFloat? = nil,
         cornerRadius: CGFloat = ExploreTheme.Radius.card,
         accessibilityLabel: String? = nil) {
        self.image = image
        self.height = height
        self.aspectRatio = aspectRatio
        self.cornerRadius = cornerRadius
        self.accessibilityLabel = accessibilityLabel
    }

    var body: some View {
        sizedContent
            .frame(maxWidth: .infinity)
            .clipped()
            .cornerRadius(cornerRadius)
            .accessibilityLabel(Text(accessibilityLabel ?? NSLocalizedString("explore_image_unavailable", comment: "")))
    }

    @ViewBuilder
    private var sizedContent: some View {
        if let aspectRatio = aspectRatio {
            imageContent
                .aspectRatio(aspectRatio, contentMode: .fit)
        } else {
            imageContent
                .frame(height: height ?? 160)
        }
    }

    /// 以透明容器作为布局尺寸，图片只作为 overlay，避免 `scaledToFill` 的固有宽度撑破网格。
    private var imageContent: some View {
        Color.clear
            .overlay {
                if let url = image?.url {
                    KFImage(url)
                        .placeholder { placeholder }
                        .resizable()
                        .scaledToFill()
                } else {
                    placeholder
                }
            }
    }

    private var placeholder: some View {
        ZStack {
            ExploreTheme.Colors.surface2
            Image(systemName: "photo")
                .font(.system(size: ExploreTheme.Layout.iconSize, weight: .medium))
                .foregroundColor(ExploreTheme.Colors.textTertiary)
        }
    }
}

// MARK: - 头像

struct ExploreAvatarView: View {
    let url: URL?
    var size: CGFloat = 28

    var body: some View {
        ZStack {
            Circle()
                .fill(ExploreTheme.Colors.surface2)
            if let url = url {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.45, weight: .medium))
                    .foregroundColor(ExploreTheme.Colors.textTertiary)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(ExploreTheme.Colors.border, lineWidth: 1))
    }
}

// MARK: - 多图布局

struct ExploreMediaGrid: View {
    let images: [ExploreImageViewState]
    let imageCount: Int
    let layout: ExploreImageLayout
    var accessibilityLabel: String?

    private let spacing: CGFloat = 6

    var body: some View {
        content
    }

    @ViewBuilder
    private var content: some View {
        if images.isEmpty {
            ExploreRemoteImage(image: nil,
                               height: 160,
                               accessibilityLabel: accessibilityLabel)
        } else {
            switch layout {
            case .single:
                cell(images[0], height: 200, cornerRadius: ExploreTheme.Radius.card)
            case .twoColumns:
                HStack(spacing: spacing) {
                    ForEach(Array(images.prefix(2).enumerated()), id: \.offset) { _, image in
                        cell(image, height: 120, cornerRadius: ExploreTheme.Radius.card)
                    }
                }
            case .oneLargeTwoSmall:
                HStack(spacing: spacing) {
                    cell(images[0], height: 180, cornerRadius: ExploreTheme.Radius.card)
                    VStack(spacing: spacing) {
                        ForEach(Array(images.dropFirst().prefix(2).enumerated()), id: \.offset) { _, image in
                            cell(image, height: 88, cornerRadius: ExploreTheme.Radius.card)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            case .twoByTwo:
                grid(columns: 2, maxCount: 4, aspectRatio: 1)
            case .threeColumns:
                grid(columns: 3, maxCount: 9, aspectRatio: 1)
            case .nineGridWithCount:
                grid(columns: 3, maxCount: 9, aspectRatio: 1, overlayTotal: imageCount > 9 ? imageCount : nil)
            }
        }
    }

    private func grid(columns: Int, maxCount: Int, height: CGFloat? = nil, aspectRatio: CGFloat? = nil, overlayTotal: Int? = nil) -> some View {
        let displayImages = Array(images.prefix(maxCount))
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns),
                         spacing: spacing) {
            ForEach(Array(displayImages.enumerated()), id: \.offset) { index, image in
                ZStack {
                    cell(image, height: height, aspectRatio: aspectRatio)
                    if let overlayTotal = overlayTotal, index == maxCount - 1 {
                        RoundedRectangle(cornerRadius: ExploreTheme.Radius.badge, style: .continuous)
                            .fill(Color.black.opacity(0.6))
                        Text("\(overlayTotal)")
                            .font(.headline.weight(.bold))
                            .monospacedDigit()
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }

    private func cell(_ image: ExploreImageViewState,
                      height: CGFloat? = nil,
                      aspectRatio: CGFloat? = nil,
                      cornerRadius: CGFloat = ExploreTheme.Radius.badge) -> some View {
        ExploreRemoteImage(image: image,
                           height: height,
                           aspectRatio: aspectRatio,
                           cornerRadius: cornerRadius,
                           accessibilityLabel: accessibilityLabel)
    }
}

// MARK: - 组件标题

struct ExploreComponentHeader: View {
    let title: String?

    var body: some View {
        if let title = title, !title.isEmpty {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                    .fill(ExploreTheme.Colors.brand)
                    .frame(width: 3, height: 16)
                Text(title)
                    .font(ExploreTheme.Fonts.sectionTitle)
                    .foregroundColor(ExploreTheme.Colors.textPrimary)
                Spacer()
            }
            .accessibilityElement(children: .combine)
        }
    }
}

// MARK: - 文章卡片

struct ExploreArticleCardView: View {
    let item: ExploreArticleCardViewState
    let action: (ExploreTargetViewState) -> Void

    var body: some View {
        Button(action: { action(item.target) }) {
            VStack(alignment: .leading, spacing: 12) {
                if let title = item.title, !title.isEmpty {
                    Text(title)
                        .font(ExploreTheme.Fonts.cardTitle)
                        .foregroundColor(ExploreTheme.Colors.textPrimary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let summary = item.summary, !summary.isEmpty {
                    Text(summary)
                        .font(ExploreTheme.Fonts.body)
                        .foregroundColor(ExploreTheme.Colors.textSecondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }

                if hasAuthorRow {
                    HStack(spacing: 8) {
                        if let avatar = item.authorAvatarURL {
                            ExploreAvatarView(url: avatar, size: 28)
                        }
                        if let author = item.authorName, !author.isEmpty {
                            Text(author)
                                .font(ExploreTheme.Fonts.secondary)
                                .foregroundColor(ExploreTheme.Colors.textSecondary)
                        }
                        Spacer()
                        if let displayAt = item.displayAt {
                            Text(displayDate(displayAt))
                                .font(ExploreTheme.Fonts.caption)
                                .monospacedDigit()
                                .foregroundColor(ExploreTheme.Colors.textTertiary)
                        }
                    }
                }

                if let layout = item.imageLayout, !item.images.isEmpty {
                    ExploreMediaGrid(images: item.images,
                                     imageCount: item.imageCount,
                                     layout: layout,
                                     accessibilityLabel: item.title)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(ExploreCardButtonStyle())
        .exploreSurface()
        .accessibilityElement(children: .contain)
        .accessibilityHint(Text(L10n.explore_open_content))
    }

    private var hasAuthorRow: Bool {
        return item.authorName != nil || item.authorAvatarURL != nil || item.displayAt != nil
    }

    private func displayDate(_ date: Date) -> String {
        return ExploreArticleHTMLDocumentBuilder.formatDate(date, locale: .current)
    }
}

// MARK: - 专题详情文章行（CR-013 追加）

/// 专题详情文章列表的行状态：将卡片状态收敛为「左侧封面 + 右侧标题/摘要/作者」。
/// 纯数据，可在不依赖 SwiftUI 的情况下校验可见性与回退规则。
struct ExploreTopicArticleRowModel: Equatable {
    let thumbnail: ExploreImageViewState?
    let title: String?
    let summary: String?
    let authorName: String?
    let authorAvatarURL: URL?

    init(item: ExploreArticleCardViewState) {
        // 左侧封面取详情图集首图；首图不可用时不拿后续图顶替，避免图文错位
        if let first = item.images.first, first.isAvailable {
            thumbnail = first
        } else {
            thumbnail = nil
        }
        title = Self.nonEmpty(item.title)
        summary = Self.nonEmpty(item.summary)
        authorName = Self.nonEmpty(item.authorName)
        authorAvatarURL = item.authorAvatarURL
    }

    var showsThumbnail: Bool { thumbnail != nil }

    var showsAuthorRow: Bool { authorName != nil || authorAvatarURL != nil }

    private static func nonEmpty(_ text: String?) -> String? {
        guard let value = text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty else {
            return nil
        }
        return value
    }
}

/// 专题详情文章列表行：左封面（4:3 固定尺寸）+ 右侧标题/摘要/作者。
/// 右侧内容高度受缩略图高度约束，标题 1 行、摘要 2 行、作者贴底，避免行高被文字撞开。
struct ExploreTopicArticleRow: View {
    let item: ExploreArticleCardViewState
    let action: (ExploreTargetViewState) -> Void

    /// 左侧封面固定尺寸，右侧内容不得改变行高
    static let thumbnailWidth: CGFloat = 112
    static let thumbnailHeight: CGFloat = 84

    @Environment(\.sizeCategory) private var sizeCategory

    private var model: ExploreTopicArticleRowModel { ExploreTopicArticleRowModel(item: item) }

    /// 无封面或开启无障碍大字号时不钳制高度，避免文字被截断
    private var fixedContentHeight: CGFloat? {
        guard model.showsThumbnail, !sizeCategory.isAccessibilityCategory else { return nil }
        return Self.thumbnailHeight
    }

    var body: some View {
        Button(action: { action(item.target) }) {
            HStack(alignment: .top, spacing: 12) {
                if let thumbnail = model.thumbnail {
                    ExploreRemoteImage(image: thumbnail,
                                       height: Self.thumbnailHeight,
                                       cornerRadius: ExploreTheme.Radius.badge,
                                       accessibilityLabel: model.title)
                        .frame(width: Self.thumbnailWidth, height: Self.thumbnailHeight)
                        .clipped()
                }

                VStack(alignment: .leading, spacing: 4) {
                    if let title = model.title {
                        Text(title)
                            .font(ExploreTheme.Fonts.body.weight(.semibold))
                            .foregroundColor(ExploreTheme.Colors.textPrimary)
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                    }

                    if let summary = model.summary {
                        Text(summary)
                            .font(ExploreTheme.Fonts.secondary)
                            .foregroundColor(ExploreTheme.Colors.textSecondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }

                    // 作者行贴底：高度被钳制时 Spacer 吸收剩余空间
                    Spacer(minLength: 4)

                    if model.showsAuthorRow {
                        HStack(spacing: 6) {
                            if let avatar = model.authorAvatarURL {
                                ExploreAvatarView(url: avatar, size: 20)
                            }
                            if let author = model.authorName {
                                Text(author)
                                    .font(ExploreTheme.Fonts.caption)
                                    .foregroundColor(ExploreTheme.Colors.textSecondary)
                                    .lineLimit(1)
                            }
                            Spacer(minLength: 0)
                        }
                    }
                }
                .frame(maxWidth: .infinity,
                       minHeight: model.showsThumbnail ? Self.thumbnailHeight : 0,
                       alignment: .topLeading)
                .frame(height: fixedContentHeight, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(ExploreCardButtonStyle())
        .exploreSurface()
        .accessibilityElement(children: .contain)
        .accessibilityHint(Text(L10n.explore_open_content))
    }
}

// MARK: - 专题详情顶部媒体（CR-013 追加）

/// 专题详情顶部图集：单图直显，多图改为手动横向轮播（不自动播放）。
/// 不再按 `imageLayout` 平铺，分页、刷新仍由 ViewState 驱动。
struct ExploreMediaCarousel: View {
    let images: [ExploreImageViewState]
    var accessibilityLabel: String?

    @State private var currentIndex = 0

    var body: some View {
        if images.count == 1, let image = images.first {
            slide(image)
        } else if images.count > 1 {
            ZStack(alignment: .bottomLeading) {
                TabView(selection: $currentIndex) {
                    ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                        slide(image)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: ExploreTheme.Layout.heroHeight)
                .clipShape(RoundedRectangle(cornerRadius: ExploreTheme.Radius.panel, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: ExploreTheme.Radius.panel, style: .continuous)
                        .strokeBorder(ExploreTheme.Colors.border, lineWidth: 1)
                )

                indicators
            }
            .onChange(of: images.count) { count in
                if currentIndex >= count {
                    currentIndex = 0
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityValue(Text("\(min(currentIndex + 1, images.count))/\(images.count)"))
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment:
                    currentIndex = min(currentIndex + 1, images.count - 1)
                case .decrement:
                    currentIndex = max(currentIndex - 1, 0)
                @unknown default:
                    break
                }
            }
        }
    }

    @ViewBuilder
    private func slide(_ image: ExploreImageViewState) -> some View {
        ExploreRemoteImage(image: image,
                           height: ExploreTheme.Layout.heroHeight,
                           cornerRadius: ExploreTheme.Radius.panel,
                           accessibilityLabel: accessibilityLabel)
            .overlay(
                RoundedRectangle(cornerRadius: ExploreTheme.Radius.panel, style: .continuous)
                    .strokeBorder(ExploreTheme.Colors.border, lineWidth: 1)
            )
    }

    private var indicators: some View {
        HStack(spacing: 6) {
            ForEach(0..<images.count, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex ? ExploreTheme.Colors.brand : Color.white.opacity(0.35))
                    .frame(width: index == currentIndex ? 18 : 6, height: 4)
                    .animation(.spring(), value: currentIndex)
            }
        }
        .padding(.leading, 16)
        .padding(.bottom, 12)
    }
}

#if DEBUG
struct ExploreCardViews_Previews: PreviewProvider {

    private static func image(_ index: Int?) -> ExploreImageViewState {
        let url = index.flatMap { URL(string: "https://example.com/\($0).png") }
        return ExploreImageViewState(url: url, width: 640, height: 480, mime: "image/png", size: 1024)
    }

    private static let layouts: [(ExploreImageLayout, Int)] = [
        (.single, 1),
        (.twoColumns, 2),
        (.oneLargeTwoSmall, 3),
        (.twoByTwo, 4),
        (.threeColumns, 9),
        (.nineGridWithCount, 12),
        (.single, 1)
    ]

    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                ExploreComponentHeader(title: "组件标题")
                ForEach(Array(layouts.enumerated()), id: \.offset) { pair in
                    let index = pair.offset
                    let entry = pair.element
                    let images = (1...max(entry.1, 1)).map { image($0) }
                    ExploreMediaGrid(images: index == layouts.count - 1 ? [image(nil)] : images,
                                     imageCount: entry.1,
                                     layout: entry.0,
                                     accessibilityLabel: "预览")
                }
                // 专题详情顶部：多图轮播（CR-013 追加）
                ExploreMediaCarousel(images: [image(1), image(2), image(3)],
                                          accessibilityLabel: "专题图集预览")

                // 专题详情文章行：固定左图 + 右文（CR-013 追加）
                ExploreTopicArticleRow(
                    item: ExploreArticleCardViewState(
                        id: "preview-row",
                        sortNo: 1,
                        title: "开源汽车——旅途的最佳伴侣与长途自驾体验分享",
                        summary: "趁春节假期，一家四口回了趟四川老家，沿途体验了智能驾驶与户外露营装备的实际表现。",
                        authorName: "hwyz_leo",
                        authorAvatarURL: nil,
                        displayAt: Date(),
                        images: [image(1), image(2)],
                        imageCount: 2,
                        imageLayout: .twoColumns,
                        target: .invalid
                    ),
                    action: { _ in }
                )

                ExploreArticleCardView(
                    item: ExploreArticleCardViewState(
                        id: "preview",
                        sortNo: 1,
                        title: "开源汽车——旅途的最佳伴侣",
                        summary: "趁春节假期，一家四口回了趟四川老家。",
                        authorName: "hwyz_leo",
                        authorAvatarURL: nil,
                        displayAt: Date(),
                        images: [image(1), image(2), image(3), image(4)],
                        imageCount: 4,
                        imageLayout: .twoByTwo,
                        target: .invalid
                    ),
                    action: { _ in }
                )
            }
            .padding()
        }
        .background(ExploreTheme.Colors.background)
        .preferredColorScheme(.dark)
        .environment(\.sizeCategory, .accessibilityExtraLarge)
    }
}
#endif
