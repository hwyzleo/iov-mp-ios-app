//
//  DownPaymentPayInfo.swift
//  iov
//
//  Created on 2026/5/16.
//

import Foundation

struct DownPaymentPayInfo {
    let orderNo: String?
    let downPaymentAmount: Decimal
    let paymentChannels: [PaymentChannelInfo]
    let expireTime: Date
    
    init(from result: DownPaymentOrderResult) {
        self.orderNo = result.orderNo
        self.downPaymentAmount = result.downPaymentAmount
        self.paymentChannels = result.paymentChannels
        self.expireTime = result.expireTime
    }
    
    init(orderNo: String?, downPaymentAmount: Decimal, paymentChannels: [PaymentChannelInfo], expireTime: Date) {
        self.orderNo = orderNo
        self.downPaymentAmount = downPaymentAmount
        self.paymentChannels = paymentChannels
        self.expireTime = expireTime
    }
    
    var remainingSeconds: Int {
        let now = Date()
        let diff = expireTime.timeIntervalSince(now)
        return max(0, Int(diff))
    }
    
    var isExpired: Bool {
        return remainingSeconds <= 0
    }
    
    var defaultChannel: PaymentChannelInfo? {
        return paymentChannels.first { $0.isDefault }
    }
}