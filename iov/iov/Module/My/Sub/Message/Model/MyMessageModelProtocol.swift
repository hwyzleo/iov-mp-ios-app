//
//  MyMessageModelProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import Foundation

// MARK: - View State

protocol MyMessageModelStateProtocol {
    var contentState: MyMessageTypes.Model.ContentState { get }
    var routerSubject: MyMessageRouter.Subjects { get }
}

// MARK: - Intent Action

protocol MyMessageModelActionProtocol: MviModelActionProtocol {

}

// MARK: - Route

protocol MyMessageModelRouterProtocol: MviModelRouterProtocol {
    
}
