//
//  VehicleWishlistIntentProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/13.
//

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
    /// 点击上牌城市
    func onTapLicenseCity()
    /// 点击订购协议
    func onTapAgreement()
    /// 点击意向金预定
    func onTapEarnestMoneyOrder(saleModelName: String, licenseCity: String)
    /// 点击定金预定
    func onTapDownPaymentOrder(orderType: Int, purchasePlan: Int, orderPersonName: String, orderPersonIdType: Int, orderPersonIdNum: String, saleModelName: String, licenseCity: String, dealership: String, deliveryCenter: String)
    /// 点击取消订单
    func onTapCancelOrder()
    /// 点击订单支付
    func onTapPayOrder(orderPaymentPhase: Int, paymentAmount: Decimal, paymentChannel: String)
    /// 点击意向金转定金
    func onTapEarnestMoneyToDownPayment()
    /// 点击锁定订单
    func onTapLockOrder()
    /// 显示上牌区域页
    func onLicenseAreaAppear()
    /// 点击上牌区域
    func onTapLicenseArea(provinceCode: String, cityCode: String, displayName: String)
}
