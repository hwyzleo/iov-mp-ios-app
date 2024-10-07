//
//  VehicleModelProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

// MARK: - View State

protocol MarketingIndexModelStateProtocol {
    var contentState: MarketingTypes.Model.MarketingIndexContentState { get }
    var routerSubject: MarketingRouter.Subjects { get }
}

// MARK: - Intent Action

protocol MarketingIndexModelActionProtocol: MviModelActionProtocol {

}

// MARK: - Route

protocol MarketingIndexModelRouterProtocol: MviModelRouterProtocol {
    /// 跳转至车辆订购页
    func routeToOrder()
    /// 跳转至登录页
    func routeToLogin()
}
