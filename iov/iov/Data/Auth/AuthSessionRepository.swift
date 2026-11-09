//
//  AuthSessionRepository.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-001 on 2026/11/9.
//

import Foundation

/// 认证会话仓储（IOS-APP-DSN-CR-001 RD-001-4 / RD-001-5 / §5.5）
/// - 读取顺序：Keychain → 旧 Realm 一次性迁移
/// - 写入顺序：仅写 Keychain，迁移成功后清除旧 Realm Token，不做双写
final class AuthSessionRepository: AuthSessionRepositoryProtocol {

    private let credentialStore: CredentialStoring
    private let legacyStore: LegacyCredentialStoring
    private let lock = NSLock()

    /// 会话缓存，避免每次请求访问 Keychain
    private var cachedSession: AuthSession?
    /// 迁移只尝试一次
    private var didAttemptMigration = false

    init(credentialStore: CredentialStoring,
         legacyStore: LegacyCredentialStoring) {
        self.credentialStore = credentialStore
        self.legacyStore = legacyStore
    }

    func loadSession() -> AuthSession? {
        lock.lock()
        defer { lock.unlock() }

        if let cachedSession = cachedSession, cachedSession.hasCredentials {
            return cachedSession
        }

        if let session = try? credentialStore.loadSession(), session.hasCredentials {
            cachedSession = session
            return session
        }

        return migrateLegacyIfNeeded()
    }

    func saveSession(_ session: AuthSession) throws {
        guard session.hasCredentials else {
            throw AuthError.invalidServerResponse
        }
        do {
            try credentialStore.save(session)
        } catch {
            throw AuthError.credentialPersistenceFailed
        }
        lock.lock()
        cachedSession = session
        lock.unlock()
    }

    func clearSession() {
        lock.lock()
        cachedSession = nil
        lock.unlock()
        try? credentialStore.remove()
    }

    func currentAccessToken() -> String {
        return loadSession()?.accessToken ?? ""
    }

    func hasSession() -> Bool {
        return loadSession()?.hasCredentials == true
    }

    func isAccessTokenExpiring(within threshold: TimeInterval) -> Bool {
        guard let session = loadSession() else { return true }
        return session.isExpiring(within: threshold)
    }

    // MARK: - 旧 Realm 一次性迁移

    private func migrateLegacyIfNeeded() -> AuthSession? {
        guard !didAttemptMigration else { return nil }
        didAttemptMigration = true

        guard let legacy = legacyStore.loadLegacyCredentials() else {
            return nil
        }

        // 旧字段不完整或迁移失败：按批准策略清除旧 Token 并要求重新登录
        guard legacy.isComplete else {
            _ = legacyStore.clearLegacyCredentials()
            return nil
        }

        let session = AuthSession(
            accessToken: legacy.accessToken,
            refreshToken: legacy.refreshToken,
            // 旧版本未保存过期时间时视为已过期，交由刷新流程处理
            accessTokenExpiresAt: legacy.expiresAt ?? Date.distantPast,
            sessionId: legacy.sessionId,
            userId: legacy.userId
        )

        do {
            try credentialStore.save(session)
        } catch {
            // 迁移失败：不得发布伪造登录态，并清除无法安全迁移的旧凭证
            _ = legacyStore.clearLegacyCredentials()
            return nil
        }

        // Keychain 写入成功后才清除旧 Realm Token，且不恢复双写
        _ = legacyStore.clearLegacyCredentials()
        cachedSession = session
        return session
    }
}
