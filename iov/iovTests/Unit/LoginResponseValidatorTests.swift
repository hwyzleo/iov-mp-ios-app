//
//  LoginResponseValidatorTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-001 on 2026/11/9.
//

import XCTest
@testable import iov

/// TC-001-4：data 缺失、空 Token、非法 TTL、挑战响应均不崩溃且不登录
final class LoginResponseValidatorTests: XCTestCase {

    func testValidResponseBuildsSession() {
        let now = Date()
        let response = makeLoginResponsePayload(code: "000000", data: makeLoginResponse())
        let result = LoginResponseValidator.session(from: response, now: now)

        guard case let .success(session) = result else {
            return XCTFail("合法响应应生成会话")
        }
        XCTAssertEqual(session.accessToken, "access-token-1")
        XCTAssertEqual(session.refreshToken, "refresh-token-1")
        XCTAssertEqual(session.sessionId, "session-1")
        XCTAssertEqual(session.userId, "user-1")
        XCTAssertEqual(session.accessTokenExpiresAt.timeIntervalSince1970, now.addingTimeInterval(3600).timeIntervalSince1970, accuracy: 0.001)
    }

    func testMissingDataRejected() {
        let response = makeLoginResponsePayload(code: "000000", data: nil)
        XCTAssertEqual(LoginResponseValidator.session(from: response), .failure(.invalidServerResponse))
    }

    func testEmptyAccessTokenRejected() {
        let response = makeLoginResponsePayload(code: "000000", data: makeLoginResponse(["accessToken": ""]))
        XCTAssertEqual(LoginResponseValidator.session(from: response), .failure(.invalidServerResponse))
    }

    func testEmptyRefreshTokenRejected() {
        let response = makeLoginResponsePayload(code: "000000", data: makeLoginResponse(["refreshToken": ""]))
        XCTAssertEqual(LoginResponseValidator.session(from: response), .failure(.invalidServerResponse))
    }

    func testNonPositiveTtlRejected() {
        let zero = makeLoginResponsePayload(code: "000000", data: makeLoginResponse(["accessTokenTtl": 0]))
        XCTAssertEqual(LoginResponseValidator.session(from: zero), .failure(.invalidServerResponse))

        let negative = makeLoginResponsePayload(code: "000000", data: makeLoginResponse(["accessTokenTtl": -1]))
        XCTAssertEqual(LoginResponseValidator.session(from: negative), .failure(.invalidServerResponse))
    }

    func testEmptySessionIdRejected() {
        let response = makeLoginResponsePayload(code: "000000", data: makeLoginResponse(["sessionId": ""]))
        XCTAssertEqual(LoginResponseValidator.session(from: response), .failure(.invalidServerResponse))
    }

    func testChallengeRequiredRejected() {
        let response = makeLoginResponsePayload(code: "000000", data: makeLoginResponse(["challengeRequired": true]))
        XCTAssertEqual(LoginResponseValidator.session(from: response), .failure(.challengeUnsupported))
    }

    func testFallbackRequiredRejected() {
        let response = makeLoginResponsePayload(code: "000000", data: makeLoginResponse(["fallbackRequired": true]))
        XCTAssertEqual(LoginResponseValidator.session(from: response), .failure(.challengeUnsupported))
    }

    func testBusinessFailureMapsToAuthError() {
        let invalidCode = makeLoginResponsePayload(code: AuthServerCode.verificationCodeInvalid, data: nil)
        XCTAssertEqual(LoginResponseValidator.session(from: invalidCode), .failure(.verificationCodeInvalid))
    }

    // MARK: - 刷新响应

    func testRefreshedSessionPreservesMetadataWhenResponseOmitsIt() {
        let previous = makeSession()
        let response = makeLoginResponsePayload(
            code: "000000",
            data: makeLoginResponse(["accessToken": "access-token-2", "refreshToken": "", "sessionId": ""])
        )

        guard case let .success(session) = LoginResponseValidator.refreshedSession(from: response, previous: previous) else {
            return XCTFail("刷新响应应生成新会话")
        }
        XCTAssertEqual(session.accessToken, "access-token-2")
        XCTAssertEqual(session.refreshToken, previous.refreshToken)
        XCTAssertEqual(session.sessionId, previous.sessionId)
        XCTAssertEqual(session.userId, previous.userId)
    }

    func testRefreshedSessionRejectsMissingAccessToken() {
        let previous = makeSession()
        let response = makeLoginResponsePayload(
            code: "000000",
            data: makeLoginResponse(["accessToken": ""])
        )
        XCTAssertEqual(LoginResponseValidator.refreshedSession(from: response, previous: previous), .failure(.invalidServerResponse))
    }

    func testRefreshedSessionMapsAuthRejectionToSessionExpired() {
        let previous = makeSession()
        let response = makeLoginResponsePayload(code: "701403", data: nil)
        XCTAssertEqual(LoginResponseValidator.refreshedSession(from: response, previous: previous), .failure(.sessionExpired))
    }
}
