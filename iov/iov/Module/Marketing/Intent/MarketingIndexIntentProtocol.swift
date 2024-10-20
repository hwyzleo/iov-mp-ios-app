//
//  VehicleIndexIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

import Foundation

protocol MarketingIndexIntentProtocol : MviIntentProtocol {
    /// 点击车型配置
    func onTapModelConfig()
    /// 点击订购按钮
    func onTapOrder()
    /// 点击心愿单详情
    func onTapWishlistDetail()
    /// 点击订单详情
    func onTapOrderDetail(orderState: OrderState)
    /// 点击订单支付
    func onTapPayOrder(orderPaymentPhase: Int, paymentAmount: Decimal, paymentChannel: String)
    /// 点击取消订单
    func onTapCancelOrder()
    /// 点击意向金转定金
    func onTapEarnestMoneyToDownPayment()
    /// 点击锁定订单
    func onTapLockOrder()
}
