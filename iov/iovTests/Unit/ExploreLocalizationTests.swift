//
//  ExploreLocalizationTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-012 on 2026/11/26.
//

import XCTest
@testable import iov

/// TC-012-9：探索页新增文案在中英文资源中对称且非空。
final class ExploreLocalizationTests: XCTestCase {

    private static let sourceRoot: URL = {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()   // Unit
            .deletingLastPathComponent()   // iovTests
            .deletingLastPathComponent()   // 工程根
    }()

    private func strings(at relativePath: String) throws -> [String: String] {
        let url = Self.sourceRoot.appendingPathComponent(relativePath)
        let content = try String(contentsOf: url, encoding: .utf8)
        var result: [String: String] = [:]
        for line in content.split(separator: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("\""), trimmed.contains("\" = \"") else { continue }
            let parts = trimmed.split(separator: "\"", maxSplits: 3, omittingEmptySubsequences: false)
            guard parts.count >= 4 else { continue }
            let key = String(parts[1])
            var value = String(parts[3])
            if value.hasSuffix(";") { value.removeLast() }
            if value.hasSuffix("\"") { value.removeLast() }
            result[key] = value
        }
        return result
    }

    func testExploreLocalizationKeysExistInBothLanguages() throws {
        let en = try strings(at: "en.lproj/Localizable.strings")
        let zh = try strings(at: "zh-Hans.lproj/Localizable.strings")
        let required = [
            "explore_image_unavailable",
            "explore_open_content",
            "explore_empty_channels",
            "explore_refresh",
            "explore_retry",
            "explore_dismiss",
            "explore_load_more",
            "explore_web_title",
            "explore_web_unavailable",
            "explore_article_title",
            "explore_topic_title",
            "explore_article_unavailable",
            "explore_error_network",
            "explore_error_service_unavailable",
            "explore_error_content_unavailable",
            "explore_error_no_content",
            "explore_error_invalid_argument",
            "explore_error_release_changed",
            "explore_error_unsupported_version",
            "explore_error_invalid_response",
            "explore_error_invalid_target",
            "explore_error_unauthorized",
            "explore_error_unknown"
        ]
        for key in required {
            XCTAssertFalse((en[key] ?? "").isEmpty, "en 缺失: \(key)")
            XCTAssertFalse((zh[key] ?? "").isEmpty, "zh-Hans 缺失: \(key)")
        }
    }

    func testAllExploreKeysAreSymmetric() throws {
        let en = try strings(at: "en.lproj/Localizable.strings")
        let zh = try strings(at: "zh-Hans.lproj/Localizable.strings")
        let enExplore = Set(en.keys.filter { $0.hasPrefix("explore_") })
        let zhExplore = Set(zh.keys.filter { $0.hasPrefix("explore_") })
        XCTAssertFalse(enExplore.isEmpty)
        XCTAssertEqual(enExplore, zhExplore)
    }
}
