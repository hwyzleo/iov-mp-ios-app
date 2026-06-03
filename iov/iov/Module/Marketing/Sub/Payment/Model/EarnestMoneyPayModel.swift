//
//  EarnestMoneyPayModel.swift
//  iov
//
//  Created on 2026/5/13.
//

import SwiftUI

final class EarnestMoneyPayModel: ObservableObject, EarnestMoneyPayModelStateProtocol {
    @Published var contentState: EarnestMoneyPayTypes.Model.ContentState = .loading
    @Published var payInfo: EarnestMoneyPayInfo?
    @Published var selectedChannel: PaymentChannelInfo?
    @Published var remainingSeconds: Int = 0
    @Published var paymentResult: InitiatePaymentResult?
}

extension EarnestMoneyPayModel: EarnestMoneyPayModelActionProtocol {
    func updatePayInfo(info: EarnestMoneyPayInfo) {
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

extension EarnestMoneyPayModel: EarnestMoneyPayModelRouterProtocol {
    func closeScreen() {
        AppRouter.shared.pop()
    }
}