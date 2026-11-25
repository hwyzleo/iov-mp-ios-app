//
//  VehicleBindingCoordinatorTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-010 on 2026/11/21.
//

import XCTest
@testable import iov

/// TC-010-3 / TC-010-6：幂等、结果恢复、上下文隔离与迟到响应丢弃。
final class VehicleBindingCoordinatorTests: XCTestCase {

    private func context(account: String = "acc-1",
                         vehicle: String = "order-1",
                         vin: String? = "VIN00000000000001") -> VehiclePageContext {
        VehiclePageContext(accountId: account, vehicleId: vehicle, vin: vin)
    }

    private func scanResult(sessionId: String = "S-1",
                            vin: String? = "VIN00000000000001",
                            state: String? = "SCANNED") -> ActivationScanResult {
        // 服务端扫码成功恒返回 claimed=true，且 claimed 不参与本地可提交判定
        ActivationScanResult(sessionId: sessionId, vin: vin, state: state, expiresAt: nil, claimed: true)
    }

    // MARK: - 上下文隔离

    func testLateRelationshipResponseFromPreviousContextIsDropped() {
        let service = StubVehicleBindingService()
        let coordinator = makeCoordinator(service)
        let contextA = context(vehicle: "order-A")
        let contextB = context(vehicle: "order-B")
        var received: [(VehiclePageContext, VehicleRelationshipState)] = []
        coordinator.onRelationship = { received.append(($0, $1)) }

        coordinator.start(context: contextA)
        coordinator.start(context: contextB)
        XCTAssertEqual(service.relationshipCalls.count, 2)

        received.removeAll()
        // A 的迟到响应必须被丢弃
        service.relationshipCalls[0].completion(.unboundForCurrentAccount)
        XCTAssertTrue(received.isEmpty)

        service.relationshipCalls[1].completion(.unknown(.capabilityUnavailable))
        XCTAssertEqual(received.count, 1)
        XCTAssertEqual(received.first?.0, contextB)
    }

    func testLateScanResponseAfterInvalidateIsDropped() {
        let service = StubVehicleBindingService()
        let coordinator = makeCoordinator(service)
        var sessions: [VehicleBindingSession?] = []
        coordinator.onSession = { _, session in sessions.append(session) }

        coordinator.start(context: context())
        coordinator.beginScan(qrToken: "qr-token")
        XCTAssertEqual(service.scanCalls.count, 1)

        coordinator.invalidate()
        service.scanCalls[0].completion(.success(scanResult()))

        XCTAssertTrue(sessions.allSatisfy { $0 == nil })
        XCTAssertNil(coordinator.session)
    }

    func testMissingAccountOrVehicleStaysUnknown() {
        let service = StubVehicleBindingService()
        let coordinator = makeCoordinator(service)
        var states: [VehicleRelationshipState] = []
        coordinator.onRelationship = { _, state in states.append(state) }

        coordinator.start(context: context(account: ""))

        XCTAssertEqual(states.last, .unknown(.capabilityUnavailable))
        XCTAssertTrue(service.relationshipCalls.isEmpty)
    }

    // MARK: - 幂等与结果恢复

    func testConfirmReusesSameIdempotencyKeyAfterUnknownResult() {
        let service = StubVehicleBindingService()
        let coordinator = makeCoordinator(service)
        coordinator.start(context: context())
        coordinator.beginScan(qrToken: "qr-token")
        service.scanCalls[0].completion(.success(scanResult()))

        coordinator.confirm()
        XCTAssertEqual(service.confirmCalls.count, 1)
        let firstKey = service.confirmCalls[0].idempotencyKey
        service.confirmCalls[0].completion(.failure(.network))
        XCTAssertEqual(coordinator.operationState, .resultUnknown(operationId: nil))

        // 响应丢失：按原幂等键重试，不新建绑定
        coordinator.refreshBindingResult()
        XCTAssertEqual(service.confirmCalls.count, 2)
        XCTAssertEqual(service.confirmCalls[1].idempotencyKey, firstKey)
        XCTAssertEqual(service.confirmCalls[1].sessionId, "S-1")
    }

