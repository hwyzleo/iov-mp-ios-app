//
//  EarnestMoneyPayInfo.swift
//  iov
//
//  Created on 2026/5/13.
//

import Foundation

struct EarnestMoneyPayInfo {
    let orderNo: String
    let earnestMoneyAmount: Decimal
    let paymentChannels: [PaymentChannelInfo]
    let expireTime: Date
    
    init(from result: EarnestMoneyOrderResult) {
        self.orderNo = result.orderNo
        self.earnestMoneyAmount = result.earnestMoneyAmount
        self.paymentChannels = result.paymentChannels
        self.expireTime = result.expireTime
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