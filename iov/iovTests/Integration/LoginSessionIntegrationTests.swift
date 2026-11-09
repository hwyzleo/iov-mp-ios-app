//
//  LoginSessionIntegrationTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-001 on 2026/11/9.
//

import XCTest
@testable import iov

/// TC-001-5 / TC-001-6：真实 Keychain + 临时 Realm 的会话持久化与迁移
final class LoginSessionIntegrationTests: XCTestCase {

    private var service: String!
    private var account: String!

    override func setUp() {
        super.setUp()
        service = "net.hwyz.iov.mp.app.tests.auth.\(UUID().uuidString)"
        account = "auth.session"
    }

    override func tearDown() {
        try? KeychainCredentialStore(service: service, account: account).remove()
        super.tearDown()
    }

    func testKeychainRoundTripWithRealStore() throws {
        let repository = AuthSessionRepository(
            credentialStore: KeychainCredentialStore(service: service, account: account),
            legacyStore: FakeLegacyCredentialStore()
        )

        try repository.saveSession(makeSession())
        XCTAssertTrue(repository.hasSession())
        XCTAssertEqual(repository.currentAccessToken(), "access-token-1")

        // 新实例重新读取，验证真实持久化
        let reloaded = AuthSessionRepository(
            credentialStore: KeychainCredentialStore(service: service, account: account),
            legacyStore: FakeLegacyCredentialStore()
        )
        XCTAssertEqual(reloaded.loadSession()?.refreshToken, "refresh-token-1")
        XCTAssertEqual(reloaded.loadSession()?.userId, "user-1")

        reloaded.clearSession()
        XCTAssertNil(try? KeychainCredentialStore(service: service, account: account).loadSession())
    }

    func testLegacyRealmMigrationIntoRealKeychain() throws {
        let factory = TempRealmFactory()
        defer { factory.cleanup() }
        XCTAssertTrue(factory.seedLegacyUser())

        let repository = AuthSessionRepository(
            credentialStore: KeychainCredentialStore(service: service, account: account),
            legacyStore: RealmLegacyCredentialStore(realmProvider: { factory.makeRealm() })
        )

        let session = repository.loadSession()

        XCTAssertEqual(session?.accessToken, "legacy-access")
        XCTAssertEqual(session?.refreshToken, "legacy-refresh")
        XCTAssertEqual(session?.userId, "legacy-user")

        let user = factory.readUser()
        XCTAssertEqual(user?.token, "", "迁移成功后必须清除 Realm 中的 Access Token")
        XCTAssertEqual(user?.refreshToken, "", "迁移成功后必须清除 Realm 中的 Refresh Token")
        XCTAssertNil(user?.tokenExpiresAt)
        XCTAssertEqual(user?.nickname, "legacy-nick", "非凭证资料不得被删除")

        // 迁移后只读 Keychain，不再双写
        let reloaded = try? KeychainCredentialStore(service: service, account: account).loadSession()
        XCTAssertEqual(reloaded?.accessToken, "legacy-access")
    }

    func testMigrationFailureFallsBackToLogin() throws {
        let factory = TempRealmFactory()
        defer { factory.cleanup() }
        XCTAssertTrue(factory.seedLegacyUser(refreshToken: ""))

        let repository = AuthSessionRepository(
            credentialStore: KeychainCredentialStore(service: service, account: account),
            legacyStore: RealmLegacyCredentialStore(realmProvider: { factory.makeRealm() })
        )

        XCTAssertNil(repository.loadSession())
        XCTAssertFalse(repository.hasSession())
        XCTAssertEqual(factory.readUser()?.token, "", "无法安全迁移的旧凭证必须清除")
        XCTAssertNil(try? KeychainCredentialStore(service: service, account: account).loadSession())
    }
}
