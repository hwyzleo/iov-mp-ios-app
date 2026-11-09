//
//  KeychainCredentialStore.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-001 on 2026/11/9.
//

import Foundation
import KeychainAccess

/// Keychain 凭证存储（IOS-APP-DSN-CR-001 RD-001-4）
/// Access Token / Refresh Token 只允许保存在 Keychain。
final class KeychainCredentialStore: CredentialStoring {

    /// 生产环境 Keychain service
    static let defaultService = "net.hwyz.iov.mp.app.auth"
    /// 默认账户标识
    static let defaultAccount = "auth.session"

    private let keychain: KeychainAccess.Keychain
    private let account: String

    init(service: String = KeychainCredentialStore.defaultService,
         account: String = KeychainCredentialStore.defaultAccount) {
        self.keychain = KeychainAccess.Keychain(service: service)
        self.account = account
    }

    func loadSession() throws -> AuthSession? {
        guard let data = try keychain.getData(account) else {
            return nil
        }
        do {
            return try JSONDecoder().decode(AuthSession.self, from: data)
        } catch {
            // 无法解码的脏数据视为不存在，并按安全策略清除
            try? keychain.remove(account)
            throw AuthError.credentialPersistenceFailed
        }
    }

    func save(_ session: AuthSession) throws {
        do {
            let data = try JSONEncoder().encode(session)
            try keychain.set(data, key: account)
        } catch {
            throw AuthError.credentialPersistenceFailed
        }
    }

    func remove() throws {
        do {
            try keychain.remove(account)
        } catch {
            throw AuthError.credentialPersistenceFailed
        }
    }
}
