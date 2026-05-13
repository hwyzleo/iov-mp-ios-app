//
//  EarnestMoneyPayInfo.swift
//  iov
//
//  Created on 2026/5/13.
//

import Foundation

struct EarnestMoneyPayInfo {
    let smallOrderNo: String
    let earnestMoneyAmount: Decimal
    let paymentChannels: [PaymentChannelInfo]
    let expireTime: Date
    
    init(from result: EarnestMoneyOrderResult) {
        self.smallOrderNo = result.smallOrderNo
        self.earnestMoneyAmount = result.earnestMoneyAmount
        self.paymentChannels = result.paymentChannels
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withFullTime]
        self.expireTime = dateFormatter.date(from: result.expireTime) ?? Date().addingTimeInterval(900)
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