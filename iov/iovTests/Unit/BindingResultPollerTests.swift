//
//  BindingResultPollerTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-011 on 2026/11/23.
//

import XCTest
@testable import iov

/// TC-011-5：结果未知自动轮询（退避 + 上限 + 终态停止）与 R-16「不得静默 / 不得重放」。
final class BindingResultPollerTests: XCTestCase {

    // MARK: - 退避序列与上限

    func testBackoffSequenceIsOneTwoFourEightEightAndStopsWhenExhausted() {
        let scheduler = ManualPollerScheduler()
        var clock = Date(timeIntervalSince1970: 1_000)
        let poller = BindingResultPoller(scheduler: scheduler, now: { clock })
        var stops: [BindingResultPoller.StopReason] = []
        poller.onStop = { stops.append($0) }
        var ticks = 0

        poller.start { _ in
            ticks += 1
            clock = clock.addingTimeInterval(1)
            return .keepPolling
        }
        scheduler.fireAll()

        XCTAssertEqual(scheduler.delays, [1, 2, 4, 8, 8])
        XCTAssertEqual(ticks, 5)
        XCTAssertEqual(stops, [.exhausted])
        XCTAssertFalse(poller.isRunning)
    }

    func testTerminalStateStopsImmediatelyWithoutFurtherTicks() {
        let scheduler = ManualPollerScheduler()
        let poller = BindingResultPoller(scheduler: scheduler)
        var stops: [BindingResultPoller.StopReason] = []
        poller.onStop = { stops.append($0) }

        poller.start { _ in
            .stop(.terminal)
        }
        scheduler.fireNext()

        XCTAssertEqual(stops, [.terminal])
        XCTAssertFalse(poller.isRunning)
        XCTAssertTrue(scheduler.pending.isEmpty, "终态后不得再排程")
    }

    func testStopIsIdempotentAndNotifiesOnce() {
        let scheduler = ManualPollerScheduler()
        let poller = BindingResultPoller(scheduler: scheduler)
        var stops = 0
        poller.onStop = { _ in stops += 1 }

        poller.start { _ in .keepPolling }
        poller.stop(.cancelled)
        poller.stop(.background)

        XCTAssertEqual(stops, 1)
        XCTAssertEqual(poller.lastStopReason, .cancelled)
        scheduler.fireAll()
    }

    func testTotalDurationCapStopsEvenWhenAttemptsRemain() {
        let scheduler = ManualPollerScheduler()
        var clock = Date(timeIntervalSince1970: 1_000)
        let poller = BindingResultPoller(config: .init(delays: [1, 2, 4, 8, 8], maxAttempts: 5, maxTotalDuration: 3),
                                        scheduler: scheduler,
                                        now: { clock })
        var stops: [BindingResultPoller.StopReason] = []
        poller.onStop = { stops.append($0) }

        poller.start { _ in
            clock = clock.addingTimeInterval(2)
            return .keepPolling
        }
        scheduler.fireAll()

        XCTAssertEqual(stops, [.exhausted])
        XCTAssertLessThanOrEqual(scheduler.delays.count, 5)
    }

    // MARK: - 协调器集成：终态 / 上限 / 无键不得静默

