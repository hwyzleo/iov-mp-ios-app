//
//  TokenRefreshCoordinator.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-001 on 2026/11/9.
//

import Foundation

/// Token 刷新远程调用抽象
protocol TokenRefreshing {
    func refresh(refreshToken: String, completion: @escaping (Result<TspResponse<LoginResponse>, Error>) -> Void)
}

/// 生产实现：经由 TspApi 调用 CIAM 刷新接口
struct TspTokenRefresher: TokenRefreshing {
    func refresh(refreshToken: String, completion: @escaping (Result<TspResponse<LoginResponse>, Error>) -> Void) {
        TspApi.refreshToken(refreshToken: refreshToken, completion: completion)
    }
}

/// 单飞 Token 刷新协调器（IOS-APP-DSN-CR-001 RD-001-6 / §5.3）
/// 第一个请求创建刷新任务，后续请求等待同一任务，不追加独立刷新调用。
actor TokenRefreshCoordinator {

    private let repository: AuthSessionRepositoryProtocol
    private let refresher: TokenRefreshing
    private let onSessionExpired: () -> Void

    /// 当前进行中的刷新任务
    private var inFlightTask: Task<Result<AuthSession, AuthError>, Never>?

    init(repository: AuthSessionRepositoryProtocol,
         refresher: TokenRefreshing,
         onSessionExpired: @escaping () -> Void) {
        self.repository = repository
        self.refresher = refresher
        self.onSessionExpired = onSessionExpired
    }

    /// 刷新访问令牌；并发调用只会触发一次远程刷新。
    /// 非隔离入口：调用方无需 await，内部串行化到 actor 上排队。
    nonisolated func refresh(completion: @escaping (Result<AuthSession, AuthError>) -> Void) {
        Task {
            await self.enqueue(completion: completion)
        }
    }

    /// 是否正在刷新（仅用于诊断与测试）
    func isRefreshing() -> Bool {
        return inFlightTask != nil
    }

    // MARK: - Private

    private func enqueue(completion: @escaping (Result<AuthSession, AuthError>) -> Void) {
        let task: Task<Result<AuthSession, AuthError>, Never>

        if let existing = inFlightTask {
            task = existing
        } else {
            guard let session = repository.loadSession(), session.hasCredentials else {
                onSessionExpired()
                completion(.failure(.sessionExpired))
                return
            }
            let newTask = Task { await self.performRefresh(previous: session) }
            inFlightTask = newTask
            task = newTask
        }

        Task {
            let result = await task.value
            completion(result)
        }
    }

    private func performRefresh(previous: AuthSession) async -> Result<AuthSession, AuthError> {
        defer { inFlightTask = nil }

        let responseResult = await withCheckedContinuation { (continuation: CheckedContinuation<Result<TspResponse<LoginResponse>, Error>, Never>) in
            refresher.refresh(refreshToken: previous.refreshToken) { result in
                continuation.resume(returning: result)
            }
        }

        switch responseResult {
        case let .failure(error):
            // 网络或临时服务故障：保留现有会话，允许后续重试
            let mapped = AuthError.mapNetworkError(error)
            if mapped == .sessionExpired {
                onSessionExpired()
            }
            return .failure(mapped)
        case let .success(response):
            switch LoginResponseValidator.refreshedSession(from: response, previous: previous) {
            case let .failure(error):
                // 服务端明确判定会话无效：触发统一 sessionExpired 处理
                if error == .sessionExpired {
                    onSessionExpired()
                }
                return .failure(error)
            case let .success(newSession):
                do {
                    // 新会话保存成功后才唤醒等待请求
                    try repository.saveSession(newSession)
                    return .success(newSession)
                } catch {
                    return .failure(.credentialPersistenceFailed)
                }
            }
        }
    }
}
