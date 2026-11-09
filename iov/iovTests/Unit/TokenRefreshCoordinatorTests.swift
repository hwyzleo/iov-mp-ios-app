//
//  TokenRefreshCoordinatorTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-001 on 2026/11/9.
//

import XCTest
@testable import iov

/// TC-001-7 / TC-001-8：并发刷新仅一次、新会话保存后唤醒、部分响应不接受、网络失败保留会话
final class TokenRefreshCoordinatorTests: XCTestCase {

    private func makeCoordinator(
        credentialStore: FakeCredentialStore,
        refresher: FakeTokenRefresher,
        onSessionExpired: @escaping () -> Void = {}
    ) -> TokenRefreshCoordinator {
        let repository = AuthSessionRepository(credentialStore: credentialStore, legacyStore: FakeLegacyCredentialStore())
        return TokenRefreshCoordinator(repository: repository, refresher: refresher, onSessionExpired: onSessionExpired)
    }

    func testConcurrentRefreshesOnlyCallRemoteOnce() {
        let credentialStore = FakeCredentialStore()
        credentialStore.stored = makeSession()
        let refresher = FakeTokenRefresher()
        refresher.delay = 0.2
        refresher.result = .success(makeLoginResponsePayload(code: "000000", data: makeLoginResponse(["accessToken": "access-token-2"])))
        let coordinator = makeCoordinator(credentialStore: credentialStore, refresher: refresher)

        let expectation = expectation(description: "并发刷新全部完成")
        expectation.expectedFulfillmentCount = 5
        expectation.assertForOverFulfill = true

        for _ in 0..<5 {
            coordinator.refresh { result in
                if case let .failure(error) = result {
                    XCTFail("并发刷新应成功：\(error)")
                }
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3)
        XCTAssertEqual(refresher.callCount, 1, "并发刷新只能执行一次远程调用")
        XCTAssertEqual(credentialStore.stored?.accessToken, "access-token-2")
    }

    func testRefreshWaitsForSessionSave() {
        let credentialStore = FakeCredentialStore()
        credentialStore.stored = makeSession()
        credentialStore.saveError = AuthError.credentialPersistenceFailed
        let refresher = FakeTokenRefresher()
        refresher.result = .success(makeLoginResponsePayload(code: "000000", data: makeLoginResponse(["accessToken": "access-token-2"])))
        let coordinator = makeCoordinator(credentialStore: credentialStore, refresher: refresher)

        let expectation = expectation(description: "保存失败")
        coordinator.refresh { result in
            XCTAssertEqual(result, .failure(.credentialPersistenceFailed))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(credentialStore.stored?.accessToken, "access-token-1", "保存失败时不得使用部分新凭证")
    }

    func testPartialRefreshResponseIsRejected() {
        let credentialStore = FakeCredentialStore()
        credentialStore.stored = makeSession()
        let refresher = FakeTokenRefresher()
        refresher.result = .success(makeLoginResponsePayload(code: "000000", data: makeLoginResponse(["accessToken": ""])))
        let coordinator = makeCoordinator(credentialStore: credentialStore, refresher: refresher)

        let expectation = expectation(description: "部分响应被拒绝")
        coordinator.refresh { result in
            XCTAssertEqual(result, .failure(.invalidServerResponse))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(credentialStore.stored?.accessToken, "access-token-1")
    }

    func testNetworkFailureKeepsExistingSession() {
        let credentialStore = FakeCredentialStore()
        credentialStore.stored = makeSession()
        let refresher = FakeTokenRefresher()
        refresher.result = .failure(NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut))
        let coordinator = makeCoordinator(credentialStore: credentialStore, refresher: refresher)

        let expectation = expectation(description: "网络失败")
        coordinator.refresh { result in
            XCTAssertEqual(result, .failure(.networkUnavailable))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(credentialStore.stored?.accessToken, "access-token-1", "网络失败不得登出")
        XCTAssertEqual(credentialStore.removeCount, 0)
    }

    func testAuthInvalidMapsToSessionExpired() {
        let credentialStore = FakeCredentialStore()
        credentialStore.stored = makeSession()
        let refresher = FakeTokenRefresher()
        refresher.result = .success(makeLoginResponsePayload(code: AuthServerCode.sessionExpired, data: nil))
        let coordinator = makeCoordinator(credentialStore: credentialStore, refresher: refresher)

        let expectation = expectation(description: "会话失效")
        coordinator.refresh { result in
            XCTAssertEqual(result, .failure(.sessionExpired))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)
    }

    func testMissingSessionTriggersSessionExpired() {
        let credentialStore = FakeCredentialStore()
        let refresher = FakeTokenRefresher()
        var expiredCount = 0
        let coordinator = makeCoordinator(credentialStore: credentialStore, refresher: refresher) {
            expiredCount += 1
        }

        let expectation = expectation(description: "无会话")
        coordinator.refresh { result in
            XCTAssertEqual(result, .failure(.sessionExpired))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(refresher.callCount, 0)
        XCTAssertEqual(expiredCount, 1)
    }
}
