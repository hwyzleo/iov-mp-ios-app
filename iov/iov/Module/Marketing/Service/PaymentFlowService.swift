//
//  PaymentFlowService.swift
//  iov
//
//  IOS-APP-DSN-CR-002 / DSN-CR-004 / DSN-CR-007
//  统一支付流程：发起支付 → 轮询支付单 → 返回终态。
//  支付终态始终由服务端决定：真实环境由支付渠道签名回调驱动，mock 环境由服务端扮演渠道自回调
//  （客户端不再持回调签名密钥、不伪造回调）。
//  订单已失效（201057）时自动恢复一次并重试，避免用户因恰好超时而支付失败。
//

import Foundation

/// 支付阶段（与后端 PaymentStage 保持一致）
enum PaymentStageValue: String {
    case earnestMoney = "EARNEST_MONEY"
    case downPayment = "DOWN_PAYMENT"
}

/// 云端支付相关错误码（OTD-VSO-DSN-CR-005）
enum PaymentErrorCode {
    /// 订单已失效，可重新发起支付
    static let orderExpired = "201057"
    /// 当前状态不允许重新支付
    static let reopenNotAllowed = "201058"
    /// 重新支付次数已用尽
    static let reopenLimitExceeded = "201059"
    /// 订单不存在或已删除
    static let orderNotExist = "201001"
}

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
        initiate(orderNo: orderNo,
                 stage: stage,
                 paymentChannel: paymentChannel,
                 allowRecover: true,
                 completion: completion)
    }

    /// 重新发起支付（订单已失效时由用户主动触发）
    func reopenPayment(orderNo: String,
                       completion: @escaping (Result<ReopenPaymentResult, Error>) -> Void) {
        ServiceContainer.marketingService.reopenPayment(orderNo: orderNo) { result in
            switch result {
            case .success(let response):
                guard response.isSuccess, let data = response.data else {
                    completion(.failure(PaymentFlowError.failed(
                        Self.reopenErrorMessage(code: response.code, message: response.message))))
                    return
                }
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - 内部实现

    /// 发起支付；`allowRecover` 为 true 时允许对 201057 自动恢复一次（禁止递归）
    private func initiate(orderNo: String,
                          stage: PaymentStageValue,
                          paymentChannel: String,
                          allowRecover: Bool,
                          completion: @escaping (Result<PaymentRecord?, Error>) -> Void) {
        ServiceContainer.marketingService.initiatePayment(orderNo: orderNo, paymentChannel: paymentChannel) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard response.isSuccess, let payment = response.data else {
                    if allowRecover, response.code == PaymentErrorCode.orderExpired {
                        // 自动恢复一次并重试，用户无感
                        self.recoverAndRetry(orderNo: orderNo,
                                             stage: stage,
                                             paymentChannel: paymentChannel,
                                             completion: completion)
                        return
                    }
                    if response.code == PaymentErrorCode.reopenLimitExceeded {
                        completion(.failure(PaymentFlowError.failed(L10nErrorMessage.reopenLimitExceeded)))
                        return
                    }
                    completion(.failure(PaymentFlowError.failed(response.message ?? "发起支付失败")))
                    return
                }
                // mock 模式下的支付终态由**服务端**扮演支付渠道触发签名回调（OTD-VSO-DSN-CR-007），
                // 客户端不持任何密钥、不伪造回调，只轮询服务端支付单状态。
                self.pollPayment(orderNo: orderNo, paymentNo: payment.paymentNo, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// 201057 自动恢复：reopen 成功后重试一次 initiate（不允许再次恢复）
    private func recoverAndRetry(orderNo: String,
                                 stage: PaymentStageValue,
                                 paymentChannel: String,
                                 completion: @escaping (Result<PaymentRecord?, Error>) -> Void) {
        reopenPayment(orderNo: orderNo) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.initiate(orderNo: orderNo,
                              stage: stage,
                              paymentChannel: paymentChannel,
                              allowRecover: false,
                              completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private static func reopenErrorMessage(code: String, message: String?) -> String {
        switch code {
        case PaymentErrorCode.reopenLimitExceeded:
            return L10nErrorMessage.reopenLimitExceeded
        case PaymentErrorCode.reopenNotAllowed:
            return L10nErrorMessage.reopenNotAllowed
        case PaymentErrorCode.orderNotExist:
            return L10nErrorMessage.orderNotExist
        default:
            return message ?? "重新发起支付失败"
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

/// 支付相关用户可读文案（保持与 Localizable.strings 的 key 对应）
enum L10nErrorMessage {
    static var reopenLimitExceeded: String {
        String(localized: "reopen_limit_exceeded")
    }
    static var reopenNotAllowed: String {
        String(localized: "reopen_not_allowed")
    }
    static var orderNotExist: String {
        String(localized: "order_not_exist")
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
