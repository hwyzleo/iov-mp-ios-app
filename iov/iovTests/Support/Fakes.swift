//
//  Fakes.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-001 on 2026/11/9.
//

import Foundation
@testable import iov

// MARK: - 凭证存储替身

final class FakeCredentialStore: CredentialStoring {
    var stored: AuthSession?
    var loadError: Error?
    var saveError: Error?
    var removeError: Error?
    private(set) var saveCount = 0
    private(set) var removeCount = 0
    private(set) var loadCount = 0

    func loadSession() throws -> AuthSession? {
        loadCount += 1
        if let loadError = loadError { throw loadError }
        return stored
    }

    func save(_ session: AuthSession) throws {
        saveCount += 1
        if let saveError = saveError { throw saveError }
        stored = session
    }

    func remove() throws {
        removeCount += 1
        if let removeError = removeError { throw removeError }
        stored = nil
    }
}

final class FakeLegacyCredentialStore: LegacyCredentialStoring {
    var legacy: LegacyCredentials?
    var clearResult = true
    private(set) var clearCount = 0

    func loadLegacyCredentials() -> LegacyCredentials? {
        return legacy
    }

    func clearLegacyCredentials() -> Bool {
        clearCount += 1
        if clearResult {
            legacy = nil
        }
        return clearResult
    }
}

// MARK: - 登录服务替身

final class FakeLoginService: LoginServiceProtocol {
    private let lock = NSLock()

    private var sendResults: [Result<TspResponse<NoReply>, Error>] = []
    private var loginResults: [Result<TspResponse<LoginResponse>, Error>] = []
    private var heldSendCompletions: [(Result<TspResponse<NoReply>, Error>) -> Void] = []

    /// 挂起发送请求，用于验证处理中状态与重复提交
    var holdSend = false

    private(set) var sendCallCount = 0
    private(set) var loginCallCount = 0
    private(set) var lastSentMobiles: [String] = []
    private(set) var lastVerifyCodes: [String] = []

    func enqueueSend(_ result: Result<TspResponse<NoReply>, Error>) {
        lock.lock(); defer { lock.unlock() }
        sendResults.append(result)
    }

    func enqueueLogin(_ result: Result<TspResponse<LoginResponse>, Error>) {
        lock.lock(); defer { lock.unlock() }
        loginResults.append(result)
    }

    func releaseSend(_ result: Result<TspResponse<NoReply>, Error>) {
        lock.lock()
        let completions = heldSendCompletions
        heldSendCompletions.removeAll()
        lock.unlock()
        completions.forEach { $0(result) }
    }

    func sendMobileVerifyCode(countryRegionCode: String, mobile: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        lock.lock()
        sendCallCount += 1
        lastSentMobiles.append(mobile)
        if holdSend {
            heldSendCompletions.append(completion)
            lock.unlock()
            return
        }
        let result = sendResults.isEmpty ? Result<TspResponse<NoReply>, Error>.success(TspResponse(code: "000000")) : sendResults.removeFirst()
        lock.unlock()
        completion(result)
    }

    func mobileVerifyCodeLogin(countryRegionCode: String, mobile: String, verifyCode: String, completion: @escaping (Result<TspResponse<LoginResponse>, Error>) -> Void) {
        lock.lock()
        loginCallCount += 1
        lastVerifyCodes.append(verifyCode)
        let result = loginResults.isEmpty
            ? Result<TspResponse<LoginResponse>, Error>.failure(AuthError.unknown)
            : loginResults.removeFirst()
        lock.unlock()
        completion(result)
    }
}

// MARK: - Token 刷新替身

final class FakeTokenRefresher: TokenRefreshing {
    private let lock = NSLock()
    private(set) var callCount = 0
    var result: Result<TspResponse<LoginResponse>, Error> = .failure(AuthError.networkUnavailable)
    var delay: TimeInterval = 0

    func refresh(refreshToken: String, completion: @escaping (Result<TspResponse<LoginResponse>, Error>) -> Void) {
        lock.lock()
        callCount += 1
        let result = self.result
        let delay = self.delay
        lock.unlock()

        if delay > 0 {
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                completion(result)
            }
        } else {
            completion(result)
        }
    }
}

// MARK: - 状态发布与资料刷新替身

final class FakeAuthPublishing: LoginAuthPublishing {
    var isForcedLogin = false
    private(set) var completedCount = 0
    private(set) var cancelledCount = 0

    func handleLoginCompleted() {
        completedCount += 1
    }

    func handleLoginCancelled() {
        cancelledCount += 1
    }
}

final class FakeProfileRefresher: LoginProfileRefreshing {
    var account: AccountInfo?
    private(set) var callCount = 0

    func refreshProfile(completion: @escaping (AccountInfo?) -> Void) {
        callCount += 1
        completion(account)
    }
}
