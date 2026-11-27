//
//  CommunityTopicIntent.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import Foundation

class CommunityTopicIntent: MviIntentProtocol {
    private weak var modelAction: CommunityTopicModelActionProtocol?
    private weak var modelRouter: CommunityTopicModelRouterProtocol?

    private let topicId: String
    private let revisionId: String
    private let service: ExploreServiceProtocol
    private let resolver: ExploreTargetResolver
    private weak var modelState: CommunityTopicModelStateProtocol?

    private var generation = 0
    private var isLoading = false
    private var isLoadingMore = false

    init(model: CommunityTopicModelActionProtocol & CommunityTopicModelRouterProtocol & CommunityTopicModelStateProtocol,
         topicId: String,
         revisionId: String,
         service: ExploreServiceProtocol = RealExploreService(),
         resolver: ExploreTargetResolver = ExploreTargetResolver()) {
        self.modelAction = model
        self.modelRouter = model
        self.topicId = topicId
        self.revisionId = revisionId
        self.service = service
        self.resolver = resolver
        self.modelState = model
    }

    func viewOnAppear() {
        guard !isLoading else { return }
        guard modelState?.topic == nil else { return }
        loadFirstPage()
    }
}

extension CommunityTopicIntent: CommunityTopicIntentProtocol {
    func loadMore() {
        guard let topic = currentTopic,
              topic.hasMore,
              let cursor = topic.nextCursor,
              !isLoadingMore else {
            return
        }
        guard topic.topicId == topicId, topic.revisionId == revisionId else { return }

        let currentGeneration = generation
        isLoadingMore = true
        modelAction?.beginLoadMore()

        service.loadTopicDetail(topicId: topicId,
                                revisionId: revisionId,
                                cursor: cursor,
                                pageSize: RealExploreService.defaultPageSize) { [weak self] result in
            guard let self = self else { return }
            self.onMain {
                guard currentGeneration == self.generation else { return }
                self.isLoadingMore = false
                guard let current = self.currentTopic,
                      current.topicId == self.topicId,
                      current.revisionId == self.revisionId else {
                    return
                }
                switch result {
                case let .success(page):
                    self.modelAction?.appendTopicPage(page)
                case let .failure(failure):
                    self.modelAction?.displayTopicError(failure)
                }
            }
        }
    }

    func retry() {
        loadFirstPage()
    }

    func dismissPresentationError() {
        modelAction?.setPresentationError(nil)
    }

    func onTapItem(target: ExploreTargetViewState) {
        switch resolver.resolve(target) {
        case let .success(.article(ref)):
            modelRouter?.routeToArticle(ref: ref)
        case let .success(.topic(ref)):
            modelRouter?.routeToTopic(ref: ref)
        case let .success(.web(url)):
            modelRouter?.routeToWeb(url: url)
        case let .success(.native(destination)):
            modelRouter?.routeToNative(destination)
        case .failure:
            modelAction?.setPresentationError(.invalidTarget)
        }
    }
}

private extension CommunityTopicIntent {
    var currentTopic: ExploreTopicDetailViewState? {
        return modelState?.topic
    }

    func loadFirstPage() {
        guard !topicId.isEmpty, !revisionId.isEmpty else {
            modelAction?.displayTopicError(.contentUnavailable)
            return
        }
        isLoading = true
        isLoadingMore = false
        generation += 1
        let currentGeneration = generation
        modelAction?.displayLoading()

        service.loadTopicDetail(topicId: topicId,
                                revisionId: revisionId,
                                cursor: nil,
                                pageSize: RealExploreService.defaultPageSize) { [weak self] result in
            guard let self = self else { return }
            self.onMain {
                guard currentGeneration == self.generation else { return }
                self.isLoading = false
                switch result {
                case let .success(topic):
                    self.modelAction?.updateTopic(topic)
                case let .failure(failure):
                    self.modelAction?.displayTopicError(failure)
                }
            }
        }
    }

    func onMain(_ action: @escaping () -> Void) {
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.async(execute: action)
        }
    }
}
