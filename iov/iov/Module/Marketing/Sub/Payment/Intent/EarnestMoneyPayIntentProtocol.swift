//
//  EarnestMoneyPayIntentProtocol.swift
//  iov
//
//  Created on 2026/5/13.
//

import Foundation

protocol EarnestMoneyPayIntentProtocol: MviIntentProtocol {
    func onTapChannel(channel: PaymentChannelInfo)
    func onTapPay()
    func startCountdown()
    func stopCountdown()
}