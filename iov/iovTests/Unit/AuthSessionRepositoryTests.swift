//
//  AuthSessionRepositoryTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-001 on 2026/11/9.
//

import XCTest
@testable import iov

/// TC-001-6：Keychain 恢复、旧 Realm 迁移成功、迁移失败和旧 Token 清理
final class AuthSessionRepositoryTests: XCTestCase {

    func testKeychainSessionIsPreferred() {
        let credentialStore = FakeCredentialStore()
        credentialStore.stored = makeSession(accessToken: "keychain-token")
        let legacyStore = FakeLegacyCredentialStore()
        legacyStore.legacy = LegacyCredentials(
            accessToken: "legacy-token",
            refreshToken: "legacy-refresh",
            expiresAt: Date().addingTimeInterval(600),
            userId: "legacy-user",
            sessionId: "legacy-session"
        )

        let repository = AuthSessionRepository(credentialStore: credentialStore, legacyStore: legacyStore)
        let session = repository.loadSession()

        XCTAssertEqual(session?.accessToken, "keychain-token")
        XCTAssertEqual(legacyStore.clearCount, 0)
    }

    func testLegacyMigrationWritesKeychainAndClearsRealmTokens() {
        let credentialStore = FakeCredentialStore()
        let legacyStore = FakeLegacyCredentialStore()
        legacyStore.legacy = LegacyCredentials(
            accessToken: "legacy-access",
            refreshToken: "legacy-refresh",
            expiresAt: Date().addingTimeInterval(600),
            userId: "legacy-user",
            sessionId: "legacy-session"
        )

        let repository = AuthSessionRepository(credentialStore: credentialStore, legacyStore: legacyStore)
        let session = repository.loadSession()

        XCTAssertEqual(session?.accessToken, "legacy-access")
        XCTAssertEqual(session?.refreshToken, "legacy-refresh")
        XCTAssertEqual(credentialStore.stored?.accessToken, "legacy-access")
        XCTAssertEqual(legacyStore.clearCount, 1)
        XCTAssertNil(legacyStore.legacy, "迁移成功后必须清除旧 Realm Token")
    }

    func testLegacyMigrationFailureClearsLegacyAndRequiresLogin() {
        let credentialStore = FakeCredentialStore()
        credentialStore.saveError = AuthError.credentialPersistenceFailed
        let legacyStore = FakeLegacyCredentialStore()
        legacyStore.legacy = LegacyCredentials(
            accessToken: "legacy-access",
            refreshToken: "legacy-refresh",
            expiresAt: Date().addingTimeInterval(600),
            userId: "legacy-user",
            sessionId: "legacy-session"
        )

        let repository = AuthSessionRepository(credentialStore: credentialStore, legacyStore: legacyStore)

        XCTAssertNil(repository.loadSession(), "迁移失败不得发布伪造登录态")
        XCTAssertFalse(repository.hasSession())
        XCTAssertEqual(legacyStore.clearCount, 1)
        XCTAssertNil(credentialStore.stored)
    }

    func testIncompleteLegacyCredentialsAreCleared() {
        let credentialStore = FakeCredentialStore()
        let legacyStore = FakeLegacyCredentialStore()
        legacyStore.legacy = LegacyCredentials(
            accessToken: "legacy-access",
            refreshToken: "",
            expiresAt: Date().addingTimeInterval(600),
            userId: "legacy-user",
            sessionId: "legacy-session"
        )

        let repository = AuthSessionRepository(credentialStore: credentialStore, legacyStore: legacyStore)

        XCTAssertNil(repository.loadSession())
        XCTAssertEqual(legacyStore.clearCount, 1)
        XCTAssertNil(credentialStore.stored)
    }

    func testLegacySessionWithoutExpiryIsTreatedAsExpiring() {
        let credentialStore = FakeCredentialStore()
        let legacyStore = FakeLegacyCredentialStore()
        legacyStore.legacy = LegacyCredentials(
            accessToken: "legacy-access",
            refreshToken: "legacy-refresh",
            expiresAt: nil,
            userId: "legacy-user",
            sessionId: "legacy-session"
        )

        let repository = AuthSessionRepository(credentialStore: credentialStore, legacyStore: legacyStore)
        XCTAssertNotNil(repository.loadSession())
        XCTAssertTrue(repository.isAccessTokenExpiring(within: 300))
    }

    func testSaveSessionFailureThrowsCredentialPersistenceFailed() {
        let credentialStore = FakeCredentialStore()
        credentialStore.saveError = NSError(domain: "Keychain", code: -1)
        let repository = AuthSessionRepository(credentialStore: credentialStore, legacyStore: FakeLegacyCredentialStore())

        XCTAssertThrowsError(try repository.saveSession(makeSession())) { error in
            XCTAssertEqual(error as? AuthError, .credentialPersistenceFailed)
        }
        XCTAssertFalse(repository.hasSession())
    }

    func testSaveSessionRejectsIncompleteSession() {
        let repository = AuthSessionRepository(credentialStore: FakeCredentialStore(), legacyStore: FakeLegacyCredentialStore())
        XCTAssertThrowsError(try repository.saveSession(makeSession(accessToken: ""))) { error in
            XCTAssertEqual(error as? AuthError, .invalidServerResponse)
        }
    }

    func testClearSessionRemovesCredentials() throws {
        let credentialStore = FakeCredentialStore()
        let repository = AuthSessionRepository(credentialStore: credentialStore, legacyStore: FakeLegacyCredentialStore())
        try repository.saveSession(makeSession())
        XCTAssertTrue(repository.hasSession())

        repository.clearSession()

        XCTAssertFalse(repository.hasSession())
        XCTAssertNil(credentialStore.stored)
        XCTAssertEqual(repository.currentAccessToken(), "")
    }

    func testAccessTokenExpiringUsesSessionExpiry() throws {
        let repository = AuthSessionRepository(credentialStore: FakeCredentialStore(), legacyStore: FakeLegacyCredentialStore())
        try repository.saveSession(makeSession(expiresIn: 100))

        XCTAssertTrue(repository.isAccessTokenExpiring(within: 300))
        XCTAssertFalse(repository.isAccessTokenExpiring(within: 10))
    }
}
