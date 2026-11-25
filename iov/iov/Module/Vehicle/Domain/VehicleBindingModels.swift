//
//  VehicleBindingModels.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-010 on 2026/11/21.
//

import Foundation

// MARK: - 页面上下文（多账号/多车隔离）

/// 车辆页请求上下文。
///
/// 设计依据：IOS-APP-DSN-CR-010 D-010-5。
/// 所有关系、绑定与能力查询都必须带上该上下文；账号或车辆切换后旧响应必须丢弃。
struct VehiclePageContext: Equatable {
    /// 当前登录账号（CIAM userId）
    let accountId: String
    /// 当前选中车辆（订单号 / 本地车辆标识）
    let vehicleId: String
    /// 当前车辆 VIN（可能缺失：VSO 已在 `myVehicleList` / 订单列表 / 详情透出，
    /// 缺失或非法时按 `.unknown(.capabilityUnavailable)` 降级，不猜测为未绑定）
    let vin: String?

    var isolationKey: String {
        "\(accountId)|\(vehicleId)|\(vin ?? "-")"
    }

    var hasAccountAndVehicle: Bool {
        !accountId.isEmpty && !vehicleId.isEmpty
    }
}

// MARK: - 关系状态

/// 关系查询不可用的原因。
enum VehicleRelationshipUnavailableReason: String, Equatable {
    /// App 端没有权威的关系查询接口（当前 TSP 仅提供扫码/确认/操作查询）
    case capabilityUnavailable
    /// 网络或依赖失败
    case network
    /// 认证失效 / 权限不足（登录会话失效或认证被拒，需要重新登录）
    case authenticationRejected
    /// 服务端错误
    case serverError
    /// 响应不合法
    case invalidResponse
    /// 请求被网关拒绝（`SGW-403001`）：不重试、不引导登录
    case forbidden
}

/// 当前账号与选中车辆的关系状态。
///
/// - 只有 `.unboundForCurrentAccount` 才代表“权威明确未绑定”，可以展示绑定主 CTA。
/// - `.unknown` 一律不得按未绑定处理，也不得据此判定车辆无人绑定。
enum VehicleRelationshipState: Equatable {
    case loading
    case unboundForCurrentAccount
    case bound(relationId: String?)
    case unknown(VehicleRelationshipUnavailableReason)

    var isBound: Bool {
        if case .bound = self { return true }
        return false
    }

    var isUnbound: Bool {
        if case .unboundForCurrentAccount = self { return true }
        return false
    }

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var isUnknown: Bool {
        if case .unknown = self { return true }
        return false
    }
}

// MARK: - 车机登录状态

/// 车机账号登录状态。
///
/// 设计依据：IOS-APP-DSN-CR-010 D-010-1；结论保留但标注「CR-010 §12.4 决策：本期不查询」——
/// 当前 App 端不查询车机登录状态，因此一律保持 `.unknown`；
/// UI 只能展示“请在车机完成登录”的操作指引，不得声称已登录或一定待完成。
enum VehicleLoginState: Equatable {
    case unknown
    case pending
    case succeeded
    case failed
}

// MARK: - 绑定失败语义

/// 绑定/扫码失败语义（对齐 IOV-TSP-DSN-CR-017 的 4011xx 错误码与 BindingResultReason）。
enum VehicleBindingFailure: Equatable, Error {
    case sessionInvalid
    case sessionExpired
    case sessionCancelled
    case sessionClaimed
    case vehicleNotFound
    case eligibilityRejected
    case eligibilityUndetermined
    case dependencyUnavailable
    case relationConflict
    case idempotencyConflict
    case agreementNotAccepted
    case invalidRequest
    /// 扫码车辆与当前车辆不一致
    case vehicleMismatch
    case network
    case server(message: String?)
    case unknown
    /// 登录会话失效（`701304` / `SGW-401001`）→ 触发统一会话失效清理并引导登录
    case authenticationSessionExpired
    /// 认证被拒（`701403` / HTTP 401）→ 引导重新登录，不重试
    case authenticationRejected
    /// 响应无法解码 / 网关资源不存在（`SGW-404001`）→ 可重试，但不表述为网络问题
    case invalidResponse
    /// 请求被网关拒绝（`SGW-403001`）→ 不重试、不引导登录
    case forbidden

