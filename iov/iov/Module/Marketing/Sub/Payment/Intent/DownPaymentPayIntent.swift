//
//  DownPaymentPayIntent.swift
//  iov
//
//  Created on 2026/5/16.
//

import Foundation
import Combine

class DownPaymentPayIntent: DownPaymentPayIntentProtocol {
    private weak var modelAction: DownPaymentPayModelActionProtocol?
    private weak var modelRouter: DownPaymentPayModelRouterProtocol?
    
    private var countdownTimer: Timer?
    private var payInfo: DownPaymentPayInfo?
    
    init(model: DownPaymentPayModel) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    func viewOnAppear() {
        modelAction?.displayLoading()
        
        if let info = AppGlobalState.shared.parameters["downPaymentPayInfo"] as? DownPaymentPayInfo {
            self.payInfo = info
            modelAction?.updatePayInfo(info: info)
            
            if info.isExpired {
                modelAction?.displayExpired()
            } else {
                modelAction?.displayReady()
                startCountdown()
            }
        } else {
            modelAction?.displayFailed(text: "支付信息缺失")
        }
    }
    
    func onTapChannel(channel: PaymentChannelInfo) {
        modelAction?.updateSelectedChannel(channel: channel)
    }
    
    func onTapPay() {
        guard let info = payInfo, let channel = selectedChannel(), let orderNo = info.orderNo else { return }
        
        if info.isExpired {
            modelAction?.displayExpired()
            return
        }
        
        stopCountdown()
        modelAction?.displayPaying()
        
        PaymentFlowService.shared.pay(
            orderNo: orderNo,
            stage: .downPayment,
            paymentChannel: channel.channelCode
        ) { [weak self] result in
            switch result {
            case .success:
                self?.modelAction?.displaySuccess()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    AppGlobalState.shared.needRefresh = true
                    AppGlobalState.shared.needCloseOrderDetail = true
                    DispatchQueue.main.async {
                        AppRouter.shared.popToRoot()
                    }
                }
            case .failure(let error):
                self?.modelAction?.displayFailed(text: error.localizedDescription)
            }
        }
    }
    
    private func selectedChannel() -> PaymentChannelInfo? {
        return (modelAction as? DownPaymentPayModel)?.selectedChannel
    }
    
    func startCountdown() {
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let info = self.payInfo else { return }
            
            let remaining = info.remainingSeconds - 1
            self.modelAction?.updateRemainingSeconds(seconds: remaining)
            
            if remaining <= 0 {
                self.stopCountdown()
                self.modelAction?.displayExpired()
            }
        }
    }
    
    func stopCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
}