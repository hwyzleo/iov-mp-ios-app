//
//  BindingResultPoller.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-011 on 2026/11/23.
//

import Foundation

// MARK: - 调度抽象（便于注入假时钟/假调度器）

/// 可取消的调度句柄
protocol PollerCancellable: AnyObject {
    func cancel()
}

/// 轮询调度器（生产实现走主队列；单测注入手动调度器，不依赖真实时间）
protocol PollerScheduling {
    func schedule(after delay: TimeInterval, _ action: @escaping () -> Void) -> PollerCancellable
}

final class DispatchPollerScheduler: PollerScheduling {

    private final class WorkItemCancellable: PollerCancellable {
        private let item: DispatchWorkItem
        init(_ item: DispatchWorkItem) { self.item = item }
        func cancel() { item.cancel() }
    }

    private let queue: DispatchQueue

    init(queue: DispatchQueue = .main) {
        self.queue = queue
    }

    func schedule(after delay: TimeInterval, _ action: @escaping () -> Void) -> PollerCancellable {
        let item = DispatchWorkItem(block: action)
        queue.asyncAfter(deadline: .now() + delay, execute: item)
        return WorkItemCancellable(item)
    }
}

// MARK: - 结果恢复轮询

/// 绑定结果恢复轮询（IOS-APP-DSN-CR-011 D-011-3）。
///
/// 不变式：
/// - 只做「结果未知」的恢复，**不新建绑定**（由调用方保证只按 operationId 或原幂等键重放）；
/// - 指数退避 + 次数上限 + 总时长上限，命中终态/认证失败/上下文变化即停；
/// - 达到上限不丢上下文：停在「结果未知」并允许手动刷新；
/// - 不使用 `DispatchQueue` 硬编码，调度器与时钟均可注入，便于单测断言退避序列。
final class BindingResultPoller {

    struct Config: Equatable {
        /// 退避序列（秒）：1 / 2 / 4 / 8 / 8
        var delays: [TimeInterval] = [1, 2, 4, 8, 8]
        /// 单轮最多请求次数
        var maxAttempts: Int = 5
        /// 单轮总时长上限（秒）
        var maxTotalDuration: TimeInterval = 30
    }

    /// 停止原因（终态停止与上限停止必须可区分）
    enum StopReason: String, Equatable {
        /// 命中业务终态（SUCCEEDED / FAILED）
        case terminal
        /// 认证类失败（需登录，不再自动恢复）
        case authentication
        /// 次数或总时长达到上限
        case exhausted
        /// 用户取消会话 / 关闭弹层 / 页面离开
        case cancelled
        /// 进入后台
        case background
        /// 既无 operationId 也无幂等键（禁止重放）
        case unavailable
        /// 上下文代次变化（账号/车辆切换）
        case contextChanged
        /// 手动刷新打断上一轮退避
        case restarted
    }

    /// 单次 tick 结论
    enum TickDecision: Equatable {
        case keepPolling
        case stop(StopReason)
    }

    /// tick 回调：入参为第几次请求（从 1 开始）
    typealias TickHandler = (_ attempt: Int) -> TickDecision

    private let config: Config
    private let scheduler: PollerScheduling
    private let now: () -> Date

    private var handler: TickHandler?
    private var pending: PollerCancellable?
    private var startedAt: Date?

    private(set) var attempt = 0
    private(set) var isRunning = false
    private(set) var lastStopReason: StopReason?
    /// 停止通知（在 `stop(_:)` 内同步回调；上下限触发 `exhausted` 也走这里）
    var onStop: ((StopReason) -> Void)?

    init(config: Config = Config(),
         scheduler: PollerScheduling = DispatchPollerScheduler(),
         now: @escaping () -> Date = Date.init) {
        self.config = config
        self.scheduler = scheduler
        self.now = now
    }

    deinit {
        pending?.cancel()
        pending = nil
    }

    var delays: [TimeInterval] { config.delays }
    var maxAttempts: Int { config.maxAttempts }
    var maxTotalDuration: TimeInterval { config.maxTotalDuration }

    /// 已排程但未触发的退避步数（等于下一次 tick 的 attempt）
    var scheduledAttempt: Int { attempt }

    /// 启动一轮轮询；已在运行时不重复启动。
    func start(_ handler: @escaping TickHandler) {
        guard !isRunning else { return }
        self.handler = handler
        isRunning = true
        attempt = 0
        startedAt = now()
        lastStopReason = nil
        scheduleNext()
    }

    /// 停止轮询（幂等）；`onStop` 只在从未停止时回调一次。
    func stop(_ reason: StopReason) {
        guard isRunning else { return }
        isRunning = false
        pending?.cancel()
        pending = nil
        handler = nil
        lastStopReason = reason
        onStop?(reason)
    }

    // MARK: - Private

    private func scheduleNext() {
        guard isRunning, let startedAt, let handler else { return }
        guard attempt < config.maxAttempts else {
            stop(.exhausted)
            return
        }
        let delay = config.delays[min(attempt, max(config.delays.count - 1, 0))]
        let elapsed = now().timeIntervalSince(startedAt)
        guard elapsed + delay <= config.maxTotalDuration else {
            stop(.exhausted)
            return
        }
        attempt += 1
        let currentAttempt = attempt
        pending = scheduler.schedule(after: delay) { [weak self] in
            self?.fire(attempt: currentAttempt, handler: handler)
        }
    }

    private func fire(attempt: Int, handler: @escaping TickHandler) {
        guard isRunning, self.handler != nil else { return }
        pending = nil
        switch handler(attempt) {
        case .keepPolling:
            scheduleNext()
        case let .stop(reason):
            stop(reason)
        }
    }
}