    /// 数字错误码 → 语义（IOV-TSP-DSN-CR-017：401101 ~ 401114）
    static func from(code: String, message: String? = nil) -> VehicleBindingFailure {
        switch code {
        case "401101": return .sessionInvalid
        case "401102": return .sessionExpired
        case "401103": return .sessionCancelled
        case "401104": return .sessionClaimed
        case "401105": return .vehicleNotFound
        case "401106": return .eligibilityRejected
        case "401107": return .eligibilityUndetermined
        case "401108": return .dependencyUnavailable
        case "401109": return .relationConflict
        case "401110": return .idempotencyConflict
        case "401111": return .agreementNotAccepted
        case "401112": return .invalidRequest
        default:
            if let message, !message.isEmpty {
                return .server(message: message)
            }
            return .unknown
        }
    }

    /// 服务端语义 reason → 失败语义（绑定结果与操作查询共用）
    static func from(reason: String?) -> VehicleBindingFailure {
        switch reason {
        case "SESSION_INVALID": return .sessionInvalid
        case "SESSION_EXPIRED": return .sessionExpired
        case "SESSION_CANCELLED": return .sessionCancelled
        case "SESSION_CLAIMED": return .sessionClaimed
        case "VEHICLE_NOT_FOUND": return .vehicleNotFound
        case "ELIGIBILITY_REJECTED": return .eligibilityRejected
        case "ELIGIBILITY_UNDETERMINED": return .eligibilityUndetermined
        case "DEPENDENCY_UNAVAILABLE": return .dependencyUnavailable
        case "RELATION_CONFLICT": return .relationConflict
        case "IDEMPOTENCY_CONFLICT": return .idempotencyConflict
        case "AGREEMENT_NOT_ACCEPTED": return .agreementNotAccepted
        case "INVALID_REQUEST": return .invalidRequest
        default: return .unknown
        }
    }

    /// 是否可用同一幂等键重试（服务端未落终态）
    ///
    /// 说明：`.unknown` 的可重试性受裁决 R-16 约束——只有「传输层结果不确定且持有幂等键
    /// 或 operationId」时才允许自动恢复；无键无 operationId 时必须停止并落 `.failed(.unknown)`。
    var isRetryableWithSameKey: Bool {
        switch self {
        case .network, .dependencyUnavailable, .invalidResponse, .unknown:
            return true
        default:
            return false
        }
    }

    /// 认证维度失败（统一会话失效 + 引导登录；不得重试、不得压缩为 `.network`）
    var isAuthenticationFailure: Bool {
        switch self {
        case .authenticationSessionExpired, .authenticationRejected:
            return true
        default:
            return false
        }
    }

    /// 扫码失败后的用户动作分类（IOS-APP-DSN-CR-011 D-011-2 §4.3）
    var scanFailureAction: ScanFailureAction {
        switch self {
        case .network, .dependencyUnavailable, .invalidResponse, .unknown, .server:
            // 可重试：复用同一次 qrToken，服务端扫码认领幂等
            return .retryWithSameToken
        case .sessionInvalid, .sessionExpired, .sessionCancelled, .sessionClaimed,
             .vehicleMismatch, .agreementNotAccepted, .invalidRequest:
            // 需刷新/重新生成二维码
            return .needsNewQr
        case .vehicleNotFound, .eligibilityRejected, .eligibilityUndetermined,
             .relationConflict, .idempotencyConflict, .forbidden:
            // 需人工（交付人员/客服）；`.forbidden` 明确不重试、不引导登录
            return .needsManual
        case .authenticationSessionExpired, .authenticationRejected:
            // 需登录（保留 qrToken 暂存，登录后续跑一次）
            return .needsLogin
        }
    }

    /// 文案 key（zh-Hans / en 均需登记）
    var localizationKey: String {
        switch self {
        case .sessionInvalid: return "vehicle_binding_error_session_invalid"
        case .sessionExpired: return "vehicle_binding_error_session_expired"
        case .sessionCancelled: return "vehicle_binding_error_session_cancelled"
        case .sessionClaimed: return "vehicle_binding_error_session_claimed"
        case .vehicleNotFound: return "vehicle_binding_error_vehicle_not_found"
        case .eligibilityRejected: return "vehicle_binding_error_eligibility_rejected"
        case .eligibilityUndetermined: return "vehicle_binding_error_eligibility_undetermined"
        case .dependencyUnavailable: return "vehicle_binding_error_dependency_unavailable"
        case .relationConflict: return "vehicle_binding_error_relation_conflict"
        case .idempotencyConflict: return "vehicle_binding_error_idempotency_conflict"
        case .agreementNotAccepted: return "vehicle_binding_error_agreement_not_accepted"
        case .invalidRequest: return "vehicle_binding_error_invalid_request"
        case .vehicleMismatch: return "vehicle_binding_error_vehicle_mismatch"
        case .network: return "vehicle_binding_error_network"
        case .server(let message):
            if let message, !message.isEmpty { return message }
            return "vehicle_binding_error_server"
        case .unknown: return "vehicle_binding_error_unknown"
        case .authenticationSessionExpired: return "vehicle_binding_error_authentication_session_expired"
        case .authenticationRejected: return "vehicle_binding_error_authentication_rejected"
        case .invalidResponse: return "vehicle_binding_error_invalid_response"
        case .forbidden: return "vehicle_binding_error_forbidden"
        }
    }
}

