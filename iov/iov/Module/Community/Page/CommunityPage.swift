//
//  CommunityView.swift
//  IOV
//
//  Created by hwyz_leo on 2024/8/31.
//

import SwiftUI

struct CommunityPage: View {

    @StateObject var container: MviContainer<CommunityIntentProtocol, CommunityModelStateProtocol>
    private var intent: CommunityIntentProtocol { container.intent }
    private var state: CommunityModelStateProtocol { container.model }

    @State private var isRefreshing = false

    var body: some View {
        ZStack(alignment: .top) {
            switch state.contentState {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(ExploreTheme.Colors.brand)
                    .scaleEffect(1.6)
            case .content:
                ContentView(intent: intent, state: state, isRefreshing: $isRefreshing)
            case .empty:
                EmptyStateView(onRefresh: { intent.refresh() })
            case let .error(failure):
                ErrorStateView(failure: failure, onRetry: { intent.retry() })
            }

            if let error = state.presentationError {
                ExploreInlineErrorBanner(message: error.messageKey,
                                         canRetry: error.canRetry,
                                         onRetry: { intent.retryPresentationError() },
                                         onDismiss: { intent.dismissPresentationError() })
                    .padding(.horizontal, ExploreTheme.Layout.margin)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: state.presentationError)
        .background(ExploreTheme.Colors.background)
        .onChange(of: state.isRefreshing) { refreshing in
            isRefreshing = refreshing
        }
        .onAppear {
            intent.viewOnAppear()
        }
        .modifier(CommunityRouter(
            subjects: state.routerSubject,
            intent: intent
        ))
    }
}

// MARK: - 内容

extension CommunityPage {

    struct ContentView: View {
        let intent: CommunityIntentProtocol
        let state: CommunityModelStateProtocol
        @Binding var isRefreshing: Bool

        @State private var searchText = ""

        var body: some View {
            VStack(spacing: 0) {
                // 顶部搜索区（搜索执行不在本 CR 范围）
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(ExploreTheme.Colors.textTertiary)
                        TextField(LocalizedStringKey("search_explore_placeholder"), text: $searchText)
                            .font(ExploreTheme.Fonts.secondary)
                            .foregroundColor(ExploreTheme.Colors.textPrimary)
                            .tint(ExploreTheme.Colors.brand)
                    }
                    .padding(.horizontal, 14)
                    .frame(minHeight: 44)
                    .background(ExploreTheme.Colors.surface2)
                    .clipShape(RoundedRectangle(cornerRadius: ExploreTheme.Radius.card, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: ExploreTheme.Radius.card, style: .continuous)
                            .strokeBorder(ExploreTheme.Colors.border, lineWidth: 1)
                    )

                    Button(action: { /* 发布逻辑不在本 CR 范围 */ }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(ExploreTheme.Colors.brand)
                            .frame(width: 44, height: 44)
                            .background(ExploreTheme.Colors.surface2)
                            .clipShape(Circle())
                            .overlay(Circle().strokeBorder(ExploreTheme.Colors.border, lineWidth: 1))
                            .shadow(color: ExploreTheme.Colors.brand.opacity(0.22), radius: 6)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, ExploreTheme.Layout.margin)
                .padding(.top, 8)
                .padding(.bottom, 12)

                ChannelBar(channels: state.channels,
                           selectedChannelCode: state.selectedChannelCode,
                           onSelect: { intent.selectChannel(code: $0) })

                RefreshScrollView(offDown: CGFloat(state.page?.components.count ?? 0) * 220.0,
                                  listH: ScreenH - kNavHeight - kBottomSafeHeight - 100,
                                  refreshing: $isRefreshing,
                                  refreshTrigger: {
                                      isRefreshing = false
                                      intent.refresh()
                                  }) {
                    Content(intent: intent, state: state)
                }
                .scrollIndicators(.hidden)
            }
            .background(ExploreTheme.Colors.background)
        }
    }

