//
//  LoginGate.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-011 on 2026/11/23.
//

import Foundation
import Combine

// MARK: - 登录门禁

/// 登录态门禁（IOS-APP-DSN-CR-011 D-011-1）。
///
/// 设计约束：
/// - 只回答「现在有没有会话」，不预判 Token 是否即将过期（`TokenRefreshCoordinator` 已有单飞刷新）；
/// - 事实来源与 `AppGlobalState.isLogin` 同源（Keychain 会话），不引入第二套登录事实；
/// - 纯协议，便于用替身单测，不需要真实 Keychain。
protocol LoginGateProviding {
    /// 是否已登录（Keychain 会话是否存在）
    var isLoggedIn: Bool { get }
    /// 登录态变化（`true` = 登录成功，`false` = 取消/退出/失效）
    var loginState: AnyPublisher<Bool, Never> { get }
}

/// 生产实现：`AuthEnvironment.shared.sessionRepository.hasSession()` + `AppGlobalState.$isLogin`。
final class AppLoginGate: LoginGateProviding {

    static let shared = AppLoginGate()

    private init() {}

    var isLoggedIn: Bool {
        AuthEnvironment.shared.sessionRepository.hasSession()
    }

    var loginState: AnyPublisher<Bool, Never> {
        AppGlobalState.shared.$isLogin.eraseToAnyPublisher()
    }
}

// MARK: - qrToken 登录后续跑暂存

/// 已扫到但尚未提交服务的 qrToken 短期暂存（IOS-APP-DSN-CR-011 D-011-1）。
///
/// 安全与合规约束（D-011-5 §7.2）：
/// - 仅内存，**不落盘**、不进 `UserDefaults`、不进 Realm、不写任何日志；
/// - 单值覆盖：只保留最近一次扫码结果；
/// - 一个 token 只允许续跑一次（`take` 即清空）；
/// - 超过 TTL 或显式 `invalidate()` 后不可续跑，避免跨账号/跨上下文复用。
///
/// 线程：只允许主线程调用（登录态发布与路由都在主线程）。
final class PendingQRTokenStore {

    /// 默认短期有效期（秒）
    static let defaultTTL: TimeInterval = 120

    private let ttl: TimeInterval
    private let now: () -> Date
    private var token: String?
    private var storedAt: Date?

    init(ttl: TimeInterval = PendingQRTokenStore.defaultTTL,
         now: @escaping () -> Date = Date.init) {
        self.ttl = ttl
        self.now = now
    }

    /// 是否仍有未过期的待续跑 token（不暴露 token 原值）
    var hasPending: Bool {
        guard token != nil, let storedAt else { return false }
        return now().timeIntervalSince(storedAt) < ttl
    }

    /// 暂存扫码结果；空串直接拒绝（避免把无效扫码带入续跑）。
    func store(_ token: String, now: Date? = nil) {
        let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            self.token = nil
            self.storedAt = nil
            return
        }
        self.token = trimmed
        self.storedAt = now ?? self.now()
    }

    /// 取出并清空：未过期返回 token，过期/不存在返回 nil（一个 token 只续跑一次）。
    func take(now: Date? = nil) -> String? {
        guard let token, let storedAt else { return nil }
        let current = now ?? self.now()
        self.token = nil
        self.storedAt = nil
        guard current.timeIntervalSince(storedAt) < ttl else { return nil }
        return token
    }

    /// 取消登录 / 上下文切换 / 退出页面时丢弃，防止跨账号续跑。
    func invalidate() {
        token = nil
        storedAt = nil
    }
}
