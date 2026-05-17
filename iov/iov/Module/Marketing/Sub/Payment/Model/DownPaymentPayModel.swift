//
//  DownPaymentPayModel.swift
//  iov
//
//  Created on 2026/5/16.
//

import SwiftUI

final class DownPaymentPayModel: ObservableObject, DownPaymentPayModelStateProtocol {
    @Published var contentState: DownPaymentPayTypes.Model.ContentState = .loading
    @Published var payInfo: DownPaymentPayInfo?
    @Published var selectedChannel: PaymentChannelInfo?
    @Published var remainingSeconds: Int = 0
    @Published var paymentResult: InitiatePaymentResult?
    
    let routerSubject = MarketingRouter.Subjects()
}

extension DownPaymentPayModel: DownPaymentPayModelActionProtocol {
    func updatePayInfo(info: DownPaymentPayInfo) {
        self.payInfo = info
        self.remainingSeconds = info.remainingSeconds
        self.selectedChannel = info.defaultChannel
    }
    
    func updateSelectedChannel(channel: PaymentChannelInfo) {
        self.selectedChannel = channel
    }
    
    func updateRemainingSeconds(seconds: Int) {
        self.remainingSeconds = seconds
    }
    
    func updatePaymentResult(result: InitiatePaymentResult) {
        self.paymentResult = result
    }
    
    func displayReady() {
        contentState = .ready
    }
    
    func displayPaying() {
        contentState = .paying
    }
    
    func displaySuccess() {
        contentState = .success
    }
    
    func displayFailed(text: String) {
        contentState = .failed(text: text)
    }
    
    func displayExpired() {
        contentState = .expired
    }
    
    func displayLoading() {
        contentState = .loading
    }
}

extension DownPaymentPayModel: DownPaymentPayModelRouterProtocol {
    func closeScreen() {
        routerSubject.close.send()
    }
}