//
//  KeychainCredentialStore.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-001 on 2026/11/9.
//

import Foundation
import Security
import KeychainAccess

/// Keychain 凭证存储（IOS-APP-DSN-CR-001 RD-001-4；IOS-APP-DSN-CR-011 D-011-5）
/// Access Token / Refresh Token 只允许保存在 Keychain，且必须带
/// `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`（不进 iCloud Keychain、不可迁移到新设备）。
final class KeychainCredentialStore: CredentialStoring {

    /// 生产环境 Keychain service
    static let defaultService = "net.hwyz.iov.mp.app.auth"
    /// 默认账户标识
    static let defaultAccount = "auth.session"
    /// 明确的设备内可访问级别（写死，防库默认值回退）
    static let accessibilityLevel = KeychainAccess.Accessibility.afterFirstUnlockThisDeviceOnly

    private let keychain: KeychainAccess.Keychain
    private let account: String

    init(service: String = KeychainCredentialStore.defaultService,
         account: String = KeychainCredentialStore.defaultAccount) {
        self.keychain = KeychainAccess.Keychain(service: service)
            .accessibility(KeychainCredentialStore.accessibilityLevel)
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
            #if DEBUG
            verifyAccessibility()
            #endif
        } catch {
            throw AuthError.credentialPersistenceFailed
        }
    }

    #if DEBUG
    /// 写入后复核 `kSecAttrAccessible`，防止 KeychainAccess 默认值回退（仅 DEBUG 断言）。
    private func verifyAccessibility() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychain.service,
            kSecAttrAccount as String: account,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
              let attributes = item as? [String: Any],
              let accessible = attributes[kSecAttrAccessible as String] as? String else {
            // 模拟器/无钥匙串环境读不到属性时不断言（不阻断 DEBUG 运行）
            return
        }
        assert(accessible == (kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String),
               "Keychain accessibility 必须为 AfterFirstUnlockThisDeviceOnly，实际: \(accessible)")
    }
    #endif

    func remove() throws {
        do {
            try keychain.remove(account)
        } catch {
            throw AuthError.credentialPersistenceFailed
        }
    }
}
