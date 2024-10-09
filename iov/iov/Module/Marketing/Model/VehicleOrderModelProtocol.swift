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
    var models: [SaleModel] { get }
    var selectModel: String { get }
    var spareTires: [SaleModel] { get }
    var selectSpareTire: String { get }
    var exteriors: [SaleModel] { get }
    var selectExterior: String { get }
    var wheels: [SaleModel] { get }
    var selectWheel: String { get }
    var interiors: [SaleModel] { get }
    var selectInterior: String { get }
    var optionals: [SaleModel] { get }
    var selectOptional: String { get }
    var totalPrice: Decimal { get }
}

// MARK: - Intent Action

protocol VehicleOrderModelActionProtocol: MviModelActionProtocol {
    /// 更新销售车型
    func updateSaleModel(saleModels: [SaleModel])
    /// 选择车型
    func selectModel(code: String, price: Decimal)
    /// 选择备胎
    func selectSpareTire(code: String, price: Decimal)
    /// 选择外观
    func selectExterior(code: String, price: Decimal)
    /// 选择车轮
    func selectWheel(code: String, price: Decimal)
    /// 选择内饰
    func selectInterior(code: String, price: Decimal)
    /// 保存订单信息
    func saveOrder(orderNum: String)
}

// MARK: - Route

protocol VehicleOrderModelRouterProtocol: MviModelRouterProtocol {

}
