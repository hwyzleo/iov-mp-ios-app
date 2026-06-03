//
//  VehicleModelProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

// MARK: - View State

protocol MarketingIndexModelStateProtocol {
    var contentState: MarketingTypes.Model.MarketingIndexContentState { get }
    var hasOrder: Bool { get }
    var currentVehicleType: VehicleType { get }
    var orderState: OrderState { get }
    var saleModelImages: [String] { get }
    var totalPrice: Decimal { get }
    var saleModelDesc: String { get }
    var saleModelList: [SaleModelMp] { get }
    var selectedSaleModelIndex: Int { get }
}

// MARK: - Intent Action

protocol MarketingIndexModelActionProtocol: MviModelActionProtocol {
    /// 显示没有订单的页面
    func displayNoOrder()
    /// 使用 myVehicleList 数据直接显示车辆信息
    func displayMyVehicle(vehicle: MyVehicleVo)
    /// 显示车辆页
    func displayVehicle();
    func displaySaleModelList(saleModelList: [SaleModelMp])
    func selectSaleModel(index: Int)
    func getCurrentSaleModel() -> SaleModelMp?
}

// MARK: - Route

protocol MarketingIndexModelRouterProtocol: MviModelRouterProtocol {
    /// 跳转至车型版本选择页
    func routeToModelVariantSelection()
    /// 跳转至车型配置页
    func routeToModelConfig()
    /// 跳转至订单详情页
    func routeToOrderDetail()
    /// 跳转至登录页
    func routeToLogin()
}
