//
//  VehicleBindingSessionStateTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-011 on 2026/11/23.
//

import XCTest
@testable import iov

/// TC-011-3：扫码响应状态机（仅 SCANNED + 未本地过期可确认；claimed 由服务端语义决定，不参与拦截）。
final class VehicleBindingSessionStateTests: XCTestCase {

    private let now = Date(timeIntervalSince1970: 1_795_255_200)

    private func session(state: String?,
                         claimed: Bool? = true,
                         expiresAt: Int64? = nil) -> VehicleBindingSession {
        VehicleBindingSession(sessionId: "S-1",
                              vin: "LSVAA123456789012",
                              state: ActivationSessionState.parse(serverValue: state),
                              expiresAt: expiresAt,
                              claimed: claimed)
    }

    // MARK: - 服务端状态解析

    func testUnknownServerStateIsPreservedInsteadOfDropped() {
        let parsed = ActivationSessionState.parse(serverValue: "FUTURE_STATE")
        XCTAssertEqual(parsed, .unknown(raw: "FUTURE_STATE"))
        XCTAssertNotEqual(parsed, .scanned)
        // 既有解析入口保持不变（未知 → nil），避免回归
        XCTAssertNil(ActivationSessionState(serverValue: "FUTURE_STATE"))
        XCTAssertEqual(ActivationSessionState(serverValue: "scanned"), .scanned)
        XCTAssertNil(ActivationSessionState.parse(serverValue: nil))
    }

    // MARK: - 可提交判定

    func testScannedUnexpiredSessionIsConfirmable() {
        XCTAssertTrue(session(state: "SCANNED").canConfirm(now: now))
        XCTAssertNil(session(state: "SCANNED").blockReason(now: now))
    }

    /// 服务端 `claimed=true` 表示“已被当前账号认领”（扫码成功恒为 true），
    /// 不得作为“被其他账号占用”的本地拦截依据，否则每次扫码都会被挡住。
    func testClaimedByCurrentAccountDoesNotBlockConfirm() {
        let claimed = session(state: "SCANNED", claimed: true)
        XCTAssertTrue(claimed.canConfirm(now: now))
        XCTAssertNil(claimed.blockReason(now: now))
    }

    func testUnknownClaimValueDoesNotBlockConfirm() {
        XCTAssertTrue(session(state: "SCANNED", claimed: nil).canConfirm(now: now))
        XCTAssertTrue(session(state: "SCANNED", claimed: false).canConfirm(now: now))
    }

    func testLocalExpiryBlocksConfirm() {
        let expiredMillis = Int64(now.addingTimeInterval(-1).timeIntervalSince1970 * 1000)
        let expired = session(state: "SCANNED", expiresAt: expiredMillis)
        XCTAssertTrue(expired.isLocallyExpired(now: now))
        XCTAssertFalse(expired.canConfirm(now: now))
        XCTAssertEqual(expired.blockReason(now: now), .expired)
    }

    func testNilExpiryDefersToServer() {
        let noExpiry = session(state: "SCANNED", expiresAt: nil)
        XCTAssertFalse(noExpiry.isLocallyExpired(now: now))
        XCTAssertTrue(noExpiry.canConfirm(now: now))
    }

    func testNonScannedStatesAreNeverConfirmable() {
        let cases: [(String, VehicleBindingSessionBlockReason)] = [
            ("BOUND", .bound),
            ("EXPIRED", .expired),
            ("CANCELLED", .cancelled),
            ("SKIPPED", .skipped),
            ("ISSUED", .issued),
            ("FUTURE_STATE", .unknown)
        ]
        for (state, expected) in cases {
            let value = session(state: state)
            XCTAssertFalse(value.canConfirm(now: now), "state=\(state)")
            XCTAssertEqual(value.blockReason(now: now), expected, "state=\(state)")
        }
    }

    func testNilStateIsNotConfirmable() {
        let value = session(state: nil)
        XCTAssertFalse(value.canConfirm(now: now))
        XCTAssertEqual(value.blockReason(now: now), .unknown)
    }

    func testBlockReasonProvidesLocalizationKeys() {
        XCTAssertEqual(VehicleBindingSessionBlockReason.expired.localizationKey,
                       "vehicle_binding_session_expired_hint")
        XCTAssertEqual(VehicleBindingSessionBlockReason.cancelled.localizationKey,
                       "vehicle_binding_session_cancelled_hint")
        XCTAssertEqual(VehicleBindingSessionBlockReason.skipped.localizationKey,
                       "vehicle_binding_session_skipped_hint")
        XCTAssertEqual(VehicleBindingSessionBlockReason.issued.localizationKey,
                       "vehicle_binding_session_issued_hint")
        XCTAssertEqual(VehicleBindingSessionBlockReason.unknown.localizationKey,
                       "vehicle_binding_session_unknown_hint")
    }

    // MARK: - 扫码失败分类（弹窗按钮）

    func testRetryableFailuresAllowRetryWithSameToken() {
        let retryable: [VehicleBindingFailure] = [.network, .dependencyUnavailable, .invalidResponse,
                                                  .unknown, .server(message: nil)]
        for failure in retryable {
            XCTAssertEqual(failure.scanFailureAction, .retryWithSameToken, "failure=\(failure)")
            XCTAssertTrue(failure.scanFailureAction.allowsRetry)
        }
    }

    func testNeedsNewQRFailuresNeverAllowRetry() {
        let cases: [VehicleBindingFailure] = [.sessionInvalid, .sessionExpired, .sessionCancelled,
                                              .sessionClaimed, .vehicleMismatch, .agreementNotAccepted,
                                              .invalidRequest]
        for failure in cases {
            XCTAssertEqual(failure.scanFailureAction, .needsNewQr, "failure=\(failure)")
            XCTAssertFalse(failure.scanFailureAction.allowsRetry)
        }
    }

    func testManualFailuresNeverAllowRetryOrLogin() {
        let cases: [VehicleBindingFailure] = [.vehicleNotFound, .eligibilityRejected,
                                              .eligibilityUndetermined, .relationConflict,
                                              .idempotencyConflict, .forbidden]
        for failure in cases {
            XCTAssertEqual(failure.scanFailureAction, .needsManual, "failure=\(failure)")
            XCTAssertFalse(failure.scanFailureAction.allowsRetry)
            XCTAssertFalse(failure.scanFailureAction.allowsLogin)
        }
    }

    func testAuthenticationFailuresAskForLogin() {
        for failure in [VehicleBindingFailure.authenticationSessionExpired, .authenticationRejected] {
            XCTAssertEqual(failure.scanFailureAction, .needsLogin)
            XCTAssertTrue(failure.scanFailureAction.allowsLogin)
            XCTAssertFalse(failure.scanFailureAction.allowsRetry)
        }
    }

    func testForbiddenIsNotRetryableAndNotAuthentication() {
        XCTAssertFalse(VehicleBindingFailure.forbidden.isRetryableWithSameKey)
        XCTAssertFalse(VehicleBindingFailure.forbidden.isAuthenticationFailure)
        XCTAssertEqual(VehicleBindingFailure.forbidden.localizationKey, "vehicle_binding_error_forbidden")
    }

    func testInvalidResponseIsRetryableButNotAuthentication() {
        XCTAssertTrue(VehicleBindingFailure.invalidResponse.isRetryableWithSameKey)
        XCTAssertFalse(VehicleBindingFailure.invalidResponse.isAuthenticationFailure)
    }
}