// MARK: - 扫码会话与操作结果

/// 扫码会话状态。
///
/// IOS-APP-DSN-CR-011 D-011-2：新增 `.unknown(raw:)`，未知枚举值**不得**被当作可提交；
/// 只有 `.scanned` 且未本地过期时允许确认。
enum ActivationSessionState: Equatable {
    case issued
    case scanned
    case bound
    case cancelled
    case expired
    case skipped
    /// 服务端返回了未识别状态（保留原值用于日志分类与提示，不参与提交判断）
    case unknown(raw: String?)

    init?(serverValue: String?) {
        guard let serverValue, !serverValue.isEmpty else { return nil }
        switch serverValue.uppercased() {
        case "ISSUED": self = .issued
        case "SCANNED": self = .scanned
        case "BOUND": self = .bound
        case "CANCELLED": self = .cancelled
        case "EXPIRED": self = .expired
        case "SKIPPED": self = .skipped
        default: return nil
        }
    }

    /// 显式保留未知值的解析入口（业务分支使用该入口，未知不会退化为 nil）
    static func parse(serverValue: String?) -> ActivationSessionState? {
        guard let serverValue, !serverValue.isEmpty else { return nil }
        return ActivationSessionState(serverValue: serverValue) ?? .unknown(raw: serverValue)
    }

    /// 服务端原始值（用于脱敏日志分类）
    var rawServerValue: String? {
        switch self {
        case .issued: return "ISSUED"
        case .scanned: return "SCANNED"
        case .bound: return "BOUND"
        case .cancelled: return "CANCELLED"
        case .expired: return "EXPIRED"
        case .skipped: return "SKIPPED"
        case .unknown(let raw): return raw
        }
    }
}

enum ActivationBindingStatus: String, Equatable {
    case pending = "PENDING"
    case succeeded = "SUCCEEDED"
    case failed = "FAILED"

    init?(serverValue: String?) {
        guard let serverValue else { return nil }
        self.init(rawValue: serverValue.uppercased())
    }
}

/// 扫码后服务端返回的最小待确认车辆信息（不落盘、不写日志）
struct VehicleBindingSession: Equatable, Identifiable {
    let sessionId: String
    let vin: String?
    let state: ActivationSessionState?
    /// 会话过期时间（epoch 毫秒，经 `@FlexibleTimestamp` 归一）；nil 不本地判过期，交给服务端
    let expiresAt: Int64?
    /// 是否已由**当前账号**认领（IOV-TSP-DSN-CR-017 `ScanActivationSessionVo.claimed`，扫码成功恒为 `true`）
    ///
    /// 该字段不参与本地可提交判定：被其他账号占用由服务端 `401104` 表达（见
    /// `VehicleBindingFailure.sessionClaimed`），不得反向解释为“被他人占用”而拦截确认。
    let claimed: Bool?

    var id: String { sessionId }

    /// 本地过期判断（epoch 毫秒 → Date）；nil 表示不判过期
    func isLocallyExpired(now: Date) -> Bool {
        guard let expiresAt else { return false }
        let expiresDate = Date(timeIntervalSince1970: TimeInterval(expiresAt) / 1000.0)
        return expiresDate <= now
    }

    /// 仅 SCANNED + 未本地过期才允许确认（D-011-2 §4.1）
    func canConfirm(now: Date) -> Bool {
        blockReason(now: now) == nil
    }

    /// 不可提交的原因（nil = 可提交）；供 UI 渲染对应提示与「重新扫码」
    func blockReason(now: Date) -> VehicleBindingSessionBlockReason? {
        switch state {
        case .scanned:
            if isLocallyExpired(now: now) { return .expired }
            return nil
        case .bound: return .bound
        case .expired: return .expired
        case .cancelled: return .cancelled
        case .skipped: return .skipped
        case .issued: return .issued
        case .unknown: return .unknown
        case .none: return .unknown
        }
    }
}

/// 会话不可提交的原因（对应文案 key，zh-Hans / en 同步登记）
enum VehicleBindingSessionBlockReason: Equatable {
    case expired
    case bound
    case cancelled
    case skipped
    case issued
    case unknown

