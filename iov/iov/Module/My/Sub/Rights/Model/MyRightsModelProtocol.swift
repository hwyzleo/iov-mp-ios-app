//
//  MyRightsModelProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import Foundation

// MARK: - View State

protocol MyRightsModelStateProtocol {
    var contentState: MyRightsTypes.Model.ContentState { get }
    var routerSubject: MyRightsRouter.Subjects { get }
}

// MARK: - Intent Action

protocol MyRightsModelActionProtocol: MviModelActionProtocol {
}

// MARK: - Route

protocol MyRightsModelRouterProtocol: MviModelRouterProtocol {
}