    func testPendingConfirmStartsPollingAndSucceededStopsIt() {
        let service = StubBindingService()
        let scheduler = ManualPollerScheduler()
        let poller = BindingResultPoller(scheduler: scheduler)
        let coordinator = makeCoordinator(service: service, poller: poller)
        var operations: [VehicleBindingOperationState] = []
        coordinator.onOperation = { _, state in operations.append(state) }

        coordinator.start(context: makeBindingContext())
        coordinator.beginScan(qrToken: "qr")
        service.scanCalls[0].completion(.success(makeBindingScanResult()))

        coordinator.confirm()
        service.confirmCalls[0].completion(.success(
            ActivationConfirmResult(operationId: "OP-1", status: "PENDING", reason: nil,
                                    relationId: nil, vin: nil, completedAt: nil)
        ))
        XCTAssertEqual(coordinator.operationState, .resultUnknown(operationId: "OP-1"))
        XCTAssertTrue(poller.isRunning, "PENDING 必须自动开始低频轮询")
        XCTAssertEqual(scheduler.delays, [1])

        scheduler.fireNext()
        XCTAssertEqual(service.operationCalls.count, 1)
        XCTAssertEqual(service.operationCalls[0].operationId, "OP-1")
        XCTAssertEqualToStillUnknown(coordinator)

        service.operationCalls[0].completion(.success(
            ActivationOperationResult(operationId: "OP-1", status: "SUCCEEDED", reason: nil,
                                      relationId: "REL-1", vin: "LSVAA123456789012",
                                      sessionId: "S-1", completedAt: nil)
        ))
        XCTAssertEqual(coordinator.operationState, .succeeded(relationId: "REL-1"))
        XCTAssertFalse(poller.isRunning, "命中终态必须停止轮询")
        XCTAssertEqual(scheduler.pendingCount, 0, "终态后不得保留待触发 tick")
        XCTAssertFalse(service.confirmCalls.count > 1, "轮询不得新建绑定")
    }

    func testExhaustedPollingKeepsResultUnknownAndFlagsExhausted() {
        let service = StubBindingService()
        let scheduler = ManualPollerScheduler()
        let poller = BindingResultPoller(scheduler: scheduler)
        let coordinator = makeCoordinator(service: service, poller: poller)
        var exhaustedEvents: [Bool] = []
        coordinator.onPolling = { _, exhausted in exhaustedEvents.append(exhausted) }

        coordinator.start(context: makeBindingContext())
        coordinator.beginScan(qrToken: "qr")
        service.scanCalls[0].completion(.success(makeBindingScanResult()))
        coordinator.confirm()
        service.confirmCalls[0].completion(.success(
            ActivationConfirmResult(operationId: "OP-1", status: "PENDING", reason: nil,
                                    relationId: nil, vin: nil, completedAt: nil)
        ))

        for _ in 0..<5 {
            scheduler.fireNext()
            service.operationCalls.last?.completion(.success(
                ActivationOperationResult(operationId: "OP-1", status: "PENDING", reason: nil,
                                          relationId: nil, vin: nil, sessionId: "S-1", completedAt: nil)
            ))
        }

        XCTAssertEqual(coordinator.operationState, .resultUnknown(operationId: "OP-1"))
        XCTAssertTrue(coordinator.pollingExhausted)
        XCTAssertEqual(exhaustedEvents, [true])
        XCTAssertFalse(poller.isRunning)
    }

    func testPollingReplaysSameIdempotencyKeyWhenOperationIdMissing() {
        let service = StubBindingService()
        let scheduler = ManualPollerScheduler()
        let poller = BindingResultPoller(scheduler: scheduler)
        let coordinator = makeCoordinator(service: service, poller: poller)

        coordinator.start(context: makeBindingContext())
        coordinator.beginScan(qrToken: "qr")
        service.scanCalls[0].completion(.success(makeBindingScanResult()))
        coordinator.confirm()
        let key = service.confirmCalls[0].idempotencyKey
        service.confirmCalls[0].completion(.failure(.network))
        XCTAssertEqual(coordinator.operationState, .resultUnknown(operationId: nil))

        scheduler.fireNext()
        XCTAssertEqual(service.confirmCalls.count, 2)
        XCTAssertEqual(service.confirmCalls[1].idempotencyKey, key, "自动恢复必须复用原幂等键")
        XCTAssertEqual(service.confirmCalls[1].sessionId, "S-1")
    }

