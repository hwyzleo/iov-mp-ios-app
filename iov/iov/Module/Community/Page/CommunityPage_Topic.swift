//
//  CommunityPage_Topic.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

extension CommunityPage {
    /// CMS `TOPIC_GRID`：ADAPTIVE_GRID / HORIZONTAL_SCROLL / IMAGE_TEXT_LIST
    struct TopicGrid: View {
        let state: ExploreTopicGridComponentViewState
        let action: (ExploreTargetViewState) -> Void

        var body: some View {
            if state.items.isEmpty {
                EmptyView()
            } else {
                switch state.style {
                case let .adaptiveGrid(columns):
                    adaptiveGrid(columns: columns)
                case .horizontalScroll:
                    horizontalScroll
                case .imageTextList:
                    imageTextList
                }
            }
        }

        private func adaptiveGrid(columns: Int) -> some View {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: columns),
                      spacing: 16) {
                ForEach(state.items) { item in
                    Button(action: { action(item.target) }) {
                        VStack(alignment: .center, spacing: 8) {
                            ExploreRemoteImage(image: item.cover,
                                               height: nil,
                                               aspectRatio: 1,
                                               cornerRadius: ExploreTheme.Radius.badge,
                                               accessibilityLabel: item.name)
                            if let name = item.name, !name.isEmpty {
                                Text(name)
                                    .font(ExploreTheme.Fonts.secondary.weight(.medium))
                                    .foregroundColor(ExploreTheme.Colors.textPrimary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .buttonStyle(ExploreCardButtonStyle())
                    .exploreSurface(radius: ExploreTheme.Radius.card,
                                    padding: ExploreTheme.Layout.compactPadding)
                }
            }
        }

        private var horizontalScroll: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(state.items) { item in
                        Button(action: { action(item.target) }) {
                            VStack(alignment: .center, spacing: 8) {
                                ExploreRemoteImage(image: item.cover,
                                                   height: 120,
                                                   cornerRadius: ExploreTheme.Radius.badge,
                                                   accessibilityLabel: item.name)
                                    .frame(width: 134)
                                if let name = item.name, !name.isEmpty {
                                    Text(name)
                                        .font(ExploreTheme.Fonts.secondary.weight(.medium))
                                        .foregroundColor(ExploreTheme.Colors.textPrimary)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .frame(width: 134)
                        }
                        .buttonStyle(ExploreCardButtonStyle())
                        .exploreSurface(radius: ExploreTheme.Radius.card,
                                        padding: ExploreTheme.Layout.compactPadding)
                    }
                }
            }
        }

        private var imageTextList: some View {
            VStack(spacing: 12) {
                ForEach(state.items) { item in
                    Button(action: { action(item.target) }) {
                        HStack(alignment: .center, spacing: 12) {
                            ExploreRemoteImage(image: item.cover,
                                               height: nil,
                                               aspectRatio: 1,
                                               cornerRadius: ExploreTheme.Radius.badge,
                                               accessibilityLabel: item.name)
                                .frame(width: 80)
                            VStack(alignment: .leading, spacing: 6) {
                                if let name = item.name, !name.isEmpty {
                                    Text(name)
                                        .font(ExploreTheme.Fonts.secondary.weight(.medium))
                                        .foregroundColor(ExploreTheme.Colors.textPrimary)
                                        .lineLimit(2)
                                }
                                if let summary = item.summary, !summary.isEmpty {
                                    Text(summary)
                                        .font(ExploreTheme.Fonts.caption)
                                        .foregroundColor(ExploreTheme.Colors.textSecondary)
                                        .lineLimit(2)
                                }
                            }
                            Spacer(minLength: 0)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(ExploreTheme.Colors.textTertiary)
                        }
                    }
                    .buttonStyle(ExploreCardButtonStyle())
                    .exploreSurface(radius: ExploreTheme.Radius.card, padding: 12)
                }
            }
        }
    }
}

#if DEBUG
struct CommunityPage_TopicGrid_Previews: PreviewProvider {

    private static func item(_ id: String, _ name: String) -> ExploreTopicItemViewState {
        ExploreTopicItemViewState(
            id: id,
            topicId: id,
            name: name,
            summary: "专题摘要",
            cover: ExploreImageViewState(url: nil, width: nil, height: nil, mime: nil, size: nil),
            target: .invalid
        )
    }

    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                CommunityPage.TopicGrid(
                    state: ExploreTopicGridComponentViewState(
                        style: .adaptiveGrid(columns: 4),
                        items: (1...4).map { item("a\($0)", "自适应 \($0)") }
                    ),
                    action: { _ in }
                )
                CommunityPage.TopicGrid(
                    state: ExploreTopicGridComponentViewState(
                        style: .horizontalScroll,
                        items: (1...3).map { item("h\($0)", "横向 \($0)") }
                    ),
                    action: { _ in }
                )
                CommunityPage.TopicGrid(
                    state: ExploreTopicGridComponentViewState(
                        style: .imageTextList,
                        items: (1...2).map { item("l\($0)", "图文行 \($0)") }
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
