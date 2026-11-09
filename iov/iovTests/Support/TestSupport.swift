//
//  TestSupport.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-001 on 2026/11/9.
//

import Foundation
import RealmSwift
import XCTest
@testable import iov

// MARK: - 登录响应构造

func makeLoginResponse(_ overrides: [String: Any] = [:]) -> LoginResponse {
    var payload: [String: Any] = [
        "userId": "user-1",
        "newUser": false,
        "sessionId": "session-1",
        "accessToken": "access-token-1",
        "accessTokenTtl": 3600,
        "refreshToken": "refresh-token-1",
        "nickname": "tester"
    ]
    overrides.forEach { payload[$0.key] = $0.value }
    let data = try! JSONSerialization.data(withJSONObject: payload)
    return try! JSONDecoder().decode(LoginResponse.self, from: data)
}

func makeLoginResponsePayload(code: String, data: LoginResponse?) -> TspResponse<LoginResponse> {
    return TspResponse(code: code, data: data)
}

func makeAccountInfo(_ overrides: [String: Any] = [:]) -> AccountInfo {
    var payload: [String: Any] = ["userId": "user-1", "nickname": "tester", "avatarUrl": "https://example.com/a.png"]
    overrides.forEach { payload[$0.key] = $0.value }
    let data = try! JSONSerialization.data(withJSONObject: payload)
    return try! JSONDecoder().decode(AccountInfo.self, from: data)
}

func makeSession(accessToken: String = "access-token-1",
                 refreshToken: String = "refresh-token-1",
                 expiresIn: TimeInterval = 3600,
                 sessionId: String = "session-1",
                 userId: String = "user-1") -> AuthSession {
    return AuthSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        accessTokenExpiresAt: Date().addingTimeInterval(expiresIn),
        sessionId: sessionId,
        userId: userId
    )
}

// MARK: - 临时 Realm

/// 为迁移测试提供隔离的 Realm 文件
final class TempRealmFactory {
    let fileURL: URL

    init() {
        fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("iov-legacy-\(UUID().uuidString).realm")
    }

    var configuration: Realm.Configuration {
        return Realm.Configuration(
            fileURL: fileURL,
            schemaVersion: 3,
            objectTypes: [UserManager.self]
        )
    }

    func makeRealm() -> Realm? {
        return try? Realm(configuration: configuration)
    }

    func seedLegacyUser(accessToken: String = "legacy-access",
                        refreshToken: String = "legacy-refresh",
                        expiresAt: Date? = Date().addingTimeInterval(1800),
                        userId: String = "legacy-user",
                        sessionId: String = "legacy-session") -> Bool {
        guard let realm = makeRealm() else { return false }
        do {
            try realm.write {
                let user = realm.create(UserManager.self)
                user.token = accessToken
                user.refreshToken = refreshToken
                user.tokenExpiresAt = expiresAt
                user.userId = userId
                user.sessionId = sessionId
                user.nickname = "legacy-nick"
            }
            return true
        } catch {
            return false
        }
    }

    func readUser() -> UserManager? {
        guard let realm = makeRealm() else { return nil }
        realm.refresh()
        return realm.objects(UserManager.self).first
    }

    func cleanup() {
        try? FileManager.default.removeItem(at: fileURL)
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: fileURL.path + ".lock"))
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: fileURL.path + ".management"))
    }
}

// MARK: - 异步等待

extension XCTestCase {
    /// 等待条件成立（主队列驱动）
    func waitUntil(timeout: TimeInterval = 2, description: String = "condition", condition: @escaping () -> Bool) {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() { return }
            RunLoop.current.run(until: Date().addingTimeInterval(0.02))
        }
        XCTFail("等待超时：\(description)")
    }
}
