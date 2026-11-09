//
//  LoginFlowIntegrationTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-001 on 2026/11/9.
//

import Combine
import XCTest
@testable import iov

/// TC-001-3 / TC-001-5 / TC-001-8 / TC-001-9：登录流程与真实 Keychain 会话集成
final class LoginFlowIntegrationTests: XCTestCase {

    private var service: String!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        service = "net.hwyz.iov.mp.app.tests.flow.\(UUID().uuidString)"
    }

    override func tearDown() {
        try? KeychainCredentialStore(service: service, account: KeychainCredentialStore.defaultAccount).remove()
        cancellables.removeAll()
        super.tearDown()
    }

    private func makeHarness() -> (model: LoginModel, intent: LoginIntent, service: FakeLoginService, authState: FakeAuthPublishing, repository: AuthSessionRepository) {
        let model = LoginModel()
        let loginService = FakeLoginService()
        let repository = AuthSessionRepository(
            credentialStore: KeychainCredentialStore(service: service, account: KeychainCredentialStore.defaultAccount),
            legacyStore: FakeLegacyCredentialStore()
        )
        let authState = FakeAuthPublishing()
        let intent = LoginIntent(
            model: model,
            loginService: loginService,
            sessionRepository: repository,
            authState: authState,
            profileRefresher: FakeProfileRefresher(),
            profileUpdater: { _ in }
        )
        return (model, intent, loginService, authState, repository)
    }

    private func prepareVerifyStep(_ model: LoginModel) {
        model.updateAgree(true)
        model.updateMobile("138 0013 8000")
        model.completeSendingCode(
            countryRegionCode: "+86",
            mobile: "138 0013 8000",
            resendAvailableAt: Date().addingTimeInterval(LoginModel.resendInterval)
        )
    }

    func testSuccessfulLoginPersistsSessionInKeychain() {
        let harness = makeHarness()
        prepareVerifyStep(harness.model)
        harness.service.enqueueLogin(.success(makeLoginResponsePayload(code: "000000", data: makeLoginResponse())))

        harness.intent.onTapVerifyCodeLoginButton(countryRegionCode: "+86", mobile: harness.model.mobile, verifyCode: "123456")

        XCTAssertEqual(harness.authState.completedCount, 1)
        XCTAssertEqual(harness.model.step, .inputVerifyCode)

        let persisted = try? KeychainCredentialStore(service: service, account: KeychainCredentialStore.defaultAccount).loadSession()
        XCTAssertEqual(persisted?.accessToken, "access-token-1")
        XCTAssertEqual(persisted?.refreshToken, "refresh-token-1")
        XCTAssertTrue(harness.repository.hasSession())
    }

    func testCredentialSaveFailureBlocksLoginPublication() {
        let harness = makeHarness()
        prepareVerifyStep(harness.model)
        harness.service.enqueueLogin(.success(makeLoginResponsePayload(code: "000000", data: makeLoginResponse())))

        // 用不可写账户模拟 Keychain 保存失败
        let failingStore = FailingCredentialStore()
        let failingIntent = LoginIntent(
            model: harness.model,
            loginService: harness.service,
            sessionRepository: AuthSessionRepository(credentialStore: failingStore, legacyStore: FakeLegacyCredentialStore()),
            authState: harness.authState,
            profileRefresher: FakeProfileRefresher(),
            profileUpdater: { _ in }
        )

        failingIntent.onTapVerifyCodeLoginButton(countryRegionCode: "+86", mobile: harness.model.mobile, verifyCode: "123456")

        XCTAssertEqual(harness.authState.completedCount, 0)
        XCTAssertEqual(harness.model.errorMessage, AuthError.credentialPersistenceFailed.localizedMessage)
        XCTAssertNil(try? KeychainCredentialStore(service: service, account: KeychainCredentialStore.defaultAccount).loadSession())
    }

    func testRefreshedSessionIsPersistedAndExpiryUpdated() {
        let repository = AuthSessionRepository(
            credentialStore: KeychainCredentialStore(service: service, account: KeychainCredentialStore.defaultAccount),
            legacyStore: FakeLegacyCredentialStore()
        )
        let refresher = FakeTokenRefresher()
        refresher.result = .success(makeLoginResponsePayload(code: "000000", data: makeLoginResponse(["accessToken": "access-token-2", "accessTokenTtl": 7200])))
        let coordinator = TokenRefreshCoordinator(repository: repository, refresher: refresher) {}

        try? repository.saveSession(makeSession(expiresIn: 10))

        let expectation = expectation(description: "刷新完成")
        coordinator.refresh { result in
            if case let .failure(error) = result {
                XCTFail("刷新应成功：\(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)

        let persisted = try? KeychainCredentialStore(service: service, account: KeychainCredentialStore.defaultAccount).loadSession()
        XCTAssertEqual(persisted?.accessToken, "access-token-2")
        XCTAssertFalse(persisted?.isExpiring(within: 300) ?? true)
    }

    func testSessionExpiredClearsKeychainSession() {
        let repository = AuthSessionRepository(
            credentialStore: KeychainCredentialStore(service: service, account: KeychainCredentialStore.defaultAccount),
            legacyStore: FakeLegacyCredentialStore()
        )
        try? repository.saveSession(makeSession())
        let refresher = FakeTokenRefresher()
        refresher.result = .success(makeLoginResponsePayload(code: AuthServerCode.sessionExpired, data: nil))
        let coordinator = TokenRefreshCoordinator(repository: repository, refresher: refresher) {
            repository.clearSession()
        }

        let expectation = expectation(description: "会话失效")
        coordinator.refresh { result in
            XCTAssertEqual(result, .failure(.sessionExpired))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)

        XCTAssertFalse(repository.hasSession())
        XCTAssertNil(try? KeychainCredentialStore(service: service, account: KeychainCredentialStore.defaultAccount).loadSession())
    }

    /// TC-001-9：强制登录完成/取消不重置当前选中的主 Tab
    func testRoutingKeepsSelectedTab() {
        let state = AppGlobalState.shared
        let originalTab = state.selectedTab
        defer {
            state.selectedTab = originalTab
            state.needShowLoginPage = false
        }

        state.selectedTab = 3
        state.handleLoginCompleted()

        XCTAssertTrue(state.isLogin)
        XCTAssertFalse(state.needShowLoginPage, "登录完成必须清除强制登录标记")
        XCTAssertEqual(state.selectedTab, 3)

        state.handleLoginCancelled()

        XCTAssertFalse(state.isLogin)
        XCTAssertFalse(state.needShowLoginPage)
        XCTAssertEqual(state.selectedTab, 3, "取消登录不得重置所选 Tab")
    }
}

/// 保存必定失败的凭证存储替身
final class FailingCredentialStore: CredentialStoring {
    func loadSession() throws -> AuthSession? { return nil }
    func save(_ session: AuthSession) throws { throw AuthError.credentialPersistenceFailed }
    func remove() throws {}
}
