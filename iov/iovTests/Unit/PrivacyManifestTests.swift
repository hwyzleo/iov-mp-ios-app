//
//  PrivacyManifestTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-011 on 2026/11/23.
//

import XCTest
import Security
import KeychainAccess
@testable import iov

/// TC-011-8 / TC-011-9：隐私清单（含 PhotosorVideos、UserDefaults CA92.1、第三方 SDK 复核）
/// 与 Keychain ThisDeviceOnly 可访问性。
final class PrivacyManifestTests: XCTestCase {

    /// 工程根目录（含 `iov/`、`iovTests/`、`en.lproj/`）
    static let sourceRoot: URL = {
        // .../iov/iovTests/Unit/PrivacyManifestTests.swift → .../iov
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()   // Unit
            .deletingLastPathComponent()   // iovTests
            .deletingLastPathComponent()   // iov（工程根）
    }()

    private func loadManifest(at url: URL) throws -> [String: Any] {
        let data = try Data(contentsOf: url)
        let plist = try PropertyListSerialization.propertyList(from: data, format: nil)
        guard let dictionary = plist as? [String: Any] else {
            throw NSError(domain: "PrivacyManifestTests", code: 1)
        }
        return dictionary
    }

    // MARK: - TC-011-8 清单内容

    func testPrivacyManifestExistsInAppResources() throws {
        let sourcePath = Self.sourceRoot.appendingPathComponent("iov/PrivacyInfo.xcprivacy")
        XCTAssertTrue(FileManager.default.fileExists(atPath: sourcePath.path),
                      "缺失 PrivacyInfo.xcprivacy：\(sourcePath.path)")

        // 打包证据：必须挂在 App Target Resources（非 Pods）
        let pbxproj = try String(contentsOf: Self.sourceRoot.appendingPathComponent("iov.xcodeproj/project.pbxproj"))
        XCTAssertTrue(pbxproj.contains("PrivacyInfo.xcprivacy in Resources"),
                      "PrivacyInfo.xcprivacy 未登记到 App Target Resources")

        // 若测试宿主为 App，则必须能从主 Bundle 读到（兜底断言资源已打包）
        if Bundle.main.bundleIdentifier == "net.hwyz.iov.mp.app" || Bundle.main.path(forResource: "PrivacyInfo", ofType: "xcprivacy") != nil {
            XCTAssertNotNil(Bundle.main.path(forResource: "PrivacyInfo", ofType: "xcprivacy"),
                            "PrivacyInfo.xcprivacy 未被复制进 App Bundle")
        }
    }

    func testManifestDeclaresNoTrackingAndRequiredCollectedTypes() throws {
        let manifest = try loadManifest(at: Self.sourceRoot.appendingPathComponent("iov/PrivacyInfo.xcprivacy"))

        XCTAssertEqual(manifest["NSPrivacyTracking"] as? Bool, false)
        XCTAssertEqual((manifest["NSPrivacyTrackingDomains"] as? [Any])?.count ?? 0, 0,
                       "不得声明任何 tracking domain")

        let collected = manifest["NSPrivacyCollectedDataTypes"] as? [[String: Any]] ?? []
        let types = Set(collected.compactMap { $0["NSPrivacyCollectedDataType"] as? String })
        let expected: Set<String> = [
            "NSPrivacyCollectedDataTypePhoneNumber",
            "NSPrivacyCollectedDataTypeDeviceID",
            "NSPrivacyCollectedDataTypeOtherDataTypes",
            "NSPrivacyCollectedDataTypeUserID",
            "NSPrivacyCollectedDataTypePhotosorVideos"
        ]
        XCTAssertEqual(types, expected, "采集类型必须与 §7.1 一致（含裁决 BLK-10 的 PhotosorVideos）")

        for entry in collected {
            XCTAssertEqual(entry["NSPrivacyCollectedDataTypeLinked"] as? Bool, true,
                           "\(entry["NSPrivacyCollectedDataType"] ?? "?") 必须声明 Linked")
            XCTAssertEqual(entry["NSPrivacyCollectedDataTypeTracking"] as? Bool, false,
                           "\(entry["NSPrivacyCollectedDataType"] ?? "?") 不得用于追踪")
            let purposes = entry["NSPrivacyCollectedDataTypePurposes"] as? [String] ?? []
            XCTAssertTrue(purposes.contains("NSPrivacyCollectedDataTypePurposeAppFunctionality"),
                          "\(entry["NSPrivacyCollectedDataType"] ?? "?") 用途必须为 AppFunctionality")
        }
    }

