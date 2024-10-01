//
//  CommunityTopicModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class CommunityTopicModel: ObservableObject, CommunityTopicModelStateProtocol {
    @Published var contentState: CommunityTopicTypes.Model.ContentState = .content
    let routerSubject = CommunityTopicRouter.Subjects()
    var topic: Topic = Topic.init(id: "", title: "", contents: [])
}

// MARK: - Action Protocol

extension CommunityTopicModel: CommunityTopicModelActionProtocol {
    func displayLoading() {
        contentState = .loading
    }
    func updateContent(topic: Topic) {
        self.topic = topic
        contentState = .content
    }
    func displayError(text: String) {
        contentState = .error(text: text)
    }
}

// MARK: - Route

extension CommunityTopicModel: CommunityTopicModelRouterProtocol {
    func closeScreen() {
        
    }
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

extension CommunityTopicTypes.Model {
    enum ContentState {
        case loading
        case content
        case error(text: String)
    }
}
