//
//  VehicleBindingService.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-010 on 2026/11/21.
//  Updated by CR IOS-APP-DSN-CR-011 on 2026/11/23（D-011-4 错误分层 / D-011-5 日志脱敏 / D-011-6 注释漂移）.
//

import Foundation

/// 车辆绑定（关系 / 扫码 / 确认 / 操作恢复）服务协议。
///
/// 设计依据：IOS-APP-DSN-CR-010 D-010-4 / D-010-6；IOS-APP-DSN-CR-011 D-011-4。
/// 对接上游已发布的手机端接口，不虚构能力：
/// - 关系查询：IOV-TSP-DSN-CR-018 `GET /api/mobile/activation/v1/binding?vin=...`（已提供）；
/// - 扫码 / 取消 / 确认 / 操作查询：IOV-TSP-DSN-CR-017。
protocol VehicleBindingServiceProtocol {
    /// 查询当前账号与选中车辆的关系。
    ///
    /// IOV-TSP-DSN-CR-018 已提供按账号 + VIN 的关系查询接口，
    /// `RealVehicleBindingService.queryRelationship` 为真实实现；
    /// VIN 缺失/非法时按 `.unknown(.capabilityUnavailable)` 降级，不当作「未绑定」。
    func queryRelationship(context: VehiclePageContext,
                           completion: @escaping (VehicleRelationshipState) -> Void)

    /// 扫码认领会话（服务端校验二维码凭据与会话状态）
    func scanActivationSession(qrToken: String,
                               completion: @escaping (Result<ActivationScanResult, VehicleBindingFailure>) -> Void)

    /// 取消会话（不修改已有云端关系）
    func cancelActivationSession(sessionId: String,
                                 completion: @escaping (Result<Void, VehicleBindingFailure>) -> Void)

    /// 确认绑定（幂等：同一 idempotencyKey + 同内容返回原结果）
    func confirmVehicleBinding(sessionId: String,
                               idempotencyKey: String,
                               completion: @escaping (Result<ActivationConfirmResult, VehicleBindingFailure>) -> Void)

    /// 查询绑定操作权威结果（仅本人操作）
    func queryBindingOperation(operationId: String,
                               completion: @escaping (Result<ActivationOperationResult, VehicleBindingFailure>) -> Void)
}

/// 真实实现：对接 IOV-TSP-DSN-CR-017 / CR-018 已发布的手机端接口。
///
/// 错误语义：统一走 `BindingErrorClassifier`（方案 A，零侵入），不再把所有失败压成 `.network`。
final class RealVehicleBindingService: VehicleBindingServiceProtocol {

    typealias RelationFetcher = (String,
                                 @escaping (Result<TspResponse<UserVehicleRelationResult>, Error>) -> Void) -> Void

    private let relationFetcher: RelationFetcher

    init(relationFetcher: @escaping RelationFetcher = TspApi.queryUserVehicleRelation) {
        self.relationFetcher = relationFetcher
    }

    func queryRelationship(context: VehiclePageContext,
                           completion: @escaping (VehicleRelationshipState) -> Void) {
        // IOV-TSP-DSN-CR-018：GET /api/mobile/activation/v1/binding?vin=...
        // VIN 必须为单个合法 17 位值；缺失/非法时客户端不得查询，更不得当作“未绑定”。
        guard let vin = VehicleVin.normalize(context.vin), VehicleVin.isValid(vin) else {
            SafeLog.log("车辆 VIN 缺失或非法，关系查询按未知降级:",
                        "account=\(SafeLog.maskAccountId(context.accountId))",
                        "vehicleId=\(SafeLog.maskAccountId(context.vehicleId))",
                        "vin=\(SafeLog.maskVin(context.vin) ?? "-")")
            completion(.unknown(.capabilityUnavailable))
            return
        }
        relationFetcher(vin) { result in
            switch result {
            case let .failure(error):
                let failure = BindingErrorClassifier.classify(error: error)
                SafeLog.log("人车关系查询失败:", failure.localizationKey)
                completion(.unknown(Self.unavailableReason(for: failure)))
            case let .success(response):
                guard response.isSuccess, let data = response.data else {
                    let failure = BindingErrorClassifier.classify(code: response.code, message: response.message)
                    SafeLog.log("人车关系查询返回异常:", failure.localizationKey)
                    completion(.unknown(Self.unavailableReason(for: failure)))
                    return
                }
                completion(Self.relationshipState(from: data))
            }
        }
    }