    func testPendingConfirmQueriesOriginalOperationInsteadOfCreatingNewBinding() {
        let service = StubVehicleBindingService()
        let coordinator = makeCoordinator(service)
        coordinator.start(context: context())
        coordinator.beginScan(qrToken: "qr-token")
        service.scanCalls[0].completion(.success(scanResult()))

        coordinator.confirm()
        service.confirmCalls[0].completion(.success(
            ActivationConfirmResult(operationId: "OP-1", status: "PENDING", reason: nil,
                                    relationId: nil, vin: nil, completedAt: nil)
        ))
        XCTAssertEqual(coordinator.operationState, .resultUnknown(operationId: "OP-1"))

        coordinator.refreshBindingResult()
        XCTAssertEqual(service.confirmCalls.count, 1, "PENDING 不得新建绑定操作")
        XCTAssertEqual(service.operationCalls.map(\.operationId), ["OP-1"])

        service.operationCalls[0].completion(.success(
            ActivationOperationResult(operationId: "OP-1", status: "SUCCEEDED", reason: nil,
                                      relationId: "REL-1", vin: "VIN00000000000001",
                                      sessionId: "S-1", completedAt: nil)
        ))
        XCTAssertEqual(coordinator.operationState, .succeeded(relationId: "REL-1"))
        XCTAssertEqual(coordinator.lastKnownRelationship, .bound(relationId: "REL-1"))
    }

    func testTerminalFailureClearsIdempotencyKeyForNextAttempt() {
        let service = StubVehicleBindingService()
        let coordinator = makeCoordinator(service, keys: ["KEY-1", "KEY-2"])
        coordinator.start(context: context())
        coordinator.beginScan(qrToken: "qr-token")
        service.scanCalls[0].completion(.success(scanResult()))

        coordinator.confirm()
        service.confirmCalls[0].completion(.success(
            ActivationConfirmResult(operationId: "OP-1", status: "FAILED", reason: "RELATION_CONFLICT",
                                    relationId: nil, vin: nil, completedAt: nil)
        ))
        XCTAssertEqual(coordinator.operationState, .failed(.relationConflict))
        XCTAssertNil(coordinator.idempotencyKey)

        coordinator.confirm()
        XCTAssertEqual(service.confirmCalls.count, 2)
        XCTAssertEqual(service.confirmCalls[0].idempotencyKey, "KEY-1")
        XCTAssertEqual(service.confirmCalls[1].idempotencyKey, "KEY-2")
    }

    func testDependencyUnavailableKeepsSameKeyForRetry() {
        let service = StubVehicleBindingService()
        let coordinator = makeCoordinator(service)
        coordinator.start(context: context())
        coordinator.beginScan(qrToken: "qr-token")
        service.scanCalls[0].completion(.success(scanResult()))

        coordinator.confirm()
        let key = service.confirmCalls[0].idempotencyKey
        service.confirmCalls[0].completion(.failure(.dependencyUnavailable))
        XCTAssertEqual(coordinator.operationState, .resultUnknown(operationId: nil))

        coordinator.confirm()
        XCTAssertEqual(service.confirmCalls[1].idempotencyKey, key)
    }

    // MARK: - 扫码与取消

    func testScannedVehicleMismatchCancelsSessionAndDoesNotExposeIt() {
        let service = StubVehicleBindingService()
        let coordinator = makeCoordinator(service)
        var failures: [VehicleBindingFailure] = []
        var sessions: [VehicleBindingSession?] = []
        coordinator.onScanFailure = { _, failure in failures.append(failure) }
        coordinator.onSession = { _, session in sessions.append(session) }

        coordinator.start(context: context(vin: "VIN-A"))
        coordinator.beginScan(qrToken: "qr-token")
        service.scanCalls[0].completion(.success(scanResult(sessionId: "S-9", vin: "VIN-B")))

        XCTAssertEqual(failures, [.vehicleMismatch])
        XCTAssertEqual(service.cancelCalls.map(\.sessionId), ["S-9"])
        XCTAssertNil(coordinator.session)
        XCTAssertTrue(sessions.allSatisfy { $0 == nil })
    }

    func testScanWithoutLocalVinIsAllowedBecauseServerValidatesSession() {
        let service = StubVehicleBindingService()
        let coordinator = makeCoordinator(service)
        coordinator.start(context: context(vin: nil))
        coordinator.beginScan(qrToken: "qr-token")
        service.scanCalls[0].completion(.success(scanResult(sessionId: "S-1", vin: "VIN-B")))
        XCTAssertEqual(coordinator.session?.sessionId, "S-1")
    }

