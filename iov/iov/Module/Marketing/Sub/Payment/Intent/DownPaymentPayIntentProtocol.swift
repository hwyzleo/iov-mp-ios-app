//
//  DownPaymentPayIntentProtocol.swift
//  iov
//
//  Created on 2026/5/16.
//

import Foundation

protocol DownPaymentPayIntentProtocol: MviIntentProtocol {
    func onTapChannel(channel: PaymentChannelInfo)
    func onTapPay()
    func startCountdown()
    func stopCountdown()
}