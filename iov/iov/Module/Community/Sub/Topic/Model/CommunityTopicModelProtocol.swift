//
//  CommunityTopicModelProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

// MARK: - View State

protocol CommunityTopicModelStateProtocol: AnyObject {
    var contentState: CommunityTopicTypes.Model.ContentState { get }
    var topic: ExploreTopicDetailViewState? { get }
    var isLoadingMore: Bool { get }
    var presentationError: ExploreFailure? { get }
    var routerSubject: CommunityTopicRouter.Subjects { get }
}

// MARK: - Intent Action

protocol CommunityTopicModelActionProtocol: MviModelActionProtocol {
    func updateTopic(_ topic: ExploreTopicDetailViewState)
    func appendTopicPage(_ page: ExploreTopicDetailViewState)
    func displayTopicError(_ failure: ExploreFailure)
    func beginLoadMore()
    func setPresentationError(_ failure: ExploreFailure?)
}

// MARK: - Route

protocol CommunityTopicModelRouterProtocol: MviModelRouterProtocol {
    func routeToArticle(ref: ArticleRevisionRef)
    func routeToTopic(ref: TopicRevisionRef)
    func routeToWeb(url: URL)
    func routeToNative(_ destination: ExploreNativeDestination)
}
