//
//  CommunityPage_Article.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

extension CommunityPage {
    /// CMS `ARTICLE_FEED`：每个组件独立游标分页
    struct ArticleFeed: View {
        let componentId: String
        let state: ExploreArticleFeedComponentViewState
        let isLoadingMore: Bool
        let action: (ExploreTargetViewState) -> Void
        let loadMore: () -> Void

        var body: some View {
            VStack(spacing: 12) {
                ForEach(state.items) { item in
                    ExploreArticleCardView(item: item, action: action)
                }

                if state.hasMore {
                    if isLoadingMore {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(ExploreTheme.Colors.brand)
                            .padding(.vertical, 12)
                    } else {
                        Button(action: loadMore) {
                            Text(L10n.explore_load_more)
                        }
                        .buttonStyle(ExploreSecondaryButtonStyle())
                    }
                }
            }
        }
    }
}