    /// 服务端二值事实 → 客户端关系状态；未知枚举不得猜测为未绑定。
    static func relationshipState(from data: UserVehicleRelationResult) -> VehicleRelationshipState {
        switch (data.status ?? "").uppercased() {
        case "BOUND":
            return .bound(relationId: data.relationId)
        case "NOT_BOUND":
            // NOT_BOUND 仅表示当前账号在该 VIN 上没有有效关系，不代表车辆无人绑定
            return .unboundForCurrentAccount
        default:
            return .unknown(.invalidResponse)
        }
    }

    /// 失败语义 → 关系不可用原因（认证维度必须可被真实赋值，供状态条给出「去登录」）
    static func unavailableReason(for failure: VehicleBindingFailure) -> VehicleRelationshipUnavailableReason {
        switch failure {
        case .authenticationSessionExpired, .authenticationRejected:
            return .authenticationRejected
        case .forbidden:
            return .forbidden
        case .invalidResponse, .invalidRequest:
            // 400/参数非法与解码失败都属响应不可用，保留既有 `401112 → invalidResponse` 口径
            return .invalidResponse
        case .server:
            return .serverError
        default:
            return .network
        }
    }

    /// 包络码 → 关系不可用原因（保留既有 `401112 → invalidResponse` 口径）
    static func unavailableReason(for code: String) -> VehicleRelationshipUnavailableReason {
        unavailableReason(for: BindingErrorClassifier.classify(code: code))
    }

    func scanActivationSession(qrToken: String,
                               completion: @escaping (Result<ActivationScanResult, VehicleBindingFailure>) -> Void) {
        TspApi.scanActivationSession(qrToken: qrToken) { result in
            switch result {
            case let .failure(error):
                let failure = BindingErrorClassifier.classify(error: error)
                SafeLog.log("扫码认领请求失败:", failure.localizationKey)
                completion(.failure(failure))
            case let .success(response):
                completion(Self.map(response))
            }
        }
    }

    func cancelActivationSession(sessionId: String,
                                 completion: @escaping (Result<Void, VehicleBindingFailure>) -> Void) {
        TspApi.cancelActivationSession(sessionId: sessionId) { result in
            switch result {
            case let .failure(error):
                let failure = BindingErrorClassifier.classify(error: error)
                SafeLog.log("取消激活会话失败:", failure.localizationKey)
                completion(.failure(failure))
            case let .success(response):
                if response.isSuccess {
                    completion(.success(()))
                } else {
                    completion(.failure(BindingErrorClassifier.classify(code: response.code,
                                                                        message: response.message)))
                }
            }
        }
    }

    func confirmVehicleBinding(sessionId: String,
                               idempotencyKey: String,
                               completion: @escaping (Result<ActivationConfirmResult, VehicleBindingFailure>) -> Void) {
        TspApi.confirmVehicleBinding(sessionId: sessionId, idempotencyKey: idempotencyKey) { result in
            switch result {
            case let .failure(error):
                let failure = BindingErrorClassifier.classify(error: error)
                SafeLog.log("确认绑定请求失败:", failure.localizationKey)
                completion(.failure(failure))
            case let .success(response):
                completion(Self.map(response))
            }
        }
    }

    func queryBindingOperation(operationId: String,
                               completion: @escaping (Result<ActivationOperationResult, VehicleBindingFailure>) -> Void) {
        TspApi.queryBindingOperation(operationId: operationId) { result in
            switch result {
            case let .failure(error):
                let failure = BindingErrorClassifier.classify(error: error)
                SafeLog.log("查询绑定操作失败:", failure.localizationKey)
                completion(.failure(failure))
            case let .success(response):
                completion(Self.map(response))
            }
        }
    }

    // MARK: - 响应映射

    private static func map<T>(_ response: TspResponse<T>) -> Result<T, VehicleBindingFailure> {
        guard response.isSuccess else {
            return .failure(BindingErrorClassifier.classify(code: response.code, message: response.message))
        }
        guard let data = response.data else {
            // 成功码但缺 data：属于响应不合法（可重试），不得说成网络问题
            SafeLog.log("⚠️ 绑车激活响应缺少 data:", BindingErrorClassifier.classify(code: response.code).localizationKey)
            return .failure(.invalidResponse)
        }
        return .success(data)
    }
}
