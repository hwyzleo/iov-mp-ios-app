//
//  LocalizationParityTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-011 on 2026/11/23.
//

import XCTest
@testable import iov

/// TC-011-10 / TC-011-11：日志脱敏、双语 key 对称、扫码浮层本地化与注释漂移检查。
final class LocalizationParityTests: XCTestCase {

    static let sourceRoot: URL = {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()   // Unit
            .deletingLastPathComponent()   // iovTests
            .deletingLastPathComponent()   // iov（工程根）
    }()

    private func strings(at relativePath: String) throws -> [String: String] {
        let url = Self.sourceRoot.appendingPathComponent(relativePath)
        let content = try String(contentsOf: url, encoding: .utf8)
        var result: [String: String] = [:]
        for line in content.split(separator: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("\""), trimmed.contains("\" = \"") || trimmed.contains("\"=") else { continue }
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

    // MARK: - 双语 key 对称

    func testLocalizableKeysAreSymmetricAcrossLanguages() throws {
        let en = try strings(at: "en.lproj/Localizable.strings")
        let zh = try strings(at: "zh-Hans.lproj/Localizable.strings")

        XCTAssertGreaterThan(en.count, 200, "Localizable.strings 解析异常")
        XCTAssertEqual(Set(en.keys), Set(zh.keys), "中英文 key 集合必须完全一致")
        XCTAssertEqual(en.count, zh.count)
    }

    func testBindingAndScannerKeysExistInBothLanguages() throws {
        let en = try strings(at: "en.lproj/Localizable.strings")
        let zh = try strings(at: "zh-Hans.lproj/Localizable.strings")
        let required = [
            "scanner_hint",
            "scanner_torch",
            "vehicle_binding_error_authentication_session_expired",
            "vehicle_binding_error_authentication_rejected",
            "vehicle_binding_error_invalid_response",
            "vehicle_binding_error_forbidden",
            "vehicle_binding_session_expired_hint",
            "vehicle_binding_session_cancelled_hint",
            "vehicle_binding_session_skipped_hint",
            "vehicle_binding_session_issued_hint",
            "vehicle_binding_session_unknown_hint",
            "vehicle_binding_go_login",
            "vehicle_binding_login_required_hint",
            "vehicle_binding_rescan_required_hint",
            "vehicle_binding_polling_exhausted"
        ]
        for key in required {
            XCTAssertFalse((en[key] ?? "").isEmpty, "en 缺失或为空: \(key)")
            XCTAssertFalse((zh[key] ?? "").isEmpty, "zh-Hans 缺失或为空: \(key)")
        }
        XCTAssertNil(en["scanner_album"], "R-17：相册按钮已移除，不得再登记 scanner_album")
    }

    // MARK: - InfoPlist.strings

    func testInfoPlistStringsContainAllPermissionKeys() throws {
        let required = [
            "NSCameraUsageDescription",
            "NSPhotoLibraryUsageDescription",
            "NSLocationWhenInUseUsageDescription",
            "NSBluetoothAlwaysUsageDescription"
        ]
        for language in ["en", "zh-Hans"] {
            let values = try strings(at: "\(language).lproj/InfoPlist.strings")
            for key in required {
                XCTAssertFalse((values[key] ?? "").isEmpty, "\(language) 缺失或为空: \(key)")
            }
            XCTAssertEqual(Set(values.keys), Set(required), "\(language) InfoPlist key 集合必须一致")
        }
    }

    func testMainInfoPlistDeclaresBluetoothUsage() throws {
        let url = Self.sourceRoot.appendingPathComponent("iov/Info.plist")
        let data = try Data(contentsOf: url)
        let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        let value = plist?["NSBluetoothAlwaysUsageDescription"] as? String
        XCTAssertFalse((value ?? "").isEmpty, "主 Target Info.plist 必须声明蓝牙用途")
    }

    // MARK: - 扫码浮层本地化与相册死控件移除（R-17）

    func testScannerViewHasNoHardcodedChineseAndNoAlbumButton() throws {
        let source = try String(contentsOf: Self.sourceRoot.appendingPathComponent("iov/Component/View/ScannerView.swift"))

        XCTAssertTrue(source.contains("\"scanner_hint\""))
        XCTAssertTrue(source.contains("\"scanner_torch\""))
        XCTAssertFalse(source.contains("photo.on.rectangle.angled"), "R-17：相册死控件必须移除")
        XCTAssertFalse(source.contains("\"相册\""))

        // 扫码浮层不得残留中文字面量
        let hanRange = source.range(of: "\\p{Han}", options: .regularExpression)
        XCTAssertNil(hanRange, "ScannerView 仍存在中文字面量（应改为 l10n key）")
    }

    // MARK: - 日志脱敏（D-011-5 §7.4）

    func testVinAndAccountIdAreMasked() {
        XCTAssertEqual(SafeLog.maskVin("LSVAA123456789012"), "LSV****9012")
        XCTAssertNil(SafeLog.maskVin(nil))
        XCTAssertNil(SafeLog.maskVin("   "))

        XCTAssertEqual(SafeLog.maskAccountId("acc-123456789"), "acc****6789")
        XCTAssertEqual(SafeLog.maskAccountId("short"), "*****")
        XCTAssertEqual(SafeLog.maskAccountId(nil), "-")
    }

    func testSanitizedMasksBareVinAndIsolationKey() {
        let isolationKey = "acc-123456789|order-987654321|LSVAA123456789012"
        let sanitized = SafeLog.sanitized("context \(isolationKey)")

        XCTAssertFalse(sanitized.contains("LSVAA123456789012"), "完整 VIN 不得进日志")
        XCTAssertTrue(sanitized.contains("LSV****9012"))
    }

    func testSanitizedMasksSensitiveKeysFromBindingChain() {
        let json = """
        {"qrToken":"qr-abc-123","sessionId":"session-9","operationId":"op-7","idempotencyKey":"key-5","vin":"LSVAA123456789012","accountId":"acc-1"}
        """
        let sanitized = SafeLog.sanitized(json)
        for raw in ["qr-abc-123", "session-9", "op-7", "key-5", "LSVAA123456789012"] {
            XCTAssertFalse(sanitized.contains(raw), "敏感值泄漏: \(raw)")
        }
    }

    // MARK: - TC-011-11 漂移检查

    func testNoLegacyActivationPathInSources() throws {
        let sources = try swiftSourceFiles()
        for url in sources {
            let content = try String(contentsOf: url, encoding: .utf8)
            XCTAssertFalse(content.contains("/api/c/activation"),
                           "\(url.lastPathComponent) 仍残留旧路径 /api/c/activation")
        }
    }

    func testBindingServiceCommentsNoLongerClaimMissingRelationAPI() throws {
        let url = Self.sourceRoot.appendingPathComponent("iov/Module/Vehicle/Service/VehicleBindingService.swift")
        let content = try String(contentsOf: url, encoding: .utf8)
        XCTAssertFalse(content.contains("没有“按账号 + VIN 查询关系”"),
                       "Protocol 注释仍称无关系查询接口（已由 CR-018 提供）")
        XCTAssertTrue(content.contains("/api/mobile/activation/v1/binding"),
                      "注释必须与 TspApi 实现路径一致")
    }

    private func swiftSourceFiles() throws -> [URL] {
        let root = Self.sourceRoot.appendingPathComponent("iov")
        guard let enumerator = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil) else {
            return []
        }
        var files: [URL] = []
        while let item = enumerator.nextObject() as? URL {
            if item.pathExtension == "swift" {
                files.append(item)
            }
        }
        return files
    }
}
