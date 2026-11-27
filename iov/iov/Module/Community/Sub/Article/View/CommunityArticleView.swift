//
//  CommunityArticleView.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

struct CommunityArticleView: View {
    @StateObject var container: MviContainer<CommunityArticleIntentProtocol, CommunityArticleModelStateProtocol>
    private var intent: CommunityArticleIntentProtocol { container.intent }
    private var state: CommunityArticleModelStateProtocol { container.model }

    /// 正文 WebView 自适应高度（嵌入外层 ScrollView）
    @State private var bodyHeight: CGFloat = 1

    var body: some View {
        ZStack {
            switch state.contentState {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(ExploreTheme.Colors.brand)
                    .scaleEffect(1.6)
            case let .content(detail):
                content(detail)
            case .unavailable:
                unavailable
            case let .error(failure):
                error(failure)
            }
        }
        .background(ExploreTheme.Colors.background)
        .onAppear {
            intent.viewOnAppear()
        }
        .modifier(CommunityArticleRouter(
            subjects: state.routerSubject,
            intent: intent
        ))
    }

    @ViewBuilder
    private func content(_ detail: ExploreArticleDetailViewState) -> some View {
        if let html = ExploreArticleHTMLDocumentBuilder.makeDocument(detail) {
            VStack(spacing: 0) {
                TopBackTitleBar(title: displayTitle(detail))
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // 1. 文章图集轮播（无可用图时整块省略）
                        if !detail.galleryImages.isEmpty {
                            ExploreMediaCarousel(images: detail.galleryImages,
                                                 accessibilityLabel: detail.title)
                        }

                        // 2. 作者（头像可选，头头像居左）
                        if showsAuthorRow(detail) {
                            HStack(spacing: 8) {
                                if let avatar = detail.authorAvatarURL {
                                    ExploreAvatarView(url: avatar, size: 28)
                                }
                                if let author = trimmed(detail.authorName) {
                                    Text(author)
                                        .font(ExploreTheme.Fonts.secondary)
                                        .foregroundColor(ExploreTheme.Colors.textSecondary)
                                }
                                Spacer(minLength: 0)
                            }
                        }

                        // 3. 正文（官方已清洗 HTML，无脚本）
                        ExploreArticleHTMLView(html: html,
                                               isScrollEnabled: false,
                                               onContentHeightChange: { height in
                                                   guard abs(bodyHeight - height) > 0.5 else { return }
                                                   bodyHeight = height
                                               })
                            .frame(maxWidth: .infinity)
                            .frame(height: max(bodyHeight, 1))

                        // 4. 文章时间（页面最下方）
                        if let date = detail.displayAt {
                            Text(ExploreArticleHTMLDocumentBuilder.formatDate(date, locale: .current))
                                .font(ExploreTheme.Fonts.caption)
                                .monospacedDigit()
                                .foregroundColor(ExploreTheme.Colors.textTertiary)
                        }

                        Spacer()
                            .frame(height: 40)
                    }
                    .padding(.horizontal, ExploreTheme.Layout.margin)
                    .padding(.top, 12)
                }
                .scrollIndicators(.hidden)
            }
            .exploreScreenBackground()
        } else {
            unavailable
        }
    }

    private func displayTitle(_ detail: ExploreArticleDetailViewState) -> String {
        return trimmed(detail.title) ?? NSLocalizedString("explore_article_title", comment: "")
    }

    private func showsAuthorRow(_ detail: ExploreArticleDetailViewState) -> Bool {
        return detail.authorAvatarURL != nil || trimmed(detail.authorName) != nil
    }

    private func trimmed(_ text: String?) -> String? {
        guard let value = text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty else {
            return nil
        }
        return value
    }

    private var unavailable: some View {
        VStack(spacing: 0) {
            TopBackTitleBar(titleLocal: L10n.explore_article_title)
            ExploreStatusView(icon: "doc.text",
                              message: L10n.explore_article_unavailable,
                              actionTitle: L10n.explore_retry,
                              action: { intent.retry() })
        }
        .exploreScreenBackground()
    }

    private func error(_ failure: ExploreFailure) -> some View {
        VStack(spacing: 0) {
            TopBackTitleBar(titleLocal: L10n.explore_article_title)
            ExploreStatusView(icon: "exclamationmark.triangle",
                              message: failure.localizedKey,
                              actionTitle: L10n.explore_retry,
                              iconColor: ExploreTheme.Colors.warning,
                              action: { intent.retry() })
        }
        .exploreScreenBackground()
    }
}
