//
//  AuthSessionRepositoryProtocol.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-001 on 2026/11/9.
//

import Foundation

/// 凭证存储抽象（Keychain 实现或测试替身）
protocol CredentialStoring {
    func loadSession() throws -> AuthSession?
    func save(_ session: AuthSession) throws
    func remove() throws
}

/// 旧版本 Realm 凭证
struct LegacyCredentials: Equatable {
    var accessToken: String
    var refreshToken: String
    var expiresAt: Date?
    var userId: String
    var sessionId: String

    /// 旧凭证完整性：Access Token、Refresh Token 非空
    var isComplete: Bool {
        !accessToken.isEmpty && !refreshToken.isEmpty
    }
}

/// 旧凭证存储抽象（用于一次性迁移）
protocol LegacyCredentialStoring {
    func loadLegacyCredentials() -> LegacyCredentials?
    /// 清除旧 Realm Token 字段，保留非凭证用户资料
    func clearLegacyCredentials() -> Bool
}

/// 认证会话仓储（IOS-APP-DSN-CR-001 §5.5）
protocol AuthSessionRepositoryProtocol: AnyObject {
    /// 读取当前会话；Keychain 优先，必要时执行一次性迁移
    func loadSession() -> AuthSession?
    /// 保存会话（先写凭证，成功后调用方才能发布登录状态）
    func saveSession(_ session: AuthSession) throws
    /// 清除会话
    func clearSession()
    /// 当前访问令牌（未登录返回空）
    func currentAccessToken() -> String
    /// 是否具备可恢复的会话
    func hasSession() -> Bool
    /// 访问令牌是否即将过期
    func isAccessTokenExpiring(within threshold: TimeInterval) -> Bool
}
