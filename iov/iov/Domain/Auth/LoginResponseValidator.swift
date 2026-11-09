//
//  LoginResponseValidator.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-001 on 2026/11/9.
//

import Foundation

/// 登录响应校验（IOS-APP-DSN-CR-001 §4.2 / §6.4）
/// 只有满足当前契约的响应才能生成有效 AuthSession。
enum LoginResponseValidator {

    /// 校验登录响应并生成会话
    static func session(from response: TspResponse<LoginResponse>, now: Date = Date()) -> Result<AuthSession, AuthError> {
        guard response.isSuccess else {
            return .failure(AuthError.mapServerCode(response.code))
        }

        guard let data = response.data else {
            return .failure(.invalidServerResponse)
        }

        // 挑战语义本 CR 不支持，安全拒绝
        if data.challengeRequired == true || data.fallbackRequired == true {
            return .failure(.challengeUnsupported)
        }

        guard let accessToken = data.accessToken, !accessToken.isEmpty,
              let refreshToken = data.refreshToken, !refreshToken.isEmpty,
              let ttl = data.accessTokenTtl, ttl > 0 else {
            return .failure(.invalidServerResponse)
        }

        let sessionId = data.sessionId ?? ""
        let userId = data.userId
        guard !sessionId.isEmpty, !userId.isEmpty else {
            return .failure(.invalidServerResponse)
        }

        let expiresAt = now.addingTimeInterval(TimeInterval(ttl))
        return .success(
            AuthSession(
                accessToken: accessToken,
                refreshToken: refreshToken,
                accessTokenExpiresAt: expiresAt,
                sessionId: sessionId,
                userId: userId
            )
        )
    }

    /// 校验刷新响应；刷新响应不要求 sessionId / userId 变化，但必须携带双 Token 与有效 TTL
    static func refreshedSession(
        from response: TspResponse<LoginResponse>,
        previous: AuthSession,
        now: Date = Date()
    ) -> Result<AuthSession, AuthError> {
        guard response.isSuccess else {
            let mapped = AuthError.mapServerCode(response.code)
            return .failure(mapped == .authenticationRejected ? .sessionExpired : mapped)
        }

        guard let data = response.data else {
            return .failure(.invalidServerResponse)
        }

        if data.challengeRequired == true || data.fallbackRequired == true {
            return .failure(.challengeUnsupported)
        }

        guard let accessToken = data.accessToken, !accessToken.isEmpty,
              let ttl = data.accessTokenTtl, ttl > 0 else {
            return .failure(.invalidServerResponse)
        }

        let refreshToken = (data.refreshToken?.isEmpty == false) ? data.refreshToken! : previous.refreshToken
        let sessionId = (data.sessionId?.isEmpty == false) ? data.sessionId! : previous.sessionId
        let userId = data.userId.isEmpty ? previous.userId : data.userId
        let expiresAt = now.addingTimeInterval(TimeInterval(ttl))

        return .success(
            AuthSession(
                accessToken: accessToken,
                refreshToken: refreshToken,
                accessTokenExpiresAt: expiresAt,
                sessionId: sessionId,
                userId: userId
            )
        )
    }
}
