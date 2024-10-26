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
    var displayLicenseAreaList: [LicenseArea] { get }
    var selectLicenseCityName: String { get }
    var selectLicenseCityCode: String { get }
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
    /// 显示省市列表
    func displayProvince(licenseAreaList: [LicenseArea])
    /// 显示省市下级列表
    func displayCity(provinceCode: String)
}

// MARK: - Route

protocol VehicleOrderDetailModelRouterProtocol: MviModelRouterProtocol {
    /// 跳转至首页
    func routeToMarketingIndex()
    /// 跳转至车型配置页
    func routeToModelConfig()
    /// 跳转至销售区域页
    func routeToLicenseArea()
}
