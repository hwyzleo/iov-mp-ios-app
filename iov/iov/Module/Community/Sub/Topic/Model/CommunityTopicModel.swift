//
//  CommunityTopicModel.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

final class CommunityTopicModel: ObservableObject, CommunityTopicModelStateProtocol {
    @Published private(set) var contentState: CommunityTopicTypes.Model.ContentState = .loading
    @Published private(set) var topic: ExploreTopicDetailViewState?
    @Published private(set) var isLoadingMore = false
    @Published private(set) var presentationError: ExploreFailure?

    let routerSubject = CommunityTopicRouter.Subjects()
}

// MARK: - Action Protocol

extension CommunityTopicModel: CommunityTopicModelActionProtocol {
    func displayLoading() {
        if topic == nil {
            contentState = .loading
        }
    }

    func displayError(text: String) {
        contentState = .error(.unknown)
    }

    func updateTopic(_ topic: ExploreTopicDetailViewState) {
        self.topic = topic
        contentState = .content
        isLoadingMore = false
        presentationError = nil
    }

    func appendTopicPage(_ page: ExploreTopicDetailViewState) {
        isLoadingMore = false
        guard let current = topic,
              current.topicId == page.topicId,
              current.revisionId == page.revisionId else {
            return
        }
        var seen = Set(current.items.map(\.id))
        var merged = current.items
        for item in page.items where !seen.contains(item.id) {
            seen.insert(item.id)
            merged.append(item)
        }
        topic = ExploreTopicDetailViewState(
            topicId: current.topicId,
            revisionId: current.revisionId,
            name: current.name,
            summary: current.summary,
            cover: current.cover,
            images: current.images,
            imageCount: current.imageCount,
            imageLayout: current.imageLayout,
            items: merged,
            hasMore: page.hasMore,
            nextCursor: page.nextCursor
        )
        contentState = .content
        presentationError = nil
    }

    func displayTopicError(_ failure: ExploreFailure) {
        if topic != nil {
            presentationError = failure
            isLoadingMore = false
        } else {
            contentState = .error(failure)
        }
    }

    func beginLoadMore() {
        isLoadingMore = true
        presentationError = nil
    }

    func setPresentationError(_ failure: ExploreFailure?) {
        presentationError = failure
    }
}

// MARK: - Route

extension CommunityTopicModel: CommunityTopicModelRouterProtocol {
    func closeScreen() {}

    func routeToArticle(ref: ArticleRevisionRef) {
        routerSubject.screen.send(.article(articleId: ref.articleId, revisionId: ref.revisionId))
    }

    func routeToTopic(ref: TopicRevisionRef) {
        routerSubject.screen.send(.topic(topicId: ref.topicId, revisionId: ref.revisionId))
    }

    func routeToWeb(url: URL) {
        routerSubject.screen.send(.web(url))
    }

    func routeToNative(_ destination: ExploreNativeDestination) {
        switch destination {
        case let .orderDetail(orderNo):
            routerSubject.screen.send(.nativeOrderDetail(orderNo: orderNo))
        }
    }
}
