//
//  CommunityModel.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

final class CommunityModel: ObservableObject, CommunityModelStateProtocol {
    @Published private(set) var channels: [ExploreChannelViewState] = []
    @Published private(set) var selectedChannelCode: String?
    @Published private(set) var contentState: ExploreContentState = .loading
    @Published private(set) var isRefreshing = false
    @Published private(set) var page: ExplorePageViewState?
    @Published private(set) var presentationError: ExplorePresentationError?
    @Published private(set) var loadingMoreComponentIds: Set<String> = []

    let routerSubject = CommunityRouter.Subjects()
}

// MARK: - Action Protocol

extension CommunityModel: CommunityModelActionProtocol {

    func displayLoading() {
        if page == nil {
            contentState = .loading
        }
    }

    func displayError(text: String) {
        contentState = .error(.unknown)
    }

    func beginInitialLoad() {
        presentationError = nil
        isRefreshing = false
        if page == nil {
            contentState = .loading
        }
    }

    func beginRefresh() {
        presentationError = nil
        isRefreshing = true
        loadingMoreComponentIds.removeAll()
        if page == nil {
            contentState = .loading
        }
    }

    func beginChannelChange(code: String) {
        selectedChannelCode = code
        page = nil
        contentState = .loading
        isRefreshing = false
        presentationError = nil
        loadingMoreComponentIds.removeAll()
    }

    func updateChannels(_ channels: [ExploreChannelViewState], selectedChannelCode: String?) {
        self.channels = channels
        guard !channels.isEmpty else {
            self.selectedChannelCode = nil
            self.page = nil
            self.contentState = .empty
            self.isRefreshing = false
            return
        }
        if let selectedChannelCode = selectedChannelCode,
           channels.contains(where: { $0.code == selectedChannelCode }) {
            self.selectedChannelCode = selectedChannelCode
        } else {
            self.selectedChannelCode = channels.first?.code
        }
    }

    func applyPage(_ page: ExplorePageViewState) {
        self.page = page
        selectedChannelCode = page.channelCode
        contentState = page.hasRenderableComponent ? .content : .empty
        isRefreshing = false
        presentationError = nil
        loadingMoreComponentIds.removeAll()
    }

    func applyNotModified() {
        isRefreshing = false
        if page == nil {
            contentState = .empty
        }
    }

    func applyNoContent() {
        page = nil
        contentState = .empty
        isRefreshing = false
        presentationError = nil
        loadingMoreComponentIds.removeAll()
    }

    func applyPageFailure(_ failure: ExploreFailure) {
        isRefreshing = false
        loadingMoreComponentIds.removeAll()
        if page != nil {
            presentationError = .refresh(failure)
        } else {
            contentState = .error(failure)
        }
    }

    func discardFeedPagination() {
        guard let current = page else { return }
        let components = current.components.map { component -> ExploreComponentViewState in
            guard case let .articleFeed(feed) = component.content else { return component }
            let reset = ExploreArticleFeedComponentViewState(items: feed.items,
                                                             hasMore: false,
                                                             nextCursor: nil)
            return ExploreComponentViewState(id: component.id,
                                             sortNo: component.sortNo,
                                             title: component.title,
                                             content: .articleFeed(reset))
        }
        page = ExplorePageViewState(schemaVersion: current.schemaVersion,
                                    channelCode: current.channelCode,
                                    channelName: current.channelName,
                                    releaseId: current.releaseId,
                                    publishedAt: current.publishedAt,
                                    components: components)
        loadingMoreComponentIds.removeAll()
    }

    func beginFeedLoad(componentId: String) {
        loadingMoreComponentIds.insert(componentId)
    }

    func applyFeedPage(_ page: ExploreFeedPageViewState) {
        loadingMoreComponentIds.remove(page.componentId)
        guard let current = self.page, current.releaseId == page.releaseId else { return }
        guard let index = current.components.firstIndex(where: { $0.id == page.componentId }),
              case let .articleFeed(feed) = current.components[index].content else {
            return
        }

        var seen = Set(feed.items.map(\.id))
        var merged = feed.items
        for item in page.items where !seen.contains(item.id) {
            seen.insert(item.id)
            merged.append(item)
        }

        var components = current.components
        components[index] = ExploreComponentViewState(
            id: components[index].id,
            sortNo: components[index].sortNo,
            title: components[index].title,
            content: .articleFeed(ExploreArticleFeedComponentViewState(
                items: merged,
                hasMore: page.hasMore,
                nextCursor: page.nextCursor
            ))
        )
        self.page = ExplorePageViewState(schemaVersion: current.schemaVersion,
                                         channelCode: current.channelCode,
                                         channelName: current.channelName,
                                         releaseId: current.releaseId,
                                         publishedAt: current.publishedAt,
                                         components: components)
    }

    func failFeedLoad(componentId: String, failure: ExploreFailure) {
        loadingMoreComponentIds.remove(componentId)
        presentationError = .feed(componentId: componentId, failure: failure)
    }

    func endFeedLoad(componentId: String) {
        loadingMoreComponentIds.remove(componentId)
    }

    func setPresentationError(_ error: ExplorePresentationError?) {
        presentationError = error
    }
}

// MARK: - Route

extension CommunityModel: CommunityModelRouterProtocol {
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
