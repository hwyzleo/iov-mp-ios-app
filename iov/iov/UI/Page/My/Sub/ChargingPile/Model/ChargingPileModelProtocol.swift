//
//  ChargingPileModelProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import Foundation

// MARK: - View State

protocol ChargingPileModelStateProtocol {
    var contentState: ChargingPileTypes.Model.ContentState { get }
    var routerSubject: ChargingPileRouter.Subjects { get }
}

// MARK: - Intent Action

protocol ChargingPileModelActionProtocol: MviModelActionProtocol {
}

// MARK: - Route

protocol ChargingPileModelRouterProtocol: MviModelRouterProtocol {
}
