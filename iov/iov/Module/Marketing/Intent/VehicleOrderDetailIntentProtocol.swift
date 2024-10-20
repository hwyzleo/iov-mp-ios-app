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
    /// 点击订购协议
    func onTapAgreement()
    /// 点击意向金预定
    func onTapEarnestMoneyOrder(saleModelName: String, licenseCity: String)
    /// 点击取消订单
    func onTapCancelOrder()
    /// 点击订单支付
    func onTapPayOrder(orderPaymentPhase: Int, paymentAmount: Decimal, paymentChannel: String)
}