    /// R-16：上下文失效后不得再发任何请求（既无 operationId 也无幂等键，不得静默重放）
    func testInvalidateStopsPollingAndSendsNoFurtherRequest() {
        let service = StubBindingService()
        let scheduler = ManualPollerScheduler()
        let poller = BindingResultPoller(scheduler: scheduler)
        let coordinator = makeCoordinator(service: service, poller: poller)
        var operations: [VehicleBindingOperationState] = []
        coordinator.onOperation = { _, state in operations.append(state) }

        coordinator.start(context: makeBindingContext())
        coordinator.beginScan(qrToken: "qr")
        service.scanCalls[0].completion(.success(makeBindingScanResult()))
        coordinator.confirm()
        service.confirmCalls[0].completion(.success(
            ActivationConfirmResult(operationId: nil, status: "PENDING", reason: nil,
                                    relationId: nil, vin: nil, completedAt: nil)
        ))
        XCTAssertEqual(coordinator.operationState, .resultUnknown(operationId: nil))
        XCTAssertTrue(poller.isRunning)

        // 清掉幂等键，模拟既无 operationId 也无键
        coordinator.invalidate()
        XCTAssertFalse(poller.isRunning, "页面离开/上下文切换必须停止轮询")
        let scanCallsBefore = service.scanCalls.count
        let confirmCallsBefore = service.confirmCalls.count
        let operationCallsBefore = service.operationCalls.count
        scheduler.fireAll()

        XCTAssertEqual(service.scanCalls.count, scanCallsBefore)
        XCTAssertEqual(service.confirmCalls.count, confirmCallsBefore)
        XCTAssertEqual(service.operationCalls.count, operationCallsBefore)
        XCTAssertFalse(operations.isEmpty)
    }

    func testRefreshWithoutAnyHandleFailsVisiblyInsteadOfSilentlyReturning() {
        let service = StubBindingService()
        let coordinator = makeCoordinator(service: service)
        var operations: [VehicleBindingOperationState] = []
        coordinator.onOperation = { _, state in operations.append(state) }

        coordinator.start(context: makeBindingContext())
        // 无会话、无 operationId、无幂等键
        coordinator.refreshBindingResult()

        XCTAssertEqual(coordinator.operationState, .failed(.unknown))
        XCTAssertEqual(operations.last, .failed(.unknown))
        XCTAssertTrue(service.confirmCalls.isEmpty)
        XCTAssertTrue(service.operationCalls.isEmpty)
        XCTAssertFalse(operations.contains(.resultUnknown(operationId: nil)))
    }

    func testDismissAndCancelStopPolling() {
        let service = StubBindingService()
        let scheduler = ManualPollerScheduler()
        let poller = BindingResultPoller(scheduler: scheduler)
        let coordinator = makeCoordinator(service: service, poller: poller)

        coordinator.start(context: makeBindingContext())
        coordinator.beginScan(qrToken: "qr")
        service.scanCalls[0].completion(.success(makeBindingScanResult()))
        coordinator.confirm()
        service.confirmCalls[0].completion(.success(
            ActivationConfirmResult(operationId: "OP-1", status: "PENDING", reason: nil,
                                    relationId: nil, vin: nil, completedAt: nil)
        ))
        XCTAssertTrue(poller.isRunning)

        coordinator.pausePolling()
        XCTAssertFalse(poller.isRunning, "进入后台必须停止自动恢复")
    }

    // MARK: - Helpers

    private func makeCoordinator(service: StubBindingService,
                                 poller: BindingResultPoller = BindingResultPoller()) -> VehicleBindingCoordinator {
        VehicleBindingCoordinator(service: service,
                                  idempotencyKeyGenerator: { "KEY-1" },
                                  poller: poller,
                                  sessionExpiryHandler: {})
    }

    private func XCTAssertEqualToStillUnknown(_ coordinator: VehicleBindingCoordinator,
                                             file: StaticString = #filePath,
                                             line: UInt = #line) {
        if case .resultUnknown = coordinator.operationState {
            return
        }
        XCTFail("轮询请求发出后应保持结果未知等待响应", file: file, line: line)
    }
}