    struct ChannelBar: View {
        let channels: [ExploreChannelViewState]
        let selectedChannelCode: String?
        let onSelect: (String) -> Void

        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 24) {
                    ForEach(channels) { channel in
                        let selected = channel.code == selectedChannelCode
                        Button(action: { onSelect(channel.code) }) {
                            VStack(spacing: 6) {
                                Text(channel.name)
                                    .font(selected ? .headline : .body)
                                    .foregroundColor(selected ? ExploreTheme.Colors.textPrimary : ExploreTheme.Colors.textSecondary)
                                Capsule()
                                    .fill(selected ? ExploreTheme.Colors.brand : Color.clear)
                                    .frame(width: 18, height: 3)
                                    .shadow(color: selected ? ExploreTheme.Colors.brand.opacity(0.55) : .clear, radius: 4)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(selected ? .isSelected : [])
                    }
                }
                .padding(.horizontal, ExploreTheme.Layout.margin)
                .padding(.bottom, 10)
                .animation(.easeInOut(duration: 0.18), value: selectedChannelCode)
            }
        }
    }

    struct Content: View {
        let intent: CommunityIntentProtocol
        let state: CommunityModelStateProtocol

        var body: some View {
            VStack(spacing: ExploreTheme.Layout.spacing) {
                if let page = state.page {
                    ForEach(page.components) { component in
                        VStack(alignment: .leading, spacing: 12) {
                            ExploreComponentHeader(title: component.title)

                            switch component.content {
                            case let .banner(banner):
                                CommunityPage.BannerCarousel(state: banner,
                                                             action: { intent.onTapItem(target: $0) })
                            case let .topicGrid(grid):
                                CommunityPage.TopicGrid(state: grid,
                                                        action: { intent.onTapItem(target: $0) })
                            case let .articleFeed(feed):
                                CommunityPage.ArticleFeed(
                                    componentId: component.id,
                                    state: feed,
                                    isLoadingMore: state.loadingMoreComponentIds.contains(component.id),
                                    action: { intent.onTapItem(target: $0) },
                                    loadMore: { intent.loadMore(componentId: component.id) }
                                )
                            case .unknown:
                                EmptyView()
                            }
                        }
                        .padding(.horizontal, ExploreTheme.Layout.margin)
                    }
                }

                Spacer()
                    .frame(height: 120)
            }
            .padding(.top, 16)
        }
    }
}

// MARK: - 状态视图

extension CommunityPage {

    struct EmptyStateView: View {
        let onRefresh: () -> Void

        var body: some View {
            ExploreStatusView(icon: "square.grid.2x2",
                              message: L10n.explore_empty_channels,
                              actionTitle: L10n.explore_refresh,
                              action: onRefresh)
        }
    }

    struct ErrorStateView: View {
        let failure: ExploreFailure
        let onRetry: () -> Void

        var body: some View {
            ExploreStatusView(icon: "exclamationmark.triangle",
                              message: failure.localizedKey,
                              actionTitle: L10n.explore_retry,
                              iconColor: ExploreTheme.Colors.warning,
                              action: onRetry)
        }
    }
}

// MARK: - Previews

#if DEBUG
struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        let page = ExplorePageViewState(
            schemaVersion: 1,
            channelCode: "recommend",
            channelName: "推荐",
            releaseId: "release-1",
            publishedAt: Date(),
            components: [
                ExploreComponentViewState(
                    id: "banner-1",
                    sortNo: 1,
                    title: nil,
                    content: .banner(ExploreBannerComponentViewState(
                        intervalSeconds: 5,
                        items: [
                            ExploreBannerItemViewState(id: "b1",
                                                       title: "尽享雪地之美",
                                                       image: ExploreImageViewState(url: nil,
                                                                                   width: nil,
                                                                                   height: nil,
                                                                                   mime: nil,
                                                                                   size: nil),
                                                       target: .invalid)
                        ]
                    ))
                ),
                ExploreComponentViewState(
                    id: "feed-1",
                    sortNo: 2,
                    title: "最新",
                    content: .articleFeed(ExploreArticleFeedComponentViewState(
                        items: [
                            ExploreArticleCardViewState(
                                id: "a1",
                                sortNo: 1,
                                title: "开源汽车——旅途的最佳伴侣",
                                summary: "趁春节假期，一家四口回了趟四川老家。",
                                authorName: "hwyz_leo",
                                authorAvatarURL: nil,
                                displayAt: Date(),
                                images: [],
                                imageCount: 0,
                                imageLayout: nil,
                                target: .invalid
                            )
                        ],
                        hasMore: false,
                        nextCursor: nil
                    ))
                )
            ]
        )
        let state = PreviewCommunityState(page: page)
        CommunityPage.Content(intent: PreviewCommunityIntent(), state: state)
            .background(ExploreTheme.Colors.background)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}

private final class PreviewCommunityState: CommunityModelStateProtocol {
    let channels: [ExploreChannelViewState] = [ExploreChannelViewState(code: "recommend", name: "推荐", sortNo: 1)]
    let selectedChannelCode: String? = "recommend"
    let contentState: ExploreContentState = .content
    let isRefreshing = false
    let page: ExplorePageViewState?
    let presentationError: ExplorePresentationError? = nil
    let loadingMoreComponentIds: Set<String> = []
    let routerSubject = CommunityRouter.Subjects()

    init(page: ExplorePageViewState?) {
        self.page = page
    }
}

private final class PreviewCommunityIntent: CommunityIntentProtocol {
    func viewOnAppear() {}
    func refresh() {}
    func retry() {}
    func selectChannel(code: String) {}
    func loadMore(componentId: String) {}
    func onTapItem(target: ExploreTargetViewState) {}
    func retryPresentationError() {}
    func dismissPresentationError() {}
}
#endif

#if DEBUG
struct CommunityPageState_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CommunityPage.EmptyStateView(onRefresh: {})
                .previewDisplayName("Empty")
            CommunityPage.ErrorStateView(failure: .serviceUnavailable, onRetry: {})
                .previewDisplayName("Error")
        }
        .preferredColorScheme(.dark)
        .environment(\.sizeCategory, .accessibilityExtraLarge)
    }
}
#endif
