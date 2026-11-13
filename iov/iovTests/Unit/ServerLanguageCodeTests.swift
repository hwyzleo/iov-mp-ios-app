//
//  ServerLanguageCodeTests.swift
//  iovTests
//

import XCTest
@testable import iov

/// 云端语言上报标识映射：zh-Hans / zh-Hant / en
final class ServerLanguageCodeTests: XCTestCase {

    private func code(_ identifier: String) -> String {
        AppGlobalState.serverLanguageCode(for: identifier)
    }

    // MARK: - 简体

    func testSimplifiedChineseIdentifiers() {
        XCTAssertEqual(code("zh-Hans"), "zh-Hans")
        XCTAssertEqual(code("zh-Hans-CN"), "zh-Hans")
        XCTAssertEqual(code("zh-CN"), "zh-Hans")
        XCTAssertEqual(code("zh-SG"), "zh-Hans")
        XCTAssertEqual(code("zh"), "zh-Hans")
        XCTAssertEqual(code("zh_Hans"), "zh-Hans")
    }

    // MARK: - 繁体

    func testTraditionalChineseIdentifiers() {
        XCTAssertEqual(code("zh-Hant"), "zh-Hant")
        XCTAssertEqual(code("zh-Hant-TW"), "zh-Hant")
        XCTAssertEqual(code("zh-TW"), "zh-Hant")
        XCTAssertEqual(code("zh-HK"), "zh-Hant")
        XCTAssertEqual(code("zh-MO"), "zh-Hant")
        XCTAssertEqual(code("zh_Hant"), "zh-Hant")
        XCTAssertEqual(code("zh_TW"), "zh-Hant")
    }

    // MARK: - 大小写不敏感

    func testCaseInsensitiveIdentifiers() {
        XCTAssertEqual(code("ZH-hans"), "zh-Hans")
        XCTAssertEqual(code("ZH-HANT-HK"), "zh-Hant")
    }

    // MARK: - 其他语言回落 en

    func testNonChineseIdentifiersFallBackToEnglish() {
        XCTAssertEqual(code("en"), "en")
        XCTAssertEqual(code("en-US"), "en")
        XCTAssertEqual(code("en_GB"), "en")
        XCTAssertEqual(code("ja-JP"), "en")
        XCTAssertEqual(code(""), "en")
    }
}
