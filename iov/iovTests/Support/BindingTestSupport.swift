//
//  BindingTestSupport.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-011 on 2026/11/23.
//

import Foundation
import XCTest
@testable import iov

// MARK: - 绑定服务替身

/// 记录调用并按需回放的绑定服务替身（不依赖真实后端）
final class StubBindingService: VehicleBindingServiceProtocol {
    struct RelationshipCall {
        let context: VehiclePageContext
        let completion: (VehicleRelationshipState) -> Void
    }
    struct ScanCall {
        let qrToken: String
        let completion: (Result<ActivationScanResult, VehicleBindingFailure>) -> Void
    }
    struct CancelCall {
        let sessionId: String
        let completion: (Result<Void, VehicleBindingFailure>) -> Void
    }
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
        confirmCalls.append(ConfirmCall(sessionId: sessionId,
                                        idempotencyKey: idempotencyKey,
                                        completion: completion))
    }

    func queryBindingOperation(operationId: String,
                               completion: @escaping (Result<ActivationOperationResult, VehicleBindingFailure>) -> Void) {
        operationCalls.append(OperationCall(operationId: operationId, completion: completion))
    }
}

// MARK: - 手动调度器

/// 手动轮询调度器：记录退避时长，由用例显式触发，不依赖真实时间
final class ManualPollerScheduler: PollerScheduling {

    /// 已排程（未触发）的 tick
    private(set) var pending: [Scheduled] = []
    /// 历史退避序列（用于断言 1/2/4/8/8）
    private(set) var recordedDelays: [TimeInterval] = []

    var delays: [TimeInterval] { recordedDelays }
    var pendingCount: Int { pending.filter { !$0.isCancelled }.count }

    func schedule(after delay: TimeInterval, _ action: @escaping () -> Void) -> PollerCancellable {
        let entry = Scheduled(delay: delay, action: action)
        pending.append(entry)
        recordedDelays.append(delay)
        return ManualCancellable(entry: entry)
    }

    /// 触发最先排程且未取消的 tick（可能因 tick 结果而追加新的 tick）
    func fireNext() {
        guard let index = pending.firstIndex(where: { !$0.isCancelled }) else { return }
        let entry = pending.remove(at: index)
        entry.action()
    }

    /// 依次触发全部已排程 tick（最多 50 次，防误入无限循环）
    func fireAll() {
        var guardCount = 0
        while pending.contains(where: { !$0.isCancelled }), guardCount < 50 {
            guardCount += 1
            fireNext()
        }
    }

    final class Scheduled {
        let delay: TimeInterval
        let action: () -> Void
        private(set) var isCancelled = false

        init(delay: TimeInterval, action: @escaping () -> Void) {
            self.delay = delay
            self.action = action
        }

        func cancel() { isCancelled = true }
    }

    private final class ManualCancellable: PollerCancellable {
        private let entry: Scheduled
        init(entry: Scheduled) { self.entry = entry }
        func cancel() { entry.cancel() }
    }
}

// MARK: - 构造工具

func makeBindingScanResult(sessionId: String = "S-1",
                           vin: String? = "LSVAA123456789012",
                           state: String? = "SCANNED",
                           expiresAt: Int64? = nil,
                           claimed: Bool? = true) -> ActivationScanResult {
    ActivationScanResult(sessionId: sessionId, vin: vin, state: state,
                         expiresAt: expiresAt, claimed: claimed)
}

func makeBindingContext(account: String = "acc-1",
                        vehicle: String = "order-1",
                        vin: String? = "LSVAA123456789012") -> VehiclePageContext {
    VehiclePageContext(accountId: account, vehicleId: vehicle, vin: vin)
}
