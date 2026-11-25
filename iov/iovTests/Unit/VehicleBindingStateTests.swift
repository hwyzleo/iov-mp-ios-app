//
//  VehicleBindingStateTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-010 on 2026/11/21.
//

import XCTest
@testable import iov

/// TC-010-1 / TC-010-4 / TC-010-5 的纯状态断言：
/// 关系未知、加载、失败都不得被当成“当前账号未绑定”，也不得据此展示绑定主 CTA。
final class VehicleBindingStateTests: XCTestCase {

    // MARK: - 展示态派生

    func testLoadingRelationshipNeverDerivesUnbound() {
        let state = VehiclePageDisplayState.derive(relationship: .loading, login: .unknown)
        XCTAssertEqual(state, .loading)
        XCTAssertNotEqual(state, .unbound)
    }

    func testUnboundRequiresExplicitAuthorityResult() {
        XCTAssertEqual(
            VehiclePageDisplayState.derive(relationship: .unboundForCurrentAccount, login: .unknown),
            .unbound
        )
    }

    func testUnknownRelationshipNeverDerivesUnboundForEveryReason() {
        let reasons: [VehicleRelationshipUnavailableReason] = [
            .capabilityUnavailable, .network, .authenticationRejected, .serverError, .invalidResponse
        ]
        for reason in reasons {
            let state = VehiclePageDisplayState.derive(relationship: .unknown(reason), login: .unknown)
            XCTAssertEqual(state, .unknown, "reason=\(reason)")
            XCTAssertNotEqual(state, .unbound, "reason=\(reason)")
        }
    }

    func testBoundWithUnknownLoginShowsLoginGuidanceInsteadOfClaimingLogin() {
        let state = VehiclePageDisplayState.derive(relationship: .bound(relationId: "REL-1"), login: .unknown)
        XCTAssertEqual(state, .boundLoginPending)
        XCTAssertEqual(
            VehiclePageDisplayState.derive(relationship: .bound(relationId: "REL-1"), login: .succeeded),
            .bound
        )
        XCTAssertEqual(
            VehiclePageDisplayState.derive(relationship: .bound(relationId: "REL-1"), login: .failed),
            .boundLoginPending
        )
    }

    func testRelationshipHelpers() {
        XCTAssertTrue(VehicleRelationshipState.bound(relationId: nil).isBound)
        XCTAssertTrue(VehicleRelationshipState.unboundForCurrentAccount.isUnbound)
        XCTAssertTrue(VehicleRelationshipState.loading.isLoading)
        XCTAssertTrue(VehicleRelationshipState.unknown(.network).isUnknown)
        XCTAssertFalse(VehicleRelationshipState.unknown(.network).isUnbound)
    }

    // MARK: - VIN 脱敏

    func testMaskedVinKeepsPrefixAndSuffixOnly() {
        XCTAssertEqual(VehicleVinMask.mask("LSVAA123456789012"), "LSV****9012")
        XCTAssertEqual(VehicleVinMask.mask("ABC1234"), "****")
        XCTAssertNil(VehicleVinMask.mask(nil))
        XCTAssertNil(VehicleVinMask.mask("   "))
    }

    func testVinValidationMatchesServerIso3779Rules() {
        XCTAssertEqual(VehicleVin.normalize(" lsvaa123456789012 "), "LSVAA123456789012")
        XCTAssertTrue(VehicleVin.isValid(" lsvaa123456789012 "))
        XCTAssertFalse(VehicleVin.isValid("VIN00000000000001"), "I/O/Q 不允许")
        XCTAssertFalse(VehicleVin.isValid("LSVAA12345678901"), "长度不足")
        XCTAssertFalse(VehicleVin.isValid(nil))
        XCTAssertFalse(VehicleVin.isValid("   "))
    }

    // MARK: - 错误码 / reason 映射

    func testTspBindingErrorCodesMapToStableFailures() {
        let expected: [String: VehicleBindingFailure] = [
            "401101": .sessionInvalid,
            "401102": .sessionExpired,
            "401103": .sessionCancelled,
            "401104": .sessionClaimed,
            "401105": .vehicleNotFound,
            "401106": .eligibilityRejected,
            "401107": .eligibilityUndetermined,
            "401108": .dependencyUnavailable,
            "401109": .relationConflict,
            "401110": .idempotencyConflict,
            "401111": .agreementNotAccepted,
            "401112": .invalidRequest
        ]
        for (code, failure) in expected {
            XCTAssertEqual(VehicleBindingFailure.from(code: code), failure, "code=\(code)")
        }
    }

    func testUnknownCodeFallsBackToServerMessageWithoutLosingInformation() {
        XCTAssertEqual(
            VehicleBindingFailure.from(code: "401199", message: "服务繁忙"),
            .server(message: "服务繁忙")
        )
        XCTAssertEqual(VehicleBindingFailure.from(code: "401199", message: nil), .unknown)
    }

    func testBindingResultReasonsMapToFailures() {
        XCTAssertEqual(VehicleBindingFailure.from(reason: "RELATION_CONFLICT"), .relationConflict)
        XCTAssertEqual(VehicleBindingFailure.from(reason: "DEPENDENCY_UNAVAILABLE"), .dependencyUnavailable)
        XCTAssertEqual(VehicleBindingFailure.from(reason: nil), .unknown)
        XCTAssertEqual(VehicleBindingFailure.from(reason: "PENDING"), .unknown)
    }

    func testOnlyTransientFailuresAllowSameIdempotencyKeyRetry() {
        XCTAssertTrue(VehicleBindingFailure.network.isRetryableWithSameKey)
        XCTAssertTrue(VehicleBindingFailure.dependencyUnavailable.isRetryableWithSameKey)
        XCTAssertTrue(VehicleBindingFailure.unknown.isRetryableWithSameKey)
        XCTAssertFalse(VehicleBindingFailure.relationConflict.isRetryableWithSameKey)
        XCTAssertFalse(VehicleBindingFailure.sessionExpired.isRetryableWithSameKey)
        XCTAssertFalse(VehicleBindingFailure.invalidRequest.isRetryableWithSameKey)
    }

    // MARK: - 服务端枚举解析

    func testUnrecognizedServerEnumsStayUnknownInsteadOfGuessing() {
        XCTAssertNil(ActivationBindingStatus(serverValue: "WHATEVER"))
        XCTAssertNil(ActivationBindingStatus(serverValue: nil))
        XCTAssertEqual(ActivationBindingStatus(serverValue: "succeeded"), .succeeded)

        XCTAssertNil(ActivationSessionState(serverValue: "WHATEVER"))
        XCTAssertEqual(ActivationSessionState(serverValue: "scanned"), .scanned)
    }

    // MARK: - 上下文隔离键

    func testContextIsolationKeyIncludesAccountVehicleAndVin() {
        let a = VehiclePageContext(accountId: "acc-1", vehicleId: "order-1", vin: "VIN1")
        let b = VehiclePageContext(accountId: "acc-1", vehicleId: "order-1", vin: "VIN2")
        let c = VehiclePageContext(accountId: "acc-2", vehicleId: "order-1", vin: "VIN1")
        XCTAssertNotEqual(a.isolationKey, b.isolationKey)
        XCTAssertNotEqual(a.isolationKey, c.isolationKey)
        XCTAssertFalse(VehiclePageContext(accountId: "", vehicleId: "order-1", vin: nil).hasAccountAndVehicle)
    }
}