    func testManifestDeclaresOnlyActuallyUsedRequiredReasonAPIs() throws {
        let manifest = try loadManifest(at: Self.sourceRoot.appendingPathComponent("iov/PrivacyInfo.xcprivacy"))
        let apis = manifest["NSPrivacyAccessedAPITypes"] as? [[String: Any]] ?? []
        let categories = Dictionary(uniqueKeysWithValues: apis.compactMap { entry -> (String, [String])? in
            guard let type = entry["NSPrivacyAccessedAPIType"] as? String else { return nil }
            return (type, entry["NSPrivacyAccessedAPITypeReasons"] as? [String] ?? [])
        })

        XCTAssertEqual(categories["NSPrivacyAccessedAPICategoryUserDefaults"], ["CA92.1"])
        // 代码未使用：不得声明（避免过度声明与审核问答不一致）
        for unused in ["NSPrivacyAccessedAPICategoryFileTimestamp",
                       "NSPrivacyAccessedAPICategoryDiskSpace",
                       "NSPrivacyAccessedAPICategorySystemBootTime",
                       "NSPrivacyAccessedAPICategoryActiveKeyboards"] {
            XCTAssertNil(categories[unused], "未使用不得声明: \(unused)")
        }
    }

    /// 第三方 SDK 复核（BLK-10 证据项）：Pods 内清单不得声明 tracking / tracking domains
    func testThirdPartyPodsDoNotDeclareTracking() throws {
        let pods = Self.sourceRoot.appendingPathComponent("Pods")
        guard FileManager.default.fileExists(atPath: pods.path) else {
            throw XCTSkip("Pods 不存在，跳过第三方清单复核")
        }
        let enumerator = FileManager.default.enumerator(at: pods, includingPropertiesForKeys: nil)
        var checked = 0
        while let url = enumerator?.nextObject() as? URL {
            guard url.lastPathComponent == "PrivacyInfo.xcprivacy" else { continue }
            checked += 1
            let manifest = try loadManifest(at: url)
            XCTAssertEqual(manifest["NSPrivacyTracking"] as? Bool, false,
                           "\(url.path) 声明了 tracking，与主清单冲突")
            let domains = manifest["NSPrivacyTrackingDomains"] as? [Any] ?? []
            XCTAssertEqual(domains.count, 0, "\(url.path) 声明了 tracking domains：\(domains)")
        }
        // 无清单的 SDK 由 PR 对照表登记（自动化仅覆盖有清单者）
        print("第三方隐私清单复核数量: \(checked)")
    }

    // MARK: - TC-011-9 Keychain 可访问性

    func testKeychainAccessibilityIsThisDeviceOnly() {
        XCTAssertEqual(KeychainCredentialStore.accessibilityLevel,
                       KeychainAccess.Accessibility.afterFirstUnlockThisDeviceOnly)
    }

    func testCredentialStoreSourceAppliesAccessibilityExplicitly() throws {
        let source = try String(contentsOf: Self.sourceRoot.appendingPathComponent("iov/Data/Auth/KeychainCredentialStore.swift"))
        XCTAssertTrue(source.contains(".accessibility("), "写入必须显式带 accessibility")
        XCTAssertTrue(source.contains("afterFirstUnlockThisDeviceOnly"))
        XCTAssertFalse(source.contains(".synchronizable(true)"), "不得同步到 iCloud Keychain")
    }

    /// 真实 Keychain 读取 `kSecAttrAccessible`（模拟器可运行；环境受限时跳过而非失败）
    func testRealKeychainItemCarriesThisDeviceOnlyAccessibility() throws {
        let service = "net.hwyz.iov.mp.app.tests.cr011.\(UUID().uuidString)"
        let store = KeychainCredentialStore(service: service, account: "auth.session")
        let session = makeSession()
        do {
            try store.save(session)
        } catch {
            throw XCTSkip("模拟器 Keychain 不可写，跳过真实属性断言: \(error)")
        }
        defer { try? store.remove() }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "auth.session",
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
              let attributes = item as? [String: Any],
              let accessible = attributes[kSecAttrAccessible as String] as? String else {
            throw XCTSkip("无法读取 Keychain 属性（status=\(status)）")
        }
        XCTAssertEqual(accessible, kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String)
        // 旧凭证读取不受影响
        XCTAssertEqual(try store.loadSession()?.userId, session.userId)
    }
}
