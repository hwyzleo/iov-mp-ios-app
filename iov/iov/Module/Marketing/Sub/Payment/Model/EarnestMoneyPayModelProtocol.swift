//
//  EarnestMoneyPayModelProtocol.swift
//  iov
//
//  Created on 2026/5/13.
//

import SwiftUI

protocol EarnestMoneyPayModelStateProtocol: ObservableObject {
    var contentState: EarnestMoneyPayTypes.Model.ContentState { get }
    var payInfo: EarnestMoneyPayInfo? { get }
    var selectedChannel: PaymentChannelInfo? { get }
    var remainingSeconds: Int { get }
    var paymentResult: InitiatePaymentResult? { get }
}

protocol EarnestMoneyPayModelActionProtocol: AnyObject {
    func updatePayInfo(info: EarnestMoneyPayInfo)
    func updateSelectedChannel(channel: PaymentChannelInfo)
    func updateRemainingSeconds(seconds: Int)
    func updatePaymentResult(result: InitiatePaymentResult)
    func displayReady()
    func displayPaying()
    func displaySuccess()
    func displayFailed(text: String)
    func displayExpired()
    func displayLoading()
}

protocol EarnestMoneyPayModelRouterProtocol: AnyObject {
    func closeScreen()
}