//
//  MyOrderModelProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import Foundation

// MARK: - View State

protocol MyOrderModelStateProtocol {
    var contentState: MyOrderTypes.Model.ContentState { get }
    var routerSubject: MyOrderRouter.Subjects { get }
}

// MARK: - Intent Action

protocol MyOrderModelActionProtocol: MviModelActionProtocol {
}

// MARK: - Route

protocol MyOrderModelRouterProtocol: MviModelRouterProtocol {
}
