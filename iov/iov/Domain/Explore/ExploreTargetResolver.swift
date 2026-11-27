//
//  ExploreTargetResolver.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-012 on 2026/11/26.
//

import Foundation

/// 类型化路由命令：View 不得自行决定业务跳转。
enum ExploreRouteCommand: Equatable {
    case article(ArticleRevisionRef)
    case topic(TopicRevisionRef)
    case web(URL)
    case native(ExploreNativeDestination)
}

/// 纯逻辑目标解析器：只有明确合法的目标才会生成路由命令。
struct ExploreTargetResolver {

    private let nativeRegistry: ExploreNativeRouteRegistry

    init(nativeRegistry: ExploreNativeRouteRegistry = .production) {
        self.nativeRegistry = nativeRegistry
    }

    func resolve(_ target: ExploreTargetViewState) -> Result<ExploreRouteCommand, ExploreTargetResolutionError> {
        switch target {
        case let .article(ref):
            guard !ref.articleId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !ref.revisionId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return .failure(.unavailable)
            }
            return .success(.article(ref))
        case let .topic(ref):
            guard !ref.topicId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !ref.revisionId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return .failure(.unavailable)
            }
            return .success(.topic(ref))
        case let .h5(url):
            guard ExploreWebPolicy.isAllowedH5URL(url) else {
                return .failure(.insecureURL)
            }
            return .success(.web(url))
        case let .native(routeCode, params):
            switch nativeRegistry.resolve(routeCode: routeCode, params: params) {
            case let .success(destination):
                return .success(.native(destination))
            case let .failure(error):
                return .failure(error)
            }
        case .invalid:
            return .failure(.unavailable)
        }
    }
}
