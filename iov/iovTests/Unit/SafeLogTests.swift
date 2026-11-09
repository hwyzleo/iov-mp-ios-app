//
//  SafeLogTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-001 on 2026/11/9.
//

import XCTest
@testable import iov

/// TC-001-10：日志扫描不包含 Token、Authorization、验证码和完整手机号
final class SafeLogTests: XCTestCase {

    func testBearerTokenIsRedacted() {
        let sanitized = SafeLog.sanitized("Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.payload.signature")
        XCTAssertFalse(sanitized.contains("eyJhbGciOiJIUzI1NiJ9.payload.signature"))
        XCTAssertTrue(sanitized.contains("***"))
    }

    func testSensitiveJsonKeysAreRedacted() {
        let body = """
        {"code":"000000","data":{"accessToken":"access-123","refreshToken":"refresh-456","sessionId":"session-1","userId":"user-1","mobile":"13800138000"},"ts":1}
        """
        let sanitized = SafeLog.redacted(responseBody: body)

        XCTAssertFalse(sanitized.contains("access-123"))
        XCTAssertFalse(sanitized.contains("refresh-456"))
        XCTAssertFalse(sanitized.contains("13800138000"))
        XCTAssertTrue(sanitized.contains("accessToken=***"))
        XCTAssertTrue(sanitized.contains("refreshToken=***"))
    }

    func testVerificationCodeIsRedacted() {
        let sanitized = SafeLog.sanitized("parameters: [\"code\": \"123456\", \"mobile\": \"13800138000\"]")
        XCTAssertFalse(sanitized.contains("123456"))
        XCTAssertFalse(sanitized.contains("13800138000"))
    }

    func testHeadersRedacted() {
        let headers = ["X-Client-Id": "iphone-capp", "Authorization": "Bearer token-abc.def"]
        let sanitized = SafeLog.redacted(headers: headers)
        XCTAssertFalse(sanitized.contains("token-abc.def"))
        XCTAssertTrue(sanitized.contains("iphone-capp"))
    }

    func testPhoneNumbersInPlainTextAreMasked() {
        let sanitized = SafeLog.sanitized("发送验证码到 13800138000 成功")
        XCTAssertFalse(sanitized.contains("13800138000"))
        XCTAssertTrue(sanitized.contains("138****00"))
    }

    func testNonSensitiveContentIsPreserved() {
        let text = "request get tsp: /api/mobile/account/v1/profile"
        XCTAssertEqual(SafeLog.sanitized(text), text)
    }
}