    var localizationKey: String {
        switch self {
        case .expired: return "vehicle_binding_session_expired_hint"
        case .bound: return "vehicle_binding_bound"
        case .cancelled: return "vehicle_binding_session_cancelled_hint"
        case .skipped: return "vehicle_binding_session_skipped_hint"
        case .issued: return "vehicle_binding_session_issued_hint"
        case .unknown: return "vehicle_binding_session_unknown_hint"
        }
    }
}

/// 登录门禁提示（IOS-APP-DSN-CR-011 D-011-1）
enum VehicleBindingLoginHint: String, Equatable, Identifiable {
    var id: String { rawValue }
    /// 未登录就点了扫码：绑定车辆需先登录
    case loginRequired
    /// 登录取消 / 超时后仍有待续跑二维码：请重新扫码
    case rescanRequired

    var localizationKey: String {
        switch self {
        case .loginRequired: return "vehicle_binding_login_required_hint"
        case .rescanRequired: return "vehicle_binding_rescan_required_hint"
        }
    }
}

/// 扫码失败弹窗按钮分类（IOS-APP-DSN-CR-011 D-011-2 §4.3）
enum ScanFailureAction: String, Equatable {
    /// 可重试：复用同一次 qrToken（不新建幂等键）
    case retryWithSameToken
    /// 需刷新二维码：仅「我知道了」
    case needsNewQr
    /// 需人工：仅「我知道了」，引导交付人员/客服
    case needsManual
    /// 需登录：「去登录」，登录后续跑一次
    case needsLogin

    /// 是否展示「重试」按钮
    var allowsRetry: Bool { self == .retryWithSameToken }
    /// 是否展示「去登录」按钮
    var allowsLogin: Bool { self == .needsLogin }
    /// 是否展示「重新扫码」按钮
    var allowsRescan: Bool { self == .needsNewQr }
}

// MARK: - 绑定操作状态

/// 绑定操作状态（与持久关系分离）。
enum VehicleBindingOperationState: Equatable {
    case idle
    case submitting
    /// 结果未知：只能按原 operationId 或原幂等键恢复，不得新建绑定
    case resultUnknown(operationId: String?)
    case succeeded(relationId: String?)
    case failed(VehicleBindingFailure)

    var isSubmitting: Bool {
        if case .submitting = self { return true }
        return false
    }

    var isSucceeded: Bool {
        if case .succeeded = self { return true }
        return false
    }
}

// MARK: - 页面派生状态

/// 车辆页的展示态（由关系 + 登录状态派生，View 不再自行拼条件）。
enum VehiclePageDisplayState: Equatable {
    case loading
    case unbound
    case unknown
    case boundLoginPending
    case bound

    static func derive(relationship: VehicleRelationshipState,
                       login: VehicleLoginState) -> VehiclePageDisplayState {
        switch relationship {
        case .loading:
            return .loading
        case .unboundForCurrentAccount:
            return .unbound
        case .unknown:
            return .unknown
        case .bound:
            switch login {
            case .succeeded:
                return .bound
            case .pending, .failed, .unknown:
                return .boundLoginPending
            }
        }
    }
}

// MARK: - VIN 规范化与校验

/// VIN 规范化与合法性（对齐 IOV-TSP-DSN-CR-018 D018-01 / ISO 3779）。
/// 服务端要求 trim + 大写后为 17 位 `[A-HJ-NPR-Z0-9]`，非法值直接 401112 且不查库。
/// App 在发起关系查询前先本地校验，避免把非法/缺失 VIN 当作“未绑定”。
enum VehicleVin {
    static func normalize(_ vin: String?) -> String? {
        guard let vin else { return nil }
        let normalized = vin.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        return normalized.isEmpty ? nil : normalized
    }

    static func isValid(_ vin: String?) -> Bool {
        guard let normalized = normalize(vin), normalized.count == 17 else { return false }
        let allowed = CharacterSet(charactersIn: "ABCDEFGHJKLMNPRSTUVWXYZ0123456789")
        return normalized.unicodeScalars.allSatisfy { allowed.contains($0) }
    }
}

// MARK: - VIN 脱敏

enum VehicleVinMask {
    /// 脱敏展示：保留前 3 位与后 4 位，其余用 `****` 代替；无效值不构造内容。
    static func mask(_ vin: String?) -> String? {
        guard let trimmed = VehicleVin.normalize(vin) else { return nil }
        guard trimmed.count > 7 else { return "****" }
        return "\(trimmed.prefix(3))****\(trimmed.suffix(4))"
    }
}
