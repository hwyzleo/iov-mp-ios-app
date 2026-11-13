//
//  PaymentFlowService.swift
//  iov
//
//  IOS-APP-DSN-CR-002
//  统一支付流程：发起支付 → 本地 Mock 网关回调 / 轮询支付单 → 返回终态。
//

import Foundation

final class PaymentFlowService {

    static let shared = PaymentFlowService()

    private let maxPollCount = 30
    private let pollInterval: TimeInterval = 1.0

    private init() {}

    /// 发起支付并等待终态
    /// - Parameters:
    ///   - orderNo: 订单号
    ///   - stage: 支付阶段（意向金/定金）
    ///   - paymentChannel: 支付渠道
    ///   - completion: 成功返回已支付支付单；失败返回错误
    func pay(orderNo: String,
             stage: PaymentStageValue,
             paymentChannel: String,
             completion: @escaping (Result<PaymentRecord?, Error>) -> Void) {
        ServiceContainer.marketingService.initiatePayment(orderNo: orderNo, paymentChannel: paymentChannel) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard response.isSuccess, let payment = response.data else {
                    completion(.failure(PaymentFlowError.failed(response.message ?? "发起支付失败")))
                    return
                }
                if MockPaymentGateway.isEnabled {
                    // 本地联调：模拟外部支付网关签名回调，随后轮询服务端支付单确认状态
                    MockPaymentGateway.simulateSuccess(paymentNo: payment.paymentNo,
                                                       paymentStage: stage,
                                                       paymentAmount: payment.paymentAmount) { mockResult in
                        switch mockResult {
                        case .success:
                            self.pollPayment(orderNo: orderNo, paymentNo: payment.paymentNo, completion: completion)
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                } else {
                    self.pollPayment(orderNo: orderNo, paymentNo: payment.paymentNo, completion: completion)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func pollPayment(orderNo: String,
                             paymentNo: String,
                             remaining: Int? = nil,
                             completion: @escaping (Result<PaymentRecord?, Error>) -> Void) {
        let attemptsLeft = (remaining ?? maxPollCount) - 1
        ServiceContainer.marketingService.getPayment(orderNo: orderNo, paymentNo: paymentNo) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard let record = response.data else {
                    completion(.failure(PaymentFlowError.failed(response.message ?? "支付状态查询失败")))
                    return
                }
                switch record.paymentStatus {
                case "PAID":
                    completion(.success(record))
                case "PAYMENT_FAILED", "CANCELLED", "CLOSED":
                    completion(.failure(PaymentFlowError.failed(record.failReason ?? "支付未完成")))
                default:
                    guard attemptsLeft > 0 else {
                        completion(.failure(PaymentFlowError.failed("支付处理超时，请稍后刷新订单")))
                        return
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.pollInterval) {
                        self.pollPayment(orderNo: orderNo, paymentNo: paymentNo, remaining: attemptsLeft, completion: completion)
                    }
                }
            case .failure(let error):
                guard attemptsLeft > 0 else {
                    completion(.failure(error))
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + self.pollInterval) {
                    self.pollPayment(orderNo: orderNo, paymentNo: paymentNo, remaining: attemptsLeft, completion: completion)
                }
            }
        }
    }
}

enum PaymentFlowError: LocalizedError {
    case failed(String)

    var errorDescription: String? {
        switch self {
        case .failed(let message):
            return message
        }
    }
}
