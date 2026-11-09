//
//  AuthError.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-001 on 2026/11/9.
//

import Foundation

/// 认证错误语义（IOS-APP-DSN-CR-001 §4.3）
/// UI 只消费本地化文案；日志只记录类别与脱敏上下文。
enum AuthError: Error, Equatable {
    /// 本地输入不合法（手机号、协议、验证码格式）
    case invalidInput
    /// 网络不可用或临时服务故障
    case networkUnavailable
    /// 验证码错误或已过期
    case verificationCodeInvalid
    /// 服务端拒绝认证（账号、风控等）
    case authenticationRejected
    /// 响应要求额外挑战（challengeRequired / fallbackRequired），本 CR 不支持
    case challengeUnsupported
    /// 服务端响应不满足当前契约
    case invalidServerResponse
    /// 凭证持久化失败
    case credentialPersistenceFailed
    /// Token 刷新失败（未导致会话失效）
    case tokenRefreshFailed
    /// 会话已失效，需要重新认证
    case sessionExpired
    /// 未归类错误
    case unknown

    /// 本地化文案 key
    var localizationKey: String {
        switch self {
        case .invalidInput: return "auth_error_invalid_input"
        case .networkUnavailable: return "auth_error_network_unavailable"
        case .verificationCodeInvalid: return "auth_error_verification_code_invalid"
        case .authenticationRejected: return "auth_error_authentication_rejected"
        case .challengeUnsupported: return "auth_error_challenge_unsupported"
        case .invalidServerResponse: return "auth_error_invalid_server_response"
        case .credentialPersistenceFailed: return "auth_error_credential_persistence_failed"
        case .tokenRefreshFailed: return "auth_error_token_refresh_failed"
        case .sessionExpired: return "auth_error_session_expired"
        case .unknown: return "auth_error_unknown"
        }
    }

    /// 已本地化的用户文案
    var localizedMessage: String {
        NSLocalizedString(localizationKey, comment: "认证错误提示")
    }

    /// 技术日志类别（不含任何敏感数据）
    var logCategory: String {
        String(describing: self)
    }
}

// MARK: - 服务端错误码映射

/// 服务端认证相关错误码
enum AuthServerCode {
    /// Token / Refresh Token / 会话失效
    static let sessionExpired = "701304"
    /// 验证码错误或过期
    static let verificationCodeInvalid = "701201"
    /// 认证被拒绝
    static let authenticationRejected = "701403"
    /// 需要额外挑战
    static let challengeRequired = "701409"
}

extension AuthError {
    /// 将网络层错误映射为认证错误
    static func mapNetworkError(_ error: Error) -> AuthError {
        if let authError = error as? AuthError {
            return authError
        }
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return .networkUnavailable
        }
        if nsError.domain == "NetworkAPIError" {
            return .invalidServerResponse
        }
        return .unknown
    }

    /// 将服务端业务码映射为认证错误
    static func mapServerCode(_ code: String) -> AuthError {
        switch code {
        case AuthServerCode.sessionExpired:
            return .sessionExpired
        case AuthServerCode.verificationCodeInvalid:
            return .verificationCodeInvalid
        case AuthServerCode.authenticationRejected:
            return .authenticationRejected
        case AuthServerCode.challengeRequired:
            return .challengeUnsupported
        default:
            return .authenticationRejected
        }
    }
}
