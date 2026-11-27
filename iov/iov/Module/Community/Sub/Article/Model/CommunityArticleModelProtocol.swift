//
//  CommunityArticleModelProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

// MARK: - View State

protocol CommunityArticleModelStateProtocol: AnyObject {
    var contentState: CommunityArticleTypes.Model.ContentState { get }
    var routerSubject: CommunityArticleRouter.Subjects { get }
}

// MARK: - Intent Action

protocol CommunityArticleModelActionProtocol: MviModelActionProtocol {
    func updateContent(_ detail: ExploreArticleDetailViewState)
    func displayUnavailable()
    func displayError(_ failure: ExploreFailure)
}

// MARK: - Route

protocol CommunityArticleModelRouterProtocol: MviModelRouterProtocol {
    func routeToNative(_ destination: ExploreNativeDestination)
}
