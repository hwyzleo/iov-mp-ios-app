//
//  CommunityModelProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/8/31.
//

import SwiftUI

// MARK: - View State

protocol CommunityModelStateProtocol: AnyObject {
    var channels: [ExploreChannelViewState] { get }
    var selectedChannelCode: String? { get }
    var contentState: ExploreContentState { get }
    var isRefreshing: Bool { get }
    var page: ExplorePageViewState? { get }
    var presentationError: ExplorePresentationError? { get }
    var loadingMoreComponentIds: Set<String> { get }
    var routerSubject: CommunityRouter.Subjects { get }
}

// MARK: - Intent Action

protocol CommunityModelActionProtocol: MviModelActionProtocol {
    func beginInitialLoad()
    func beginRefresh()
    func beginChannelChange(code: String)
    func updateChannels(_ channels: [ExploreChannelViewState], selectedChannelCode: String?)
    func applyPage(_ page: ExplorePageViewState)
    func applyNotModified()
    func applyNoContent()
    func applyPageFailure(_ failure: ExploreFailure)
    func discardFeedPagination()

    func beginFeedLoad(componentId: String)
    func applyFeedPage(_ page: ExploreFeedPageViewState)
    func failFeedLoad(componentId: String, failure: ExploreFailure)
    func endFeedLoad(componentId: String)

    func setPresentationError(_ error: ExplorePresentationError?)
}

// MARK: - Route

protocol CommunityModelRouterProtocol: MviModelRouterProtocol {
    func routeToArticle(ref: ArticleRevisionRef)
    func routeToTopic(ref: TopicRevisionRef)
    func routeToWeb(url: URL)
    func routeToNative(_ destination: ExploreNativeDestination)
}
