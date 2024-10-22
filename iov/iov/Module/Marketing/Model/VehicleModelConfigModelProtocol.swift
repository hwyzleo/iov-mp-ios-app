//
//  VehicleModelProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

// MARK: - View State

protocol VehicleModelConfigModelStateProtocol {
    var contentState: MarketingTypes.Model.VehicleModelConfigContentState { get }
    var routerSubject: MarketingRouter.Subjects { get }
    var saleCode: String { get }
    var models: [SaleModelConfig] { get }
    var selectModel: String { get }
    var selectModelName: String { get }
    var spareTires: [SaleModelConfig] { get }
    var selectSpareTire: String { get }
    var exteriors: [SaleModelConfig] { get }
    var selectExterior: String { get }
    var wheels: [SaleModelConfig] { get }
    var selectWheel: String { get }
    var interiors: [SaleModelConfig] { get }
    var selectInterior: String { get }
    var adases: [SaleModelConfig] { get }
    var selectAdas: String { get }
    var totalPrice: Decimal { get }
}

// MARK: - Intent Action

protocol VehicleModelConfigModelActionProtocol: MviModelActionProtocol {
    /// 更新销售车型
    func updateSaleModel(saleCode: String, saleModels: [SaleModelConfig])
    /// 选择车型
    func selectModel(code: String, name: String, price: Decimal)
    /// 选择备胎
    func selectSpareTire(code: String, price: Decimal)
    /// 选择外观
    func selectExterior(code: String, price: Decimal)
    /// 选择车轮
    func selectWheel(code: String, price: Decimal)
    /// 选择内饰
    func selectInterior(code: String, price: Decimal)
    /// 选择智驾
    func selectAdas(code: String, price: Decimal)
    /// 保存订单信息
    func saveOrder(orderNum: String)
}

// MARK: - Route

protocol VehicleModelConfigModelRouterProtocol: MviModelRouterProtocol {
    /// 跳转至订单详情页
    func routeToOrderDetail()
}
