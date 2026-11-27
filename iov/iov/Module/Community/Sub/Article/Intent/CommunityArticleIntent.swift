//
//  CommunityArticleIntent.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import Foundation

class CommunityArticleIntent: MviIntentProtocol {
    private weak var modelAction: CommunityArticleModelActionProtocol?
    private weak var modelRouter: CommunityArticleModelRouterProtocol?

    private let articleId: String
    private let revisionId: String
    private let service: ExploreServiceProtocol
    private let resolver: ExploreTargetResolver

    private var generation = 0
    private var isLoading = false
    private var didLoad = false

    init(model: CommunityArticleModelActionProtocol & CommunityArticleModelRouterProtocol,
         articleId: String,
         revisionId: String,
         service: ExploreServiceProtocol = RealExploreService(),
         resolver: ExploreTargetResolver = ExploreTargetResolver()) {
        self.modelAction = model
        self.modelRouter = model
        self.articleId = articleId
        self.revisionId = revisionId
        self.service = service
        self.resolver = resolver
    }

    func viewOnAppear() {
        guard !didLoad else { return }
        didLoad = true
        load()
    }
}

extension CommunityArticleIntent: CommunityArticleIntentProtocol {
    func retry() {
        load()
    }
}

private extension CommunityArticleIntent {
    func load() {
        guard !isLoading else { return }
        guard !articleId.isEmpty, !revisionId.isEmpty else {
            modelAction?.displayUnavailable()
            return
        }

        isLoading = true
        generation += 1
        let currentGeneration = generation
        modelAction?.displayLoading()

        service.loadArticleDetail(articleId: articleId, revisionId: revisionId) { [weak self] result in
            guard let self = self else { return }
            self.onMain {
                guard currentGeneration == self.generation else { return }
                self.isLoading = false

                switch result {
                case let .success(detail):
                    switch detail.body {
                    case .officialHTML:
                        self.modelAction?.updateContent(detail)
                    case let .ugcReference(_, nativeRouteCode):
                        guard let routeCode = nativeRouteCode, !routeCode.isEmpty else {
                            self.modelAction?.displayUnavailable()
                            return
                        }
                        switch self.resolver.resolve(.native(routeCode: routeCode, params: [:])) {
                        case let .success(.native(destination)):
                            self.modelAction?.updateContent(detail)
                            self.modelRouter?.routeToNative(destination)
                        case .success, .failure:
                            self.modelAction?.displayUnavailable()
                        }
                    }
                case let .failure(failure):
                    if failure == .contentUnavailable || failure == .noContent {
                        self.modelAction?.displayUnavailable()
                    } else {
                        self.modelAction?.displayError(failure)
                    }
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
