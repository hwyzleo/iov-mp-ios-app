//
//  EarnestMoneyPayIntent.swift
//  iov
//
//  Created on 2026/5/13.
//

import Foundation
import Combine

class EarnestMoneyPayIntent: EarnestMoneyPayIntentProtocol {
    private weak var modelAction: EarnestMoneyPayModelActionProtocol?
    private weak var modelRouter: EarnestMoneyPayModelRouterProtocol?
    
    private var countdownTimer: Timer?
    private var payInfo: EarnestMoneyPayInfo?
    
    init(model: EarnestMoneyPayModel) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    func viewOnAppear() {
        modelAction?.displayLoading()
        
        if let info = AppGlobalState.shared.parameters["earnestMoneyPayInfo"] as? EarnestMoneyPayInfo {
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
        guard let info = payInfo, let channel = selectedChannel() else { return }
        
        if info.isExpired {
            modelAction?.displayExpired()
            return
        }
        
        stopCountdown()
        modelAction?.displayPaying()
        
        PaymentFlowService.shared.pay(
            orderNo: info.orderNo,
            stage: .earnestMoney,
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
        return (modelAction as? EarnestMoneyPayModel)?.selectedChannel
    }
    
    func startCountdown() {
        stopCountdown()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let info = self.payInfo else { return }

            // 用绝对截止时间重算，避免退到后台/主线程卡顿后定时器漂移
            let remaining = info.remainingSeconds
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