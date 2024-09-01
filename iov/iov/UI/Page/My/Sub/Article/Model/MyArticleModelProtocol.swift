//
//  MyArticleModelProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import Foundation

// MARK: - View State

protocol MyArticleModelStateProtocol {
    var contentState: MyArticleTypes.Model.ContentState { get }
    var routerSubject: MyArticleRouter.Subjects { get }
}

// MARK: - Intent Action

protocol MyArticleModelActionProtocol: MviModelActionProtocol {
}

// MARK: - Route

protocol MyArticleModelRouterProtocol: MviModelRouterProtocol {
}
