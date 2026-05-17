//
//  DownPaymentPayModelProtocol.swift
//  iov
//
//  Created on 2026/5/16.
//

import SwiftUI

protocol DownPaymentPayModelStateProtocol: ObservableObject {
    var contentState: DownPaymentPayTypes.Model.ContentState { get }
    var payInfo: DownPaymentPayInfo? { get }
    var selectedChannel: PaymentChannelInfo? { get }
    var remainingSeconds: Int { get }
    var paymentResult: InitiatePaymentResult? { get }
    var routerSubject: MarketingRouter.Subjects { get }
}

protocol DownPaymentPayModelActionProtocol: AnyObject {
    func updatePayInfo(info: DownPaymentPayInfo)
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

protocol DownPaymentPayModelRouterProtocol: AnyObject {
    func closeScreen()
}