//
//  MyInviteModelProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import Foundation

// MARK: - View State

protocol MyInviteModelStateProtocol {
    var contentState: MyInviteTypes.Model.ContentState { get }
    var routerSubject: MyInviteRouter.Subjects { get }
}

// MARK: - Intent Action

protocol MyInviteModelActionProtocol: MviModelActionProtocol {
}

// MARK: - Route

protocol MyInviteModelRouterProtocol: MviModelRouterProtocol {
}
