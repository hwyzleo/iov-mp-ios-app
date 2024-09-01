//
//  ServiceModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class ServiceModel: ObservableObject, ServiceModelStateProtocol {
    @Published var contentState: ServiceTypes.Model.ContentState = .content
    let routerSubject = ServiceRouter.Subjects()
    var contentBlocks: [ContentBlock] = []
}

// MARK: - Action Protocol

extension ServiceModel: ServiceModelActionProtocol {
    func displayLoading() {
        contentState = .loading
    }
    func updateContent(contentBlocks: [ContentBlock]) {
        self.contentBlocks = contentBlocks
        contentState = .content
    }
    func displayError(text: String) {
        contentState = .error(text: text)
    }
}

// MARK: - Route

extension ServiceModel: ServiceModelRouterProtocol {
    func closeScreen() {}
    func routeToArticle() {
        routerSubject.screen.send(.article)
    }
    func routeToSubject() {
        routerSubject.screen.send(.subject)
    }
    func routeToTopic() {
        routerSubject.screen.send(.topic)
    }
}

extension ServiceTypes.Model {
    enum ContentState {
        case loading
        case content
        case error(text: String)
    }
}
