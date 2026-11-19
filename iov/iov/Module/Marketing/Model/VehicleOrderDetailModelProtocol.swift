//
//  VehicleWishlistModelProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/10/13.
//

import SwiftUI

// MARK: - View State

protocol VehicleOrderDetailModelStateProtocol {
    var contentState: MarketingTypes.Model.VehicleOrderDetailContentState { get }
    /// 终态标题（订单已失效/已取消/已关闭）
    var invalidTitle: String { get }
    /// 是否允许重新发起支付
    var canReopenPayment: Bool { get }
    var saleModelImages: [String] { get }
    var saleModelName: String { get }
    var saleModelPrice: Decimal { get }
    var dynamicConfigs: [(String, String, Decimal)] { get }
    var totalPrice: Decimal { get }
    var saleModelDesc: String { get }
    var selectBookMethod: String { get }
    var purchaseBenefitsIntro: String { get }
    var downPayment: Bool { get }
    var downPaymentPrice: Decimal { get }
    var earnestMoney: Bool { get }
    var earnestMoneyPrice: Decimal { get }
    var agreementIsChecked: Bool { get }
    var purchaseAgreements: [PurchaseAgreement] { get }
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
    var isFromEarnestMoneyConversion: Bool { get }

    // MARK: - 购车合同与尾款（OTD-VSO-DSN-CR-014）
    /// 订单状态（服务端权威值）
    var orderState: Int { get }
    /// 支付方式（full_payment / loan）
    var paymentMethod: String? { get }
    /// 合同状态（DRAFT/GENERATED/SIGNING/SIGNED/EFFECTIVE/INVALID，nil = 未签署）
    var contractStatus: String? { get }
    /// 合同签署页地址（仅 SIGNING 且为 http(s) 时存在）
    var contractWebUrl: URL? { get }
    /// 尾款金额（服务端金额快照）
    var tailPaymentAmount: Decimal { get }
    /// 合同请求进行中
    var contractBusy: Bool { get }
    /// 尾款支付请求进行中
    var tailPaymentBusy: Bool { get }
    /// 是否全款订单
    var isFullPayment: Bool { get }
    /// 合同是否已签署（SIGNED/EFFECTIVE）
    var isContractSigned: Bool { get }
    /// 合同是否签署中
    var isContractSigning: Bool { get }
    /// 是否可发起签署
    var canSignContract: Bool { get }
    /// 是否可支付尾款
    var canPayTailPayment: Bool { get }
}

// MARK: - Intent Action

protocol VehicleOrderDetailModelActionProtocol: MviModelActionProtocol {
    /// 获取当前内容状态
    func getContentState() -> MarketingTypes.Model.VehicleOrderDetailContentState
    /// 获取当前订单号（会话内）
    func getOrderNum() -> String
    /// 是否可发起合同签署
    func getCanSignContract() -> Bool
    /// 是否可支付尾款
    func getCanPayTailPayment() -> Bool
    /// 更新订单状态与支付方式（服务端权威值）
    func updateOrderState(orderState: Int, paymentMethod: String?)
    /// 更新合同状态
    func updateContract(status: String?, signUrl: String?, fileUrl: String?)
    /// 更新尾款金额
    func updateTailPaymentAmount(_ amount: Decimal)
    /// 设置合同请求进行中
    func setContractBusy(_ busy: Bool)
    /// 设置尾款支付请求进行中
    func setTailPaymentBusy(_ busy: Bool)
    /// 展示合同签署页（仅 http/https）
    func showContractWebPage(url: URL)
    /// 关闭合同签署页
    func clearContractWebPage()
    /// 更新销售车型图片集
    func updateSaleModelImages(saleModelImages: [String])
    /// 更新销售车型简介
    func updateSaleModelIntro(saleModelName: String, saleModelDesc: String)
    /// 更新预定方式
    func updateBookMethod(downPayment: Bool, downPaymentPrice: Decimal, earnestMoney: Bool, earnestMoneyPrice: Decimal, purchaseDenefitsIntro: String)
    /// 更新销售车型价格
    func updateSaleModelPrice(saleModelName: String, saleModelPrice: Decimal, totalPrice: Decimal)
    /// 更新总价
    func updateTotalPrice(totalPrice: Decimal)
    /// 更新销售车型配置（动态配置项）
    func updateDynamicConfigs(_ configs: [(String, String, Decimal)])
    /// 更新选择预定方式
    func updateSelectBookMethod(bookMethod: String)
    /// 更新选择下单人员类型
    func updateSelectOrderPersonType(orderPersonType: Int)
    /// 更新下单人信息
    func updateOrderPerson(orderPersonType: Int, orderPersonName: String, orderPersonIdType: Int, orderPersonIdNum: String)
    /// 更新人员姓名
    func updateOrderPersonName(name: String)
    /// 更新人员证件号码
    func updateOrderPersonIdNum(idNum: String)
    /// 更新购车方案类型
    func updateSelectPurchasePlan(purchasePlan: Int)
    /// 更新购车方案
    func updatePurchasePlan(purchasePlan: Int)
    /// 更新订单
    func updateOrder(orderNum: String, orderTime: Int64)
    /// 更新上牌城市
    func updateLicenseCity(code: String, name: String)
    /// 更新销售门店
    func updateDealership(code: String, name: String)
    /// 更新交付中心
    func updateDeliveryCenter(code: String, name: String)
    /// 切换订购协议
    func toggleAgreement()
    /// 更新购车协议列表
    func updatePurchaseAgreements(_ agreements: [PurchaseAgreement])
    func setIsFromEarnestMoneyConversion(isFrom: Bool)
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
    /// 显示已分配车辆页
    func displayAllocationVehicle()
    /// 显示待运输页
    func displayPrepareTransport()
    /// 显示待提车
    func displayPrepareDeliver()
    /// 显示已支付尾款
    func displayFinalPaymentPaid()
    /// 显示终态（失效/取消/关闭）
    func displayInvalidOrder(title: String, canReopenPayment: Bool)
    /// 显示已开票
    func displayInvoiced()
    /// 显示已提车
    func displayDelivered()
}

// MARK: - Route

protocol VehicleOrderDetailModelRouterProtocol: MviModelRouterProtocol {
    func routeToMarketingIndex()
    func routeToModelConfig()
    func routeToLicenseArea()
    func routeToDealership()
    func routeToDeliveryCenter()
    func routeToEarnestMoneyPay()
    func routeToDownPaymentPay()
}
