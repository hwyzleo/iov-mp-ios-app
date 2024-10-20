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
    var hasOrder: Bool { get }
    var currentVehicleType: VehicleType { get }
    var orderState: OrderState { get }
    var saleModelImages: [String] { get }
    var totalPrice: Decimal { get }
    var saleModelDesc: String { get }
}

// MARK: - Intent Action

protocol MarketingIndexModelActionProtocol: MviModelActionProtocol {
    /// 显示没有订单的页面
    func displayNoOrder()
    /// 有订单的情况下显示心愿单
    func displayWishlist(wishlist: Wishlist)
    /// 有订单的情况下显示订单
    func displayOrder(order: OrderResponse)
    /// 显示车辆页
    func displayVehicle();
}

// MARK: - Route

protocol MarketingIndexModelRouterProtocol: MviModelRouterProtocol {
    /// 跳转至车型配置页
    func routeToModelConfig()
    /// 跳转至订单详情页
    func routeToOrderDetail()
    /// 跳转至登录页
    func routeToLogin()
}
