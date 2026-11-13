//
//  MockPaymentGateway.swift
//  iov
//
//  IOS-APP-DSN-CR-002
//  本地模拟外部支付网关：仅 Debug + isMock 开启时参与编译/执行。
//  通过 HMAC-SHA256 签名回调 VSO 支付回调接口，使订单状态在本地联调时真正流转到已支付。
//

import Foundation

#if DEBUG
import CryptoKit
#endif

/// 支付阶段（与后端 PaymentStage 保持一致）
enum PaymentStageValue: String {
    case earnestMoney = "EARNEST_MONEY"
    case downPayment = "DOWN_PAYMENT"
}

enum MockPaymentError: LocalizedError {
    case disabled
    case callbackFailed(String)

    var errorDescription: String? {
        switch self {
        case .disabled:
            return "本地支付模拟未开启"
        case .callbackFailed(let message):
            return message
        }
    }
}

enum MockPaymentGateway {

    static var isEnabled: Bool {
        #if DEBUG
        return AppGlobalState.shared.isMock
        #else
        return false
        #endif
    }

#if DEBUG
    /// 与 iov-cloud-otd-vso `vso.payment.callback.signature-secret` 默认值一致。
    /// 仅用于 Debug 本地联调；Release 不参与编译。
    private static let debugSignatureSecret = "hwyz1234567890abcdef"

    /// 模拟支付成功：延迟后以签名回调通知 VSO
    static func simulateSuccess(paymentNo: String,
                                paymentStage: PaymentStageValue,
                                paymentAmount: Decimal,
                                completion: @escaping (Result<Void, Error>) -> Void) {
        guard isEnabled else {
            completion(.failure(MockPaymentError.disabled))
            return
        }

        let externalTradeNo = "MOCK-" + paymentNo
        let status = "PAID"

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let timestamp = Int(Date().timeIntervalSince1970)
            let nonce = UUID().uuidString.replacingOccurrences(of: "-", with: "")
            let signature = buildSignature(paymentNo: paymentNo,
                                           externalTradeNo: externalTradeNo,
                                           status: status,
                                           amount: paymentAmount,
                                           nonce: nonce,
                                           timestamp: timestamp)
            let parameters: [String: Any] = [
                "paymentNo": paymentNo,
                "externalTradeNo": externalTradeNo,
                "paymentStage": paymentStage.rawValue,
                "paymentAmount": paymentAmount,
                "paymentStatus": status,
                "payTime": Int(Date().timeIntervalSince1970 * 1000),
                "idempotentKey": UUID().uuidString,
                "timestamp": timestamp,
                "nonce": nonce,
                "signature": signature
            ]

            TspManager.requestPost(
                path: "/api/open/vsoCallback/v1/payment",
                parameters: parameters,
                headers: ["X-Signature": signature]
            ) { (result: Result<TspResponse<NoReply>, Error>) in
                switch result {
                case .success(let response):
                    if response.isSuccess {
                        completion(.success(()))
                    } else {
                        completion(.failure(MockPaymentError.callbackFailed(response.message ?? "Mock 支付回调失败")))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    /// 可见性 internal 以便单元测试签名串构造
    static func buildSignature(paymentNo: String,
                               externalTradeNo: String,
                               status: String,
                               amount: Decimal,
                               nonce: String,
                               timestamp: Int) -> String {
        let amountText = NSDecimalNumber(decimal: amount).stringValue
        let signData: [String: String] = [
            "amount": amountText,
            "orderId": paymentNo,
            "paySeq": externalTradeNo,
            "status": status,
            "nonce": nonce,
            "timestamp": String(timestamp)
        ]
        let content = signData.keys.sorted()
            .map { "\($0)=\(signData[$0] ?? "")" }
            .joined(separator: "&")
        return hmacSHA256(content: content, secret: debugSignatureSecret)
    }

    static func hmacSHA256(content: String, secret: String) -> String {
        let key = SymmetricKey(data: Data(secret.utf8))
        let mac = HMAC<SHA256>.authenticationCode(for: Data(content.utf8), using: key)
        return mac.map { String(format: "%02x", $0) }.joined()
    }
#else
    static func simulateSuccess(paymentNo: String,
                                paymentStage: PaymentStageValue,
                                paymentAmount: Decimal,
                                completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.failure(MockPaymentError.disabled))
    }
#endif
}
