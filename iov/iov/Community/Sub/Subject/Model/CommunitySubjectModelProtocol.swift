//
//  CommunitySubjectModelProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

// MARK: - View State

protocol CommunitySubjectModelStateProtocol {
    var contentState: CommunitySubjectTypes.Model.ContentState { get }
    var routerSubject: CommunitySubjectRouter.Subjects { get }
    var subject: Subject { get }
}

// MARK: - Intent Action

protocol CommunitySubjectModelActionProtocol: MviModelActionProtocol {
    /// 更新页面内容
    func updateContent(subject: Subject)
}

// MARK: - Route

protocol CommunitySubjectModelRouterProtocol: MviModelRouterProtocol {
    /// 跳转至文章页
    func routeToArticle()
    /// 跳转至话题页
    func routeToSubject()
    /// 跳转至专题页
    func routeToTopic()
}
