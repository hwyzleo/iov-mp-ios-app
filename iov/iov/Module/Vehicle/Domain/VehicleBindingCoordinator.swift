//
//  VehicleBindingCoordinator.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-010 on 2026/11/21.
//  Updated by CR IOS-APP-DSN-CR-011 on 2026/11/23（D-011-2 状态机 / D-011-3 轮询 / D-011-4 错误分层）.
//

import Foundation

/// 车辆绑定交互编排（与 UI 无关，可单测）。
///
/// 设计依据：IOS-APP-DSN-CR-010 D-010-3 / D-010-4 / D-010-5；
/// IOS-APP-DSN-CR-011 D-011-2 / D-011-3 / D-011-4（第 1 轮裁决 R-16）。
/// - 以 `(accountId, vehicleId, VIN)` 上下文 + 代次隔离迟到响应；
/// - 同一确认操作复用幂等键，结果未知只按原 operationId / 原幂等键恢复；
/// - 扫码返回的车辆与当前车辆不一致时终止当前车绑定；
/// - 扫码会话状态机：仅 `SCANNED` + 未被占用 + 未本地过期才允许确认；
/// - 结果未知时按退避轮询恢复，终态/认证失败/无键无 operationId 一律停止且禁止重放。
final class VehicleBindingCoordinator {

    typealias RelationshipHandler = (VehiclePageContext, VehicleRelationshipState) -> Void
    typealias SessionHandler = (VehiclePageContext, VehicleBindingSession?) -> Void
    typealias OperationHandler = (VehiclePageContext, VehicleBindingOperationState) -> Void
    typealias ScanFailureHandler = (VehiclePageContext, VehicleBindingFailure) -> Void
    typealias SessionBlockedHandler = (VehiclePageContext, VehicleBindingSessionBlockReason) -> Void
    typealias PollingHandler = (VehiclePageContext, Bool) -> Void

    private let service: VehicleBindingServiceProtocol
    private let idempotencyKeyGenerator: () -> String
    private let now: () -> Date
    private let poller: BindingResultPoller
    /// 认证类失败 → 统一会话失效清理（清凭证 + 强制登录）；单测可注入替身
    private let sessionExpiryHandler: () -> Void

    private(set) var context: VehiclePageContext?
    private(set) var session: VehicleBindingSession?
    private(set) var operationState: VehicleBindingOperationState = .idle
    private(set) var idempotencyKey: String?
    private(set) var operationId: String?
    /// 最近一次可重试失败（用于在“结果确认中”时展示可读原因）
    private(set) var lastTransientFailure: VehicleBindingFailure?
    /// 最近一次关系结论（当前上下文）：仅供调试与测试断言，不持久化
    private(set) var lastKnownRelationship: VehicleRelationshipState = .loading
    /// 轮询是否已耗尽（耗尽后保持结果未知并保留手动刷新）
    private(set) var pollingExhausted = false
    /// 最近一次扫码用的 qrToken（仅内存；用于「重试」复用同一次 qrToken）
    private(set) var lastScanToken: String?

    private var generation = 0
    private var submitting = false
    private var pollingGeneration: Int?

    var onRelationship: RelationshipHandler?
    var onSession: SessionHandler?
    var onOperation: OperationHandler?
    var onScanFailure: ScanFailureHandler?
    /// 会话存在但不可提交时（过期 / 已绑定 / 已取消 / 已跳过 / ISSUED / 未知）
    var onSessionBlocked: SessionBlockedHandler?
    /// 轮询耗尽状态变化
    var onPolling: PollingHandler?

    init(service: VehicleBindingServiceProtocol,
         idempotencyKeyGenerator: @escaping () -> String = { UUID().uuidString },
         poller: BindingResultPoller = BindingResultPoller(),
         now: @escaping () -> Date = Date.init,
         sessionExpiryHandler: @escaping () -> Void = { AuthEnvironment.shared.handleSessionExpired() }) {
        self.service = service
        self.idempotencyKeyGenerator = idempotencyKeyGenerator
        self.poller = poller
        self.now = now
        self.sessionExpiryHandler = sessionExpiryHandler
    }

    // MARK: - 上下文

