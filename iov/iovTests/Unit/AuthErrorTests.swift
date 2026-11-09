//
//  AuthErrorTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-001 on 2026/11/9.
//

import XCTest
@testable import iov

/// TC-001-4 / TC-001-10：错误语义与本地化文案
final class AuthErrorTests: XCTestCase {

    func testServerCodeMapping() {
        XCTAssertEqual(AuthError.mapServerCode(AuthServerCode.sessionExpired), .sessionExpired)
        XCTAssertEqual(AuthError.mapServerCode(AuthServerCode.verificationCodeInvalid), .verificationCodeInvalid)
        XCTAssertEqual(AuthError.mapServerCode(AuthServerCode.authenticationRejected), .authenticationRejected)
        XCTAssertEqual(AuthError.mapServerCode(AuthServerCode.challengeRequired), .challengeUnsupported)
        XCTAssertEqual(AuthError.mapServerCode("999999"), .authenticationRejected)
    }

    func testNetworkErrorMapping() {
        let network = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        XCTAssertEqual(AuthError.mapNetworkError(network), .networkUnavailable)

        let parsing = NSError(domain: "NetworkAPIError", code: 0)
        XCTAssertEqual(AuthError.mapNetworkError(parsing), .invalidServerResponse)

        XCTAssertEqual(AuthError.mapNetworkError(AuthError.sessionExpired), .sessionExpired)
        XCTAssertEqual(AuthError.mapNetworkError(NSError(domain: "Other", code: 1)), .unknown)
    }

    func testLocalizedMessagesAreProvided() {
        let errors: [AuthError] = [
            .invalidInput, .networkUnavailable, .verificationCodeInvalid, .authenticationRejected,
            .challengeUnsupported, .invalidServerResponse, .credentialPersistenceFailed,
            .tokenRefreshFailed, .sessionExpired, .unknown
        ]

        for error in errors {
            XCTAssertFalse(error.localizationKey.isEmpty)
            let message = error.localizedMessage
            XCTAssertFalse(message.isEmpty)
            // 本地化资源缺失时会回退为 key 本身
            XCTAssertNotEqual(message, error.localizationKey, "缺少本地化文案: \(error.localizationKey)")
        }
    }

    func testLogCategoryHasNoSensitiveContent() {
        XCTAssertEqual(AuthError.verificationCodeInvalid.logCategory, "verificationCodeInvalid")
    }
}
