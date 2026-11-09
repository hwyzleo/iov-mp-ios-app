//
//  AuthEnvironment.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-001 on 2026/11/9.
//

import Foundation

/// 认证装配根：会话仓储、刷新协调器与统一认证事件
final class AuthEnvironment {

    static let shared = AuthEnvironment()

    let sessionRepository: AuthSessionRepositoryProtocol
    let refreshCoordinator: TokenRefreshCoordinator

    private init() {
        let repository = AuthSessionRepository(
            credentialStore: KeychainCredentialStore(),
            legacyStore: RealmLegacyCredentialStore()
        )
        self.sessionRepository = repository
        self.refreshCoordinator = TokenRefreshCoordinator(
            repository: repository,
            refresher: TspTokenRefresher(),
            onSessionExpired: {
                AppGlobalState.shared.handleSessionExpired()
            }
        )
    }

    /// 统一会话失效处理：清理凭证并发布未登录状态
    func handleSessionExpired() {
        sessionRepository.clearSession()
        AppGlobalState.shared.handleSessionExpired()
    }

    /// 统一退出登录处理
    func handleLogoutCompleted() {
        sessionRepository.clearSession()
        UserManager.logout()
        AppGlobalState.shared.handleLogoutCompleted()
    }
}
