//
//  CommunityTopicModelProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

// MARK: - View State

protocol CommunityTopicModelStateProtocol {
    var contentState: CommunityTopicTypes.Model.ContentState { get }
    var routerSubject: CommunityTopicRouter.Subjects { get }
    var topic: Topic { get }
}

// MARK: - Intent Action

protocol CommunityTopicModelActionProtocol: MviModelActionProtocol {
    /// 更新页面内容
    func updateContent(topic: Topic)
}

// MARK: - Route

protocol CommunityTopicModelRouterProtocol: MviModelRouterProtocol {
    /// 跳转至文章页
    func routeToArticle()
    /// 跳转至话题页
    func routeToSubject()
    /// 跳转至专题页
    func routeToTopic()
}

