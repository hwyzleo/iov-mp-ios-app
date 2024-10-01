//
//  MyPointsModelProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import Foundation

// MARK: - View State

protocol MyPointsModelStateProtocol {
    var contentState: MyPointsTypes.Model.ContentState { get }
    var routerSubject: MyPointsRouter.Subjects { get }
}

// MARK: - Intent Action

protocol MyPointsModelActionProtocol: MviModelActionProtocol {
}

// MARK: - Route

protocol MyPointsModelRouterProtocol: MviModelRouterProtocol {
}
