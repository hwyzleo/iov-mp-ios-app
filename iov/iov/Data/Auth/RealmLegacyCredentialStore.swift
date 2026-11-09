//
//  RealmLegacyCredentialStore.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-001 on 2026/11/9.
//

import Foundation
import RealmSwift

/// 旧版本 Realm 凭证读取与清理（一次性迁移专用）
/// 仅保留读取旧 Token 和清除旧 Token 的能力，不再承担 Token 事实存储职责。
final class RealmLegacyCredentialStore: LegacyCredentialStoring {

    private let realmProvider: () -> Realm?

    init(realmProvider: @escaping () -> Realm? = { RealmManager.user.realm }) {
        self.realmProvider = realmProvider
    }

    func loadLegacyCredentials() -> LegacyCredentials? {
        guard let realm = realmProvider() else { return nil }
        realm.refresh()
        guard let user = realm.objects(UserManager.self).first, !user.isInvalidated else {
            return nil
        }
        guard !user.token.isEmpty || !user.refreshToken.isEmpty else {
            return nil
        }
        return LegacyCredentials(
            accessToken: user.token,
            refreshToken: user.refreshToken,
            expiresAt: user.tokenExpiresAt,
            userId: user.userId,
            sessionId: user.sessionId
        )
    }

    func clearLegacyCredentials() -> Bool {
        guard let realm = realmProvider() else { return false }
        let users = realm.objects(UserManager.self).filter { !$0.isInvalidated }
        let snapshot = Array(users)
        do {
            try realm.write {
                for user in snapshot where !user.isInvalidated {
                    user.token = ""
                    user.refreshToken = ""
                    user.tokenExpiresAt = nil
                }
            }
            return true
        } catch {
            return false
        }
    }
}
