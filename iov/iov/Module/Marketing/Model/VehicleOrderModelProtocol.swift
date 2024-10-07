//
//  VehicleModelProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

// MARK: - View State

protocol VehicleOrderModelStateProtocol {
    var contentState: MarketingTypes.Model.VehicleOrderContentState { get }
    var routerSubject: MarketingRouter.Subjects { get }
}

// MARK: - Intent Action

protocol VehicleOrderModelActionProtocol: MviModelActionProtocol {
    /// 保存订单信息
    func saveOrder(orderNum: String)
}

// MARK: - Route

protocol VehicleOrderModelRouterProtocol: MviModelRouterProtocol {

}