    /// 进入页面 / 账号或车辆切换：作废旧代次，清空旧操作上下文并重新查询关系。
    func start(context newContext: VehiclePageContext) {
        generation += 1
        let gen = generation
        stopPolling(.contextChanged)
        context = newContext
        session = nil
        idempotencyKey = nil
        operationId = nil
        lastTransientFailure = nil
        lastScanToken = nil
        submitting = false
        operationState = .idle
        pollingExhausted = false

        onSession?(newContext, nil)
        onOperation?(newContext, .idle)

        guard newContext.hasAccountAndVehicle else {
            emitRelationship(newContext, .unknown(.capabilityUnavailable))
            return
        }

        emitRelationship(newContext, .loading)
        service.queryRelationship(context: newContext) { [weak self] state in
            guard let self, self.isCurrent(gen, newContext) else { return }
            self.emitRelationship(newContext, state)
        }
    }

    /// 手动重试关系查询（未知/异常时）
    func refreshRelationship() {
        guard let context else { return }
        let gen = generation
        emitRelationship(context, .loading)
        service.queryRelationship(context: context) { [weak self] state in
            guard let self, self.isCurrent(gen, context) else { return }
            self.emitRelationship(context, state)
        }
    }

    /// 账号或车辆离开页面：作废所有未返回结果。
    func invalidate() {
        generation += 1
        stopPolling(.cancelled)
        context = nil
        session = nil
        idempotencyKey = nil
        operationId = nil
        lastTransientFailure = nil
        lastScanToken = nil
        submitting = false
        operationState = .idle
        pollingExhausted = false
    }

    /// 进入后台：停止自动恢复（回前台不自动重启，仅保留手动刷新）
    func pausePolling() {
        guard poller.isRunning else { return }
        stopPolling(.background)
    }

    // MARK: - 扫码

