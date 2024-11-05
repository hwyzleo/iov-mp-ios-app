//
//  VehicleWishlistIntentProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/13.
//
import Foundation

protocol VehicleOrderDetailIntentProtocol : MviIntentProtocol {
    /// 点击删除
    func onTapDelete()
    /// 点击修改销售车型配置
    func onTapModifySaleModel()
    /// 点击订购
    func onTapOrder()
    /// 点击定金预定方式
    func onTapDownPaymentBookMethod()
    /// 点击意向金预定方式
    func onTapEarnestMoneyBookMethod()
    /// 点击下单人员类型个人
    func onTapOrderPersonTypePerson()
    /// 点击下单人员类型企业
    func onTapOrderPersonTypeOrg()
    /// 点击购车方案全款
    func onTapPurchasePlanFullPayment()
    /// 点击否车方案分期
    func onTapPurchasePlanStaging()
    /// 点击上牌城市
    func onTapLicenseCity()
    /// 点击销售门店
    func onTapDealership()
    /// 点击交付中心
    func onTapDeliveryCenter()
    /// 点击订购协议
    func onTapAgreement()
    /// 点击意向金预定
    func onTapEarnestMoneyOrder(saleModelName: String, licenseCityCode: String)
    /// 点击定金预定
    func onTapDownPaymentOrder(orderPersonType: Int, purchasePlan: Int, orderPersonName: String, orderPersonIdType: Int, orderPersonIdNum: String, saleModelName: String, licenseCity: String, dealership: String, deliveryCenter: String)
    /// 点击取消订单
    func onTapCancelOrder()
    /// 点击订单支付
    func onTapPayOrder(orderPaymentPhase: Int, paymentAmount: Decimal, paymentChannel: String)
    /// 点击意向金转定金
    func onTapEarnestMoneyToDownPayment()
    /// 点击锁定订单
    func onTapLockOrder()
}
