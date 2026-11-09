//
//  MobileNumberTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-001 on 2026/11/9.
//

import XCTest
@testable import iov

/// TC-001-1：手机号格式化、非法输入
final class MobileNumberTests: XCTestCase {

    func testNormalizationRemovesSpacesAndSymbols() {
        XCTAssertEqual(MobileNumber.normalized("138 0013 8000"), "13800138000")
        XCTAssertEqual(MobileNumber.normalized("138-0013-8000"), "13800138000")
        XCTAssertEqual(MobileNumber.normalized("abc13800138000xyz"), "13800138000")
    }

    func testMainlandMobileValidation() {
        XCTAssertTrue(MobileNumber.isValidMainlandMobile("13800138000"))
        XCTAssertTrue(MobileNumber.isValidMainlandMobile("138 0013 8000"))
        XCTAssertFalse(MobileNumber.isValidMainlandMobile("1380013800"))
        XCTAssertFalse(MobileNumber.isValidMainlandMobile("23800138000"))
        XCTAssertFalse(MobileNumber.isValidMainlandMobile(""))
    }

    func testFormatting() {
        XCTAssertEqual(MobileNumber.formatted("13800138000"), "138 0013 8000")
        XCTAssertEqual(MobileNumber.formatted("138"), "138")
        XCTAssertEqual(MobileNumber.formatted("1380013"), "138 0013")
    }

    func testMaskingKeepsPrefixAndSuffixOnly() {
        let masked = MobileNumber.masked("13800138000")
        XCTAssertEqual(masked, "138****00")
        XCTAssertFalse(masked.contains("001380"))
        XCTAssertEqual(MobileNumber.masked("123"), "***")
    }
}