    /// 用户扫码后认领会话；仅返回最小待确认车辆信息，不代表已绑定。
    func beginScan(qrToken: String) {
        guard let context, !submitting else { return }
        let trimmed = qrToken.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            onScanFailure?(context, .invalidRequest)
            return
        }
        lastScanToken = trimmed
        let gen = generation
        service.scanActivationSession(qrToken: trimmed) { [weak self] result in
            guard let self, self.isCurrent(gen, context) else { return }
            switch result {
            case let .failure(failure):
                self.handleScanFailure(context, failure)
            case let .success(scan):
                self.handleScanResponse(context, scan)
            }
        }
    }

    /// 「重试」按钮：复用同一次 qrToken（服务端扫码认领幂等，不新建幂等键）
    @discardableResult
    func retryScan() -> Bool {
        guard let token = lastScanToken, !token.isEmpty else { return false }
        beginScan(qrToken: token)
        return true
    }

    /// 用户取消：遵守服务端会话状态，不删除已有关系。
    func cancelSession(completion: (() -> Void)? = nil) {
        stopPolling(.cancelled)
        guard let context, let session, !submitting else {
            completion?()
            return
        }
        let gen = generation
        service.cancelActivationSession(sessionId: session.sessionId) { [weak self] _ in
            guard let self, self.isCurrent(gen, context) else {
                completion?()
                return
            }
            self.clearSession(for: context)
            completion?()
        }
    }

    /// 关闭确认弹层时调用：成功态只清理本地会话，其余按取消处理。
    func dismissBindingSheet() {
        stopPolling(.cancelled)
        guard let context else { return }
        if operationState.isSucceeded {
            clearSession(for: context)
        } else {
            cancelSession()
        }
    }

    // MARK: - 确认绑定

    /// 当前会话是否允许提交（UI 与 `confirm()` 共用同一判据，避免无效提交）
    func canConfirmCurrentSession(now: Date? = nil) -> Bool {
        guard let session else { return false }
        return session.canConfirm(now: now ?? self.now())
    }

    /// 用户明确确认后才提交；同一次确认重试复用同一幂等键。
    func confirm() {
        submitConfirm(sessionGuard: true)
    }

    /// 提交确认（`sessionGuard` = false 仅用于「结果未知」的同键重放：
    /// 服务端为权威，本地状态不阻断已提交操作的恢复；不新建幂等键）
    private func submitConfirm(sessionGuard: Bool) {
        guard let context, let session, !submitting else { return }
        // D-011-2：仅 SCANNED + 未占用 + 未过期可提交；其他状态只提示不提交
        if sessionGuard, let reason = session.blockReason(now: now()) {
            onSessionBlocked?(context, reason)
            return
        }
        let key = idempotencyKey ?? idempotencyKeyGenerator()
        idempotencyKey = key
        submitting = true
        lastTransientFailure = nil
        pollingExhausted = false
        operationState = .submitting
        onOperation?(context, .submitting)

        let gen = generation
        service.confirmVehicleBinding(sessionId: session.sessionId, idempotencyKey: key) { [weak self] result in
            guard let self, self.isCurrent(gen, context) else { return }
            self.submitting = false
            switch result {
            case let .failure(failure):
                self.handleConfirmFailure(context, failure)
            case let .success(confirm):
                self.handleConfirmResponse(context, confirm)
            }
        }
    }

    /// 结果未知时的恢复入口（手动刷新 = 立即 tick 并重置退避序列）：
    /// - 已有 operationId：查询原操作权威结果；
    /// - 否则复用原幂等键重新确认（服务端幂等返回原结果）；
    /// - 既无 operationId 也无幂等键：停止轮询并落 `.failed(.unknown)`，**不得静默返回**
    ///   （裁决 R-16：不重发 confirm、不新建会话、不新建幂等键）。
    func refreshBindingResult() {
        guard let context, !submitting else { return }
        if let operationId {
            submitting = true
            pollingExhausted = false
            operationState = .resultUnknown(operationId: operationId)
            onOperation?(context, operationState)
            let gen = generation
            service.queryBindingOperation(operationId: operationId) { [weak self] result in
                guard let self, self.isCurrent(gen, context) else { return }
                self.submitting = false
                switch result {
                case let .failure(failure):
                    self.handleResultRecoveryFailure(context, failure, operationId: operationId, allowsLogin: true)
                    if case .resultUnknown = self.operationState {
                        // 手动刷新失败：重置退避序列后继续低频恢复（总时长上限不变）
                        self.restartPolling(for: context)
                    }
                case let .success(operation):
                    self.handleOperationResponse(context, operation)
                    if case .resultUnknown = self.operationState {
                        self.restartPolling(for: context)
                    }
                }
            }
            return
        }
        if session != nil, idempotencyKey != nil {
            restartPolling(for: context)
            confirm()
            return
        }
        // R-16：无键无 operationId，禁止重放；必须给出可读、可操作的失败
        failWithoutRecovery(context)
        stopPolling(.unavailable)
    }

    // MARK: - 扫码响应处理

    private func handleScanFailure(_ context: VehiclePageContext, _ failure: VehicleBindingFailure) {
        handleAuthenticationFailure(context, failure)
        onScanFailure?(context, failure)
    }

    private func handleScanResponse(_ context: VehiclePageContext, _ scan: ActivationScanResult) {
        let scannedVin = scan.vin?.trimmingCharacters(in: .whitespacesAndNewlines)
        // 只有两边都有 VIN 时才可判定不一致；缺失 VIN 由服务端按会话 VIN 校验资格
        if let currentVin = context.vin, !currentVin.isEmpty,
           let scannedVin, !scannedVin.isEmpty,
           currentVin.uppercased() != scannedVin.uppercased() {
            service.cancelActivationSession(sessionId: scan.sessionId) { _ in }
            onScanFailure?(context, .vehicleMismatch)
            return
        }

        let session = VehicleBindingSession(
            sessionId: scan.sessionId,
            vin: scan.vin,
            state: ActivationSessionState.parse(serverValue: scan.state),
            expiresAt: scan.expiresAt,
            claimed: scan.claimed
        )

        // BOUND：服务端已是绑定态 → 关闭弹层、按权威置 bound 并刷新关系
        if session.blockReason(now: now()) == .bound {
            self.session = nil
            self.idempotencyKey = nil
            self.operationId = nil
            self.lastTransientFailure = nil
            self.submitting = false
            self.operationState = .idle
            self.lastScanToken = nil
            stopPolling(.terminal)
            onSession?(context, nil)
            onOperation?(context, .idle)
            emitRelationship(context, .bound(relationId: nil))
            refreshRelationship()
            return
        }

        self.session = session
        self.idempotencyKey = nil
        self.operationId = nil
        self.lastTransientFailure = nil
        self.operationState = .idle
        self.pollingExhausted = false
        stopPolling(.cancelled)
        onSession?(context, session)
        onOperation?(context, .idle)

        // 过期 / CANCELLED / SKIPPED / ISSUED / 未知：不可提交，给出对应引导
        if let reason = session.blockReason(now: now()) {
            onSessionBlocked?(context, reason)
        }
    }

    // MARK: - 响应处理

    private func handleConfirmResponse(_ context: VehiclePageContext, _ confirm: ActivationConfirmResult) {
        operationId = confirm.operationId
        switch ActivationBindingStatus(serverValue: confirm.status) {
        case .succeeded:
            idempotencyKey = nil
            lastTransientFailure = nil
            pollingExhausted = false
            lastScanToken = nil
            operationState = .succeeded(relationId: confirm.relationId)
            stopPolling(.terminal)
            onOperation?(context, operationState)
            emitRelationship(context, .bound(relationId: confirm.relationId))
        case .failed:
            idempotencyKey = nil
            let failure = VehicleBindingFailure.from(reason: confirm.reason)
            handleAuthenticationFailure(context, failure)
            operationState = .failed(failure)
            stopPolling(.terminal)
            onOperation?(context, operationState)
        case .pending, .none:
            // PENDING / 未知状态都不得伪报成功或失败 → 结果未知 + 自动恢复
            operationState = .resultUnknown(operationId: confirm.operationId)
            onOperation?(context, operationState)
            startPollingIfNeeded(for: context)
        }
    }

    private func handleConfirmFailure(_ context: VehiclePageContext, _ failure: VehicleBindingFailure) {
        lastTransientFailure = failure
        if failure.isAuthenticationFailure {
            handleAuthenticationFailure(context, failure)
            idempotencyKey = nil
            operationState = .failed(failure)
            stopPolling(.authentication)
            onOperation?(context, operationState)
            return
        }
        if failure.isRetryableWithSameKey {
            // 未落终态：保留幂等键，等退避轮询或用户手动刷新，不新建绑定操作
            operationState = .resultUnknown(operationId: operationId)
            onOperation?(context, operationState)
            startPollingIfNeeded(for: context)
        } else {
            // 业务终态：下一次确认需要重新扫码生成新的幂等键
            idempotencyKey = nil
            operationState = .failed(failure)
            stopPolling(.terminal)
            onOperation?(context, operationState)
        }
    }

    private func handleOperationResponse(_ context: VehiclePageContext, _ operation: ActivationOperationResult) {
        operationId = operation.operationId
        switch ActivationBindingStatus(serverValue: operation.status) {
        case .succeeded:
            idempotencyKey = nil
            lastTransientFailure = nil
            pollingExhausted = false
            lastScanToken = nil
            operationState = .succeeded(relationId: operation.relationId)
            stopPolling(.terminal)
            onOperation?(context, operationState)
            emitRelationship(context, .bound(relationId: operation.relationId))
        case .failed:
            idempotencyKey = nil
            let failure = VehicleBindingFailure.from(reason: operation.reason)
            handleAuthenticationFailure(context, failure)
            operationState = .failed(failure)
            stopPolling(.terminal)
            onOperation?(context, operationState)
        case .pending, .none:
            operationState = .resultUnknown(operationId: operation.operationId)
            onOperation?(context, operationState)
        }
    }

    /// 恢复（轮询/手动刷新）失败：保留 operationId，认证类走登录引导，其余保持结果未知
    private func handleResultRecoveryFailure(_ context: VehiclePageContext,
                                            _ failure: VehicleBindingFailure,
                                            operationId: String?,
                                            allowsLogin: Bool) {
        lastTransientFailure = failure
        if failure.isAuthenticationFailure, allowsLogin {
            handleAuthenticationFailure(context, failure)
            operationState = .failed(failure)
            stopPolling(.authentication)
            onOperation?(context, operationState)
            return
        }
        operationState = .resultUnknown(operationId: operationId)
        onOperation?(context, operationState)
    }

    /// 认证类失败统一入口：只触发一次统一会话失效清理（不重试、不落网络语义）
    private func handleAuthenticationFailure(_ context: VehiclePageContext, _ failure: VehicleBindingFailure) {
        guard failure.isAuthenticationFailure else { return }
        SafeLog.log("绑车链路认证失效，触发统一会话失效清理:", failure.localizationKey)
        sessionExpiryHandler()
    }

    /// R-16：既无 operationId 也无幂等键 → 停止恢复、落可读失败，禁止静默与重放
    private func failWithoutRecovery(_ context: VehiclePageContext) {
        lastTransientFailure = .unknown
        operationState = .failed(.unknown)
        onOperation?(context, operationState)
    }

    // MARK: - 结果恢复轮询

    private func startPollingIfNeeded(for context: VehiclePageContext) {
        // 已达退避上限后不再自动重启（避免无穷重试）；手动刷新会先清除 exhausted
        guard poller.isRunning == false, pollingExhausted == false else { return }
        startPolling(for: context)
    }

    private func restartPolling(for context: VehiclePageContext) {
        if poller.isRunning {
            poller.stop(.restarted)
        }
        startPolling(for: context)
    }

    private func startPolling(for context: VehiclePageContext) {
        let gen = generation
        pollingGeneration = gen
        poller.onStop = { [weak self] reason in
            guard let self, self.pollingGeneration == gen, self.generation == gen, reason == .exhausted else { return }
            // 达到上限：保持结果未知，标记耗尽（保留手动刷新）
            self.pollingExhausted = true
            self.onPolling?(context, true)
        }
        poller.start { [weak self] _ in
            guard let self else { return .stop(.cancelled) }
            return self.pollTick(context: context, generation: gen)
        }
    }

    private func stopPolling(_ reason: BindingResultPoller.StopReason) {
        pollingGeneration = nil
        guard poller.isRunning else { return }
        poller.onStop = nil
        poller.stop(reason)
    }

    /// 单次恢复动作（顺序判定，不变式：**不新建绑定**）
    private func pollTick(context: VehiclePageContext, generation gen: Int) -> BindingResultPoller.TickDecision {
        guard isCurrent(gen, context) else { return .stop(.contextChanged) }
        if let operationId {
            let currentOperationId = operationId
            service.queryBindingOperation(operationId: currentOperationId) { [weak self] result in
                guard let self, self.isCurrent(gen, context) else { return }
                switch result {
                case let .failure(failure):
                    self.handleResultRecoveryFailure(context, failure,
                                                     operationId: currentOperationId,
                                                     allowsLogin: true)
                    if case .failed = self.operationState {
                        self.stopPolling(failure.isAuthenticationFailure ? .authentication : .terminal)
                    }
                case let .success(operation):
                    self.handleOperationResponse(context, operation)
                }
            }
            return .keepPolling
        }
        if session != nil, idempotencyKey != nil {
            // 同键重放：服务端幂等返回原结果（本地会话状态不阻断已提交操作的恢复）
            submitConfirm(sessionGuard: false)
            return .keepPolling
        }
        failWithoutRecovery(context)
        return .stop(.unavailable)
    }

    // MARK: - Helpers

    private func clearSession(for context: VehiclePageContext) {
        session = nil
        idempotencyKey = nil
        operationId = nil
        lastTransientFailure = nil
        lastScanToken = nil
        submitting = false
        operationState = .idle
        pollingExhausted = false
        onSession?(context, nil)
        onOperation?(context, .idle)
    }

    private func emitRelationship(_ context: VehiclePageContext, _ state: VehicleRelationshipState) {
        lastKnownRelationship = state
        onRelationship?(context, state)
    }

    /// 代次 + 上下文双重校验，丢弃账号/车辆切换后的迟到响应。
    private func isCurrent(_ gen: Int, _ expected: VehiclePageContext) -> Bool {
        generation == gen && context == expected
    }
}
