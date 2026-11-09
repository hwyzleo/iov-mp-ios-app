//
//  LoginModelStateTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-001 on 2026/11/9.
//

import Combine
import XCTest
@testable import iov

/// TC-001-1 / TC-001-2 / TC-001-3 / TC-001-5：登录交互状态机与提交顺序
final class LoginModelStateTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()

    private struct Harness {
        let model: LoginModel
        let intent: LoginIntent
        let credentialStore: FakeCredentialStore
        let repository: AuthSessionRepository
        let loginService: FakeLoginService
        let authState: FakeAuthPublishing
        let profileRefresher: FakeProfileRefresher
    }

    private func makeHarness(holdSend: Bool = false) -> Harness {
        let model = LoginModel()
        let loginService = FakeLoginService()
        loginService.holdSend = holdSend
        let credentialStore = FakeCredentialStore()
        let repository = AuthSessionRepository(credentialStore: credentialStore, legacyStore: FakeLegacyCredentialStore())
        let authState = FakeAuthPublishing()
        let profileRefresher = FakeProfileRefresher()
        let intent = LoginIntent(
            model: model,
            loginService: loginService,
            sessionRepository: repository,
            authState: authState,
            profileRefresher: profileRefresher,
            profileUpdater: { _ in }
        )
        return Harness(model: model, intent: intent, credentialStore: credentialStore, repository: repository, loginService: loginService, authState: authState, profileRefresher: profileRefresher)
    }

    // MARK: - 协议勾选

    func testToggleAgreeFlipsModelValue() {
        let harness = makeHarness()
        XCTAssertFalse(harness.model.agree)

        harness.intent.onToggleAgree()
        XCTAssertTrue(harness.model.agree)

        harness.intent.onToggleAgree()
        XCTAssertFalse(harness.model.agree)
    }

    // MARK: - 发送验证码

    func testInvalidMobileDoesNotSendRequest() {
        let harness = makeHarness()
        harness.model.updateAgree(true)
        harness.intent.onChangeMobile("1380013")

        harness.intent.onTapSendVerifyCodeButton(countryRegionCode: "+86", mobile: harness.model.mobile)

        XCTAssertEqual(harness.loginService.sendCallCount, 0)
        XCTAssertEqual(harness.model.step, .inputMobile)
        XCTAssertEqual(harness.model.errorMessage, AuthError.invalidInput.localizedMessage)
    }

    func testUnagreedRequestDoesNotSend() {
        let harness = makeHarness()
        harness.model.updateMobile("138 0013 8000")
        harness.model.updateAgree(false)

        harness.intent.onTapSendVerifyCodeButton(countryRegionCode: "+86", mobile: harness.model.mobile)

        XCTAssertEqual(harness.loginService.sendCallCount, 0)
        XCTAssertEqual(harness.model.step, .inputMobile)
    }

    func testSendSuccessEntersVerifyStepAndStartsCountdown() {
        let harness = makeHarness()
        harness.model.updateAgree(true)
        harness.model.updateMobile("138 0013 8000")
        let before = Date()

        harness.intent.onTapSendVerifyCodeButton(countryRegionCode: "+86", mobile: harness.model.mobile)

        XCTAssertEqual(harness.loginService.sendCallCount, 1)
        XCTAssertEqual(harness.model.step, .inputVerifyCode)
        XCTAssertEqual(harness.model.operation, .idle)
        XCTAssertNil(harness.model.errorMessage)
        guard let availableAt = harness.model.resendAvailableAt else {
            return XCTFail("发送成功必须设置可重发时刻")
        }
        XCTAssertEqual(availableAt.timeIntervalSince(before), LoginModel.resendInterval, accuracy: 1)
        XCTAssertEqual(harness.model.resendRemainingSeconds(now: availableAt.addingTimeInterval(-1)), 1)
        XCTAssertEqual(harness.model.resendRemainingSeconds(now: availableAt), 0)
    }

    func testSendFailureKeepsStepAndShowsError() {
        let harness = makeHarness()
        harness.model.updateAgree(true)
        harness.model.updateMobile("138 0013 8000")
        harness.loginService.enqueueSend(.success(TspResponse(code: AuthServerCode.authenticationRejected)))

        harness.intent.onTapSendVerifyCodeButton(countryRegionCode: "+86", mobile: harness.model.mobile)

        XCTAssertEqual(harness.model.step, .inputMobile, "发送失败必须停留在手机号步骤")
        XCTAssertEqual(harness.model.operation, .idle)
        XCTAssertEqual(harness.model.errorMessage, AuthError.authenticationRejected.localizedMessage)
        XCTAssertNil(harness.model.resendAvailableAt)
    }

    func testDuplicateSendIsBlockedWhileSending() {
        let harness = makeHarness(holdSend: true)
        harness.model.updateAgree(true)
        harness.model.updateMobile("138 0013 8000")

        harness.intent.onTapSendVerifyCodeButton(countryRegionCode: "+86", mobile: harness.model.mobile)
        XCTAssertEqual(harness.model.operation, .sendingCode)
        harness.intent.onTapSendVerifyCodeButton(countryRegionCode: "+86", mobile: harness.model.mobile)

        XCTAssertEqual(harness.loginService.sendCallCount, 1, "处理中必须阻止重复发送")

        harness.loginService.releaseSend(.success(TspResponse(code: "000000")))
        XCTAssertEqual(harness.model.step, .inputVerifyCode)
        XCTAssertEqual(harness.model.operation, .idle)
    }

    // MARK: - 重新发送

    func testResendBeforeCountdownEndsIsBlocked() {
        let harness = makeHarness()
        harness.model.updateAgree(true)
        harness.intent.onTapSendVerifyCodeButton(countryRegionCode: "+86", mobile: "138 0013 8000")
        let sendCount = harness.loginService.sendCallCount

        harness.intent.onTapResendVerifyCodeText(countryRegionCode: "+86", mobile: harness.model.mobile)

        XCTAssertEqual(harness.loginService.sendCallCount, sendCount)
        XCTAssertEqual(harness.model.step, .inputVerifyCode)
    }

    func testResendSuccessRestartsCountdown() {
        let harness = makeHarness()
        let past = Date().addingTimeInterval(-1)
        harness.model.completeSendingCode(countryRegionCode: "+86", mobile: "138 0013 8000", resendAvailableAt: past)
        harness.model.updateAgree(true)
        let before = Date()

        harness.intent.onTapResendVerifyCodeText(countryRegionCode: "+86", mobile: harness.model.mobile)

        XCTAssertEqual(harness.model.step, .inputVerifyCode)
        guard let availableAt = harness.model.resendAvailableAt else {
            return XCTFail("重发成功必须重启倒计时")
        }
        XCTAssertEqual(availableAt.timeIntervalSince(before), LoginModel.resendInterval, accuracy: 1)
    }

    func testResendFailureKeepsPreviousCountdown() {
        let harness = makeHarness()
        let past = Date().addingTimeInterval(-1)
        harness.model.completeSendingCode(countryRegionCode: "+86", mobile: "138 0013 8000", resendAvailableAt: past)
        harness.model.updateAgree(true)
        harness.loginService.enqueueSend(.success(TspResponse(code: AuthServerCode.authenticationRejected)))

        harness.intent.onTapResendVerifyCodeText(countryRegionCode: "+86", mobile: harness.model.mobile)

        XCTAssertEqual(harness.model.step, .inputVerifyCode, "重发失败必须保持当前步骤")
        XCTAssertEqual(harness.model.resendAvailableAt, past, "重发失败不得启动虚假倒计时")
        XCTAssertEqual(harness.model.operation, .idle)
        XCTAssertNotNil(harness.model.errorMessage)
    }

    // MARK: - 登录提交

    func testLoginSuccessSavesCredentialsBeforePublishing() {
        let harness = makeHarness()
        harness.model.completeSendingCode(countryRegionCode: "+86", mobile: "138 0013 8000", resendAvailableAt: Date().addingTimeInterval(60))
        harness.loginService.enqueueLogin(.success(makeLoginResponsePayload(code: "000000", data: makeLoginResponse())))
        var closeCount = 0
        harness.model.routerSubject.close.sink { closeCount += 1 }.store(in: &cancellables)

        harness.intent.onTapVerifyCodeLoginButton(countryRegionCode: "+86", mobile: harness.model.mobile, verifyCode: "123456")

        XCTAssertEqual(harness.credentialStore.stored?.accessToken, "access-token-1")
        XCTAssertEqual(harness.authState.completedCount, 1)
        XCTAssertEqual(harness.profileRefresher.callCount, 1)
        XCTAssertEqual(closeCount, 1)
        XCTAssertEqual(harness.model.operation, .idle)
        XCTAssertEqual(harness.loginService.lastVerifyCodes.last, "123456")
    }

    func testLoginFailureStaysOnVerifyStep() {
        let harness = makeHarness()
        harness.model.completeSendingCode(countryRegionCode: "+86", mobile: "138 0013 8000", resendAvailableAt: Date().addingTimeInterval(60))
        harness.loginService.enqueueLogin(.success(makeLoginResponsePayload(code: AuthServerCode.verificationCodeInvalid, data: nil)))

        harness.intent.onTapVerifyCodeLoginButton(countryRegionCode: "+86", mobile: harness.model.mobile, verifyCode: "000000")

        XCTAssertEqual(harness.model.step, .inputVerifyCode)
        XCTAssertEqual(harness.model.errorMessage, AuthError.verificationCodeInvalid.localizedMessage)
        XCTAssertEqual(harness.authState.completedCount, 0)
        XCTAssertNil(harness.credentialStore.stored)
    }

    func testInvalidLoginResponseDoesNotPublishLogin() {
        let harness = makeHarness()
        harness.model.completeSendingCode(countryRegionCode: "+86", mobile: "138 0013 8000", resendAvailableAt: Date().addingTimeInterval(60))
        harness.loginService.enqueueLogin(.success(makeLoginResponsePayload(code: "000000", data: makeLoginResponse(["accessToken": ""]))))

        harness.intent.onTapVerifyCodeLoginButton(countryRegionCode: "+86", mobile: harness.model.mobile, verifyCode: "123456")

        XCTAssertEqual(harness.authState.completedCount, 0)
        XCTAssertNil(harness.credentialStore.stored)
        XCTAssertEqual(harness.model.step, .inputVerifyCode)
        XCTAssertEqual(harness.model.errorMessage, AuthError.invalidServerResponse.localizedMessage)
    }

    func testChallengeResponseDoesNotPublishLogin() {
        let harness = makeHarness()
        harness.model.completeSendingCode(countryRegionCode: "+86", mobile: "138 0013 8000", resendAvailableAt: Date().addingTimeInterval(60))
        harness.loginService.enqueueLogin(.success(makeLoginResponsePayload(code: "000000", data: makeLoginResponse(["challengeRequired": true]))))

        harness.intent.onTapVerifyCodeLoginButton(countryRegionCode: "+86", mobile: harness.model.mobile, verifyCode: "123456")

        XCTAssertEqual(harness.authState.completedCount, 0)
        XCTAssertNil(harness.credentialStore.stored)
        XCTAssertEqual(harness.model.errorMessage, AuthError.challengeUnsupported.localizedMessage)
    }

    func testCredentialPersistenceFailureDoesNotPublishLogin() {
        let harness = makeHarness()
        harness.credentialStore.saveError = AuthError.credentialPersistenceFailed
        harness.model.completeSendingCode(countryRegionCode: "+86", mobile: "138 0013 8000", resendAvailableAt: Date().addingTimeInterval(60))
        harness.loginService.enqueueLogin(.success(makeLoginResponsePayload(code: "000000", data: makeLoginResponse())))

        harness.intent.onTapVerifyCodeLoginButton(countryRegionCode: "+86", mobile: harness.model.mobile, verifyCode: "123456")

        XCTAssertEqual(harness.authState.completedCount, 0, "保存失败不得发布登录状态")
        XCTAssertEqual(harness.model.errorMessage, AuthError.credentialPersistenceFailed.localizedMessage)
        XCTAssertEqual(harness.model.step, .inputVerifyCode)
    }

    func testProfileRefreshFailureDoesNotRollbackSession() {
        let harness = makeHarness()
        harness.profileRefresher.account = nil
        harness.model.completeSendingCode(countryRegionCode: "+86", mobile: "138 0013 8000", resendAvailableAt: Date().addingTimeInterval(60))
        harness.loginService.enqueueLogin(.success(makeLoginResponsePayload(code: "000000", data: makeLoginResponse())))

        harness.intent.onTapVerifyCodeLoginButton(countryRegionCode: "+86", mobile: harness.model.mobile, verifyCode: "123456")

        XCTAssertEqual(harness.authState.completedCount, 1)
        XCTAssertEqual(harness.credentialStore.stored?.accessToken, "access-token-1")
        XCTAssertNil(harness.model.errorMessage)
    }

    func testDuplicateLoginSubmissionIsBlocked() {
        let harness = makeHarness()
        harness.model.updateAgree(true)
        harness.model.updateMobile("138 0013 8000")
        harness.model.beginLoggingIn()

        harness.intent.onTapVerifyCodeLoginButton(countryRegionCode: "+86", mobile: harness.model.mobile, verifyCode: "123456")

        XCTAssertEqual(harness.loginService.loginCallCount, 0)
    }

    func testShortVerificationCodeIsRejectedWithoutRequest() {
        let harness = makeHarness()
        harness.model.completeSendingCode(countryRegionCode: "+86", mobile: "138 0013 8000", resendAvailableAt: Date().addingTimeInterval(60))

        harness.intent.onTapVerifyCodeLoginButton(countryRegionCode: "+86", mobile: harness.model.mobile, verifyCode: "123")

        XCTAssertEqual(harness.loginService.loginCallCount, 0)
        XCTAssertEqual(harness.model.errorMessage, AuthError.invalidInput.localizedMessage)
    }

    // MARK: - 取消与返回

    func testCancelForcedLoginPublishesCancellation() {
        let harness = makeHarness()
        harness.authState.isForcedLogin = true

        harness.intent.onTapExitLoginIcon()

        XCTAssertEqual(harness.authState.cancelledCount, 1)
    }

    func testCancelNormalLoginClosesScreen() {
        let harness = makeHarness()
        var closeCount = 0
        harness.model.routerSubject.close.sink { closeCount += 1 }.store(in: &cancellables)

        harness.intent.onTapExitLoginIcon()

        XCTAssertEqual(closeCount, 1)
        XCTAssertEqual(harness.authState.cancelledCount, 0)
    }
}
