//
//  CommunityTopicView.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

struct CommunityTopicView: View {
    @StateObject var container: MviContainer<CommunityTopicIntentProtocol, CommunityTopicModelStateProtocol>
    private var intent: CommunityTopicIntentProtocol { container.intent }
    private var state: CommunityTopicModelStateProtocol { container.model }

    var body: some View {
        ZStack(alignment: .top) {
            switch state.contentState {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(ExploreTheme.Colors.brand)
                    .scaleEffect(1.6)
            case .content:
                if let topic = state.topic {
                    content(topic)
                }
            case let .error(failure):
                error(failure)
            }

            if let failure = state.presentationError {
                ExploreInlineErrorBanner(message: failure.localizedKey,
                                         canRetry: failure != .invalidTarget,
                                         onRetry: {
                                             if failure == .releaseChanged {
                                                 intent.retry()
                                             } else {
                                                 intent.loadMore()
                                             }
                                         },
                                         onDismiss: { intent.dismissPresentationError() })
                    .padding(.horizontal, ExploreTheme.Layout.margin)
                    .padding(.top, 56)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: state.presentationError)
        .background(ExploreTheme.Colors.background)
        .onAppear {
            intent.viewOnAppear()
        }
        .modifier(CommunityTopicRouter(
            subjects: state.routerSubject,
            intent: intent
        ))
    }

    @ViewBuilder
    private func content(_ topic: ExploreTopicDetailViewState) -> some View {
        VStack(spacing: 0) {
            // 顶部栏直接展示当前专题标题，不再固定「专题」
            if let name = topic.name, !name.isEmpty {
                TopBackTitleBar(title: name)
            } else {
                TopBackTitleBar(titleLocal: L10n.explore_topic_title)
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 专题详情顶部：单图直显，多图轮播（不再按 imageLayout 平铺）
                    if !topic.galleryImages.isEmpty {
                        ExploreMediaCarousel(images: topic.galleryImages,
                                             accessibilityLabel: topic.name)
                    }

                    let summary = topic.summary?.trimmingCharacters(in: .whitespacesAndNewlines)
                    if let summary = summary, !summary.isEmpty {
                        Text(summary)
                            .font(ExploreTheme.Fonts.body)
                            .foregroundColor(ExploreTheme.Colors.textSecondary)
                    }

                    // 摘要与文章列表之间增加行间距与分割线
                    if let summary = summary, !summary.isEmpty, !topic.items.isEmpty {
                        Rectangle()
                            .fill(ExploreTheme.Colors.border)
                            .frame(height: 1)
                            .padding(.top, 4)
                    }

                    ForEach(topic.items) { item in
                        ExploreTopicArticleRow(item: item,
                                              action: { intent.onTapItem(target: $0) })
                    }

                    if topic.hasMore {
                        if state.isLoadingMore {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(ExploreTheme.Colors.brand)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        } else {
                            Button(action: { intent.loadMore() }) {
                                Text(L10n.explore_load_more)
                            }
                            .buttonStyle(ExploreSecondaryButtonStyle())
                        }
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
    }

    private func error(_ failure: ExploreFailure) -> some View {
        VStack(spacing: 0) {
            TopBackTitleBar(titleLocal: L10n.explore_topic_title)
            ExploreStatusView(icon: "square.stack.3d.up",
                              message: failure.localizedKey,
                              actionTitle: L10n.explore_retry,
                              iconColor: ExploreTheme.Colors.warning,
                              action: { intent.retry() })
        }
        .exploreScreenBackground()
    }
}
