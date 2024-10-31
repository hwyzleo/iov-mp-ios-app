//
//  VehicleWishlistModelProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/13.
//

import SwiftUI

// MARK: - View State

protocol VehicleOrderDetailModelStateProtocol {
    var contentState: MarketingTypes.Model.VehicleOrderDetailContentState { get }
    var routerSubject: MarketingRouter.Subjects { get }
    var saleModelImages: [String] { get }
    var saleModelName: String { get }
    var saleModelPrice: Decimal { get }
    var saleSpareTireName: String { get }
    var saleSpareTirePrice: Decimal { get }
    var saleExteriorName: String { get }
    var saleExteriorPrice: Decimal { get }
    var saleWheelName: String { get }
    var saleWheelPrice: Decimal { get }
    var saleInteriorName: String { get }
    var saleInteriorPrice: Decimal { get }
    var saleAdasName: String { get }
    var saleAdasPrice: Decimal { get }
    var totalPrice: Decimal { get }
    var saleModelDesc: String { get }
    var selectBookMethod: String { get }
    var purchaseBenefitsIntro: String { get }
    var downPayment: Bool { get }
    var downPaymentPrice: Decimal { get }
    var earnestMoney: Bool { get }
    var earnestMoneyPrice: Decimal { get }
    var agreementIsChecked: Bool { get }
    var orderNum: String { get }
    var orderTime: Int64 { get }
    var selectLicenseCityName: String { get }
    var selectLicenseCityCode: String { get }
    var selectDealershipName: String { get }
    var selectDealershipCode: String { get }
    var selectDeliveryCenterName: String { get }
    var selectDeliveryCenterCode: String { get }
    var orderPersonType: Int { get }
    var purchasePlan: Int { get }
    var orderPersonName: String { get }
    var orderPersonIdType: Int { get }
    var orderPersonIdNum: String { get }
}

// MARK: - Intent Action

protocol VehicleOrderDetailModelActionProtocol: MviModelActionProtocol {
    /// 更新销售车型图片集
    func updateSaleModelImages(saleModelImages: [String])
    /// 更新销售车型简介
    func updateSaleModelIntro(saleModelName: String, saleModelDesc: String)
    /// 更新预定方式
    func updateBookMethod(downPayment: Bool, downPaymentPrice: Decimal, earnestMoney: Bool, earnestMoneyPrice: Decimal, purchaseDenefitsIntro: String)
    /// 更新销售车型价格
    func updateSaleModelPrice(saleModelName: String, saleModelPrice: Decimal, saleSpareTireName: String, saleSpareTirePrice: Decimal, saleExteriorName: String, saleExteriorPrice: Decimal, saleWheelName: String, saleWheelPrice: Decimal, saleInteriorName: String, saleInteriorPrice: Decimal, saleAdasName: String, saleAdasPrice: Decimal, totalPrice: Decimal)
    /// 更新选择预定方式
    func updateSelectBookMethod(bookMethod: String)
    /// 更新选择下单人员类型
    func updateSelectOrderPersonType(orderPersonType: Int)
    /// 更新下单人信息
    func updateOrderPerson(orderPersonType: Int, orderPersonName: String, orderPersonIdType: Int, orderPersonIdNum: String)
    /// 更新选择购车方案
    func updateSelectPurchasePlan(purchasePlan: Int)
    /// 更新购车方案
    func updatePurchasePlan(purchasePlan: Int)
    /// 更新订单
    func updateOrder(orderNum: String, orderTime: Int64)
    /// 切换订购协议
    func toggleAgreement()
    /// 显示心愿单
    func displayWishlist()
    /// 显示订购页
    func displayOrder()
    /// 显示意向金未支付页
    func displayEarnestMoneyUnpaid()
    /// 显示意向金已支付页
    func displayEarnestMoneyPaid()
    /// 显示定金未支付页
    func displayDownPaymentUnpaid()
    /// 显示定金已支付页
    func displayDownPaymentPaid()
    /// 显示安排生产页
    func displayArrangeProduction()
    /// 显示待运输页
    func displayPrepareTransport()
    /// 显示待交付页
    func displayPrepareDeliver()
    /// 显示已提车页
    func displayDelivered()
}

// MARK: - Route

protocol VehicleOrderDetailModelRouterProtocol: MviModelRouterProtocol {
    /// 跳转至首页
    func routeToMarketingIndex()
    /// 跳转至车型配置页
    func routeToModelConfig()
    /// 跳转至上牌区域页
    func routeToLicenseArea()
    /// 跳转至销售门店页
    func routeToDealership()
    /// 跳转至交付中心页
    func routeToDeliveryCenter()
}
