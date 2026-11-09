//
//  AuthSession.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-001 on 2026/11/9.
//

import Foundation

/// 认证会话（IOS-APP-DSN-CR-001 §4.2）
/// 仅凭证相关字段进入 Keychain，用户资料仍保存在 Realm。
struct AuthSession: Codable, Equatable {
    /// 访问令牌，非空，仅存 Keychain
    let accessToken: String
    /// 刷新令牌，非空，仅存 Keychain
    let refreshToken: String
    /// 访问令牌过期时刻，由登录时刻与 accessTokenTtl 计算
    let accessTokenExpiresAt: Date
    /// 会话标识，与登录响应一致
    let sessionId: String
    /// 用户标识，与用户资料关联
    let userId: String

    /// 会话是否已过期
    func isExpired(now: Date = Date()) -> Bool {
        accessTokenExpiresAt.timeIntervalSince(now) <= 0
    }

    /// 会话是否即将过期（剩余时间小于指定秒数）
    func isExpiring(within threshold: TimeInterval, now: Date = Date()) -> Bool {
        accessTokenExpiresAt.timeIntervalSince(now) <= threshold
    }

    /// 会话字段是否自洽（不含新登录响应的严格校验）
    var hasCredentials: Bool {
        !accessToken.isEmpty && !refreshToken.isEmpty
    }
}
