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
        
        ServiceContainer.marketingService.initiatePayment(
            orderNo: info.orderNo,
            paymentChannel: channel.channelCode
        ) { [weak self] result in
            switch result {
            case .success(let res):
                print("initiatePayment result: code=\(res.code), isSuccess=\(res.isSuccess), data=\(res.data != nil)")
                if res.isSuccess, let paymentResult = res.data {
                    self?.modelAction?.updatePaymentResult(result: paymentResult)
                    print("simulatePayment called: paymentNo=\(paymentResult.paymentNo), amount=\(paymentResult.paymentAmount)")
                    self?.simulatePayment(paymentNo: paymentResult.paymentNo, paymentAmount: paymentResult.paymentAmount)
                } else {
                    self?.modelAction?.displayFailed(text: res.message ?? "发起支付失败")
                }
            case .failure(let error):
                print("initiatePayment failure: \(error)")
                self?.modelAction?.displayFailed(text: "网络请求失败")
            }
        }
    }
    
    private func selectedChannel() -> PaymentChannelInfo? {
        return (modelAction as? EarnestMoneyPayModel)?.selectedChannel
    }
    
    private func simulatePayment(paymentNo: String, paymentAmount: Decimal) {
        print("simulatePayment entering: paymentNo=\(paymentNo), amount=\(paymentAmount)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            print("simulatePayment asyncAfter triggered")
            ServiceContainer.marketingService.paymentCallback(
                paymentNo: paymentNo,
                externalTradeNo: "MOCK_TRADE_" + UUID().uuidString,
                paymentStage: "EARNEST_MONEY",
                paymentAmount: paymentAmount,
                paymentStatus: "SUCCESS",
                payTime: Date(),
                idempotentKey: nil
            ) { result in
                print("paymentCallback result: \(result)")
                switch result {
                case .success(let res):
                    if res.isSuccess {
                        self?.modelAction?.displaySuccess()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            AppGlobalState.shared.needRefresh = true
                            let lastView = AppGlobalState.shared.parameters["lastView"] as? String ?? ""
                            if lastView == "MODEL_CONFIG" {
                                AppGlobalState.shared.parameters["backCount"] = 1
                            }
                            AppGlobalState.shared.needCloseOrderDetail = true
                            self?.modelRouter?.closeScreen()
                        }
                    } else {
                        self?.modelAction?.displayFailed(text: res.message ?? "支付失败")
                    }
                case .failure:
                    self?.modelAction?.displayFailed(text: "网络请求失败")
                }
            }
        }
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