    func testCancelClearsSessionWithoutTouchingRelationship() {
        let service = StubVehicleBindingService()
        let coordinator = makeCoordinator(service)
        var relationship: [VehicleRelationshipState] = []
        coordinator.onRelationship = { _, state in relationship.append(state) }
        coordinator.start(context: context())
        coordinator.beginScan(qrToken: "qr-token")
        service.scanCalls[0].completion(.success(scanResult(sessionId: "S-1")))

        var cancelled = false
        coordinator.cancelSession { cancelled = true }
        service.cancelCalls[0].completion(.success(()))
        XCTAssertTrue(cancelled)
        XCTAssertNil(coordinator.session)
        XCTAssertFalse(relationship.contains(.unboundForCurrentAccount))
    }

    func testScanFailureIsReportedWithoutSession() {
        let service = StubVehicleBindingService()
        let coordinator = makeCoordinator(service)
        var failures: [VehicleBindingFailure] = []
        coordinator.onScanFailure = { _, failure in failures.append(failure) }
        coordinator.start(context: context())
        coordinator.beginScan(qrToken: "qr-token")
        service.scanCalls[0].completion(.failure(.sessionExpired))
        XCTAssertEqual(failures, [.sessionExpired])
        XCTAssertNil(coordinator.session)
    }

    // MARK: - Helpers

    private func makeCoordinator(_ service: StubVehicleBindingService,
                                 keys: [String] = ["KEY-1"]) -> VehicleBindingCoordinator {
        let sequence = KeySequence(keys: keys)
        return VehicleBindingCoordinator(service: service,
                                         idempotencyKeyGenerator: { sequence.next() })
    }
}

// MARK: - 测试替身

private final class KeySequence {
    private var keys: [String]
    private var index = 0
    init(keys: [String]) { self.keys = keys }
    func next() -> String {
        defer { index += 1 }
        return index < keys.count ? keys[index] : "KEY-\(index + 1)"
    }
}

private final class StubVehicleBindingService: VehicleBindingServiceProtocol {
    struct RelationshipCall { let context: VehiclePageContext; let completion: (VehicleRelationshipState) -> Void }
    struct ScanCall { let qrToken: String; let completion: (Result<ActivationScanResult, VehicleBindingFailure>) -> Void }
    struct CancelCall { let sessionId: String; let completion: (Result<Void, VehicleBindingFailure>) -> Void }
    struct ConfirmCall {
        let sessionId: String
        let idempotencyKey: String
        let completion: (Result<ActivationConfirmResult, VehicleBindingFailure>) -> Void
    }
    struct OperationCall {
        let operationId: String
        let completion: (Result<ActivationOperationResult, VehicleBindingFailure>) -> Void
    }

    private(set) var relationshipCalls: [RelationshipCall] = []
    private(set) var scanCalls: [ScanCall] = []
    private(set) var cancelCalls: [CancelCall] = []
    private(set) var confirmCalls: [ConfirmCall] = []
    private(set) var operationCalls: [OperationCall] = []

    func queryRelationship(context: VehiclePageContext,
                           completion: @escaping (VehicleRelationshipState) -> Void) {
        relationshipCalls.append(RelationshipCall(context: context, completion: completion))
    }

    func scanActivationSession(qrToken: String,
                               completion: @escaping (Result<ActivationScanResult, VehicleBindingFailure>) -> Void) {
        scanCalls.append(ScanCall(qrToken: qrToken, completion: completion))
    }

    func cancelActivationSession(sessionId: String,
                                 completion: @escaping (Result<Void, VehicleBindingFailure>) -> Void) {
        cancelCalls.append(CancelCall(sessionId: sessionId, completion: completion))
    }

    func confirmVehicleBinding(sessionId: String,
                               idempotencyKey: String,
                               completion: @escaping (Result<ActivationConfirmResult, VehicleBindingFailure>) -> Void) {
        confirmCalls.append(ConfirmCall(sessionId: sessionId, idempotencyKey: idempotencyKey, completion: completion))
    }

    func queryBindingOperation(operationId: String,
                               completion: @escaping (Result<ActivationOperationResult, VehicleBindingFailure>) -> Void) {
        operationCalls.append(OperationCall(operationId: operationId, completion: completion))
    }
}
