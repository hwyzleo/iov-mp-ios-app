//
//  CommunityArticleModel.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

final class CommunityArticleModel: ObservableObject, CommunityArticleModelStateProtocol {
    @Published private(set) var contentState: CommunityArticleTypes.Model.ContentState = .loading
    let routerSubject = CommunityArticleRouter.Subjects()
}

// MARK: - Action Protocol

extension CommunityArticleModel: CommunityArticleModelActionProtocol {
    func displayLoading() {
        contentState = .loading
    }

    func displayError(text: String) {
        contentState = .error(.unknown)
    }

    func updateContent(_ detail: ExploreArticleDetailViewState) {
        contentState = .content(detail)
    }

    func displayUnavailable() {
        contentState = .unavailable
    }

    func displayError(_ failure: ExploreFailure) {
        contentState = .error(failure)
    }
}

// MARK: - Route

extension CommunityArticleModel: CommunityArticleModelRouterProtocol {
    func closeScreen() {}

    func routeToNative(_ destination: ExploreNativeDestination) {
        switch destination {
        case let .orderDetail(orderNo):
            routerSubject.screen.send(.nativeOrderDetail(orderNo: orderNo))
        }
    }
}
