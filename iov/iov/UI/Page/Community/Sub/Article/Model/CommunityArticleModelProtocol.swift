//
//  CommunityArticleModelProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

// MARK: - View State

protocol CommunityArticleModelStateProtocol {
    var contentState: CommunityArticleTypes.Model.ContentState { get }
    var routerSubject: CommunityArticleRouter.Subjects { get }
    var article: Article { get }
}

// MARK: - Intent Action

protocol CommunityArticleModelActionProtocol: MviModelActionProtocol {
    /// 更新页面内容
    func updateContent(article: Article)
    /// 更新点赞效果
    func updateLike(liked: Bool)
}

// MARK: - Route

protocol CommunityArticleModelRouterProtocol: MviModelRouterProtocol {
    
}
