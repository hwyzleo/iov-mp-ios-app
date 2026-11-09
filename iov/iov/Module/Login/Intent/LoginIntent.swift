//
//  LoginIntent.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

/// 登录后资料刷新（失败不回滚已保存会话）
protocol LoginProfileRefreshing {
    func refreshProfile(completion: @escaping (AccountInfo?) -> Void)
}

struct TspLoginProfileRefresher: LoginProfileRefreshing {
    func refreshProfile(completion: @escaping (AccountInfo?) -> Void) {
        TspApi.getAccountInfo { result in
            switch result {
            case let .success(response):
                if response.isSuccess, let account = response.data {
                    completion(account)
                } else {
                    SafeLog.log("账号资料刷新失败:", response.code)
                    completion(nil)
                }
            case let .failure(error):
                SafeLog.log("账号资料刷新请求失败:", AuthError.mapNetworkError(error).logCategory)
                completion(nil)
            }
        }
    }
}

class LoginIntent {

    // MARK: - Model

    private weak var modelAction: LoginModelActionProtocol?
    private weak var modelState: LoginModelStateProtocol?
    private weak var modelRouter: LoginModelRouterProtocol?

    // MARK: - Dependencies

    private let loginService: LoginServiceProtocol
    private let sessionRepository: AuthSessionRepositoryProtocol
    private let authState: LoginAuthPublishing
    private let profileRefresher: LoginProfileRefreshing
    /// 登录响应的资料落库（凭证与资料分离，失败不影响登录结果）
    private let profileUpdater: (LoginResponse) -> Void
    private let now: () -> Date

    init(model: LoginModelActionProtocol & LoginModelRouterProtocol & LoginModelStateProtocol,
         loginService: LoginServiceProtocol = ServiceContainer.loginService,
         sessionRepository: AuthSessionRepositoryProtocol = AuthEnvironment.shared.sessionRepository,
         authState: LoginAuthPublishing = AppGlobalState.shared,
         profileRefresher: LoginProfileRefreshing = TspLoginProfileRefresher(),
         profileUpdater: @escaping (LoginResponse) -> Void = { UserManager.updateProfile(response: $0) },
         now: @escaping () -> Date = Date.init) {
        self.modelAction = model
        self.modelState = model
        self.modelRouter = model
        self.loginService = loginService
        self.sessionRepository = sessionRepository
        self.authState = authState
        self.profileRefresher = profileRefresher
        self.profileUpdater = profileUpdater
        self.now = now
    }
}

// MARK: - Public

extension LoginIntent: LoginIntentProtocol {

    func onTapExitLoginIcon() {
        if authState.isForcedLogin {
            // 根条件渲染登录页不能依赖 presentationMode.dismiss()（IOS-APP-DSN-CR-001 §5.4）
            authState.handleLoginCancelled()
        } else {
            modelRouter?.closeScreen()
        }
    }

    func onChangeMobile(_ mobile: String) {
        modelAction?.updateMobile(MobileNumber.formatted(mobile))
    }

    func onToggleAgree() {
        let agree = modelState?.agree ?? false
        modelAction?.updateAgree(!agree)
    }

    func onTapSendVerifyCodeButton(countryRegionCode: String, mobile: String) {
        guard modelState?.operation == .idle else { return }
        guard MobileNumber.isValidMainlandMobile(mobile), modelState?.agree == true else {
            display(.invalidInput)
            return
        }

        let normalizedMobile = MobileNumber.normalized(mobile)
        let formattedMobile = MobileNumber.formatted(normalizedMobile)
        modelAction?.beginSendingCode()

        loginService.sendMobileVerifyCode(countryRegionCode: countryRegionCode, mobile: normalizedMobile) { [weak self] result in
            guard let self = self else { return }
            self.runOnMain {
                switch result {
                case let .success(response):
                    if response.isSuccess {
                        self.modelAction?.completeSendingCode(
                            countryRegionCode: countryRegionCode,
                            mobile: formattedMobile,
                            resendAvailableAt: self.now().addingTimeInterval(LoginModel.resendInterval)
                        )
                    } else {
                        self.modelAction?.completeOperation()
                        self.display(AuthError.mapServerCode(response.code))
                    }
                case let .failure(error):
                    self.modelAction?.completeOperation()
                    self.display(AuthError.mapNetworkError(error))
                }
            }
        }
    }

    func onTapBackMobileLoginIcon() {
        guard modelState?.operation == .idle else { return }
        modelAction?.routeMobileLogin()
    }

    func onTapResendVerifyCodeText(countryRegionCode: String, mobile: String) {
        guard modelState?.operation == .idle else { return }
        // 倒计时未结束不允许重发
        if let availableAt = modelState?.resendAvailableAt, now() < availableAt {
            return
        }
        guard MobileNumber.isValidMainlandMobile(mobile) else {
            display(.invalidInput)
            return
        }

        let normalizedMobile = MobileNumber.normalized(mobile)
        modelAction?.beginResendingCode()

        loginService.sendMobileVerifyCode(countryRegionCode: countryRegionCode, mobile: normalizedMobile) { [weak self] result in
            guard let self = self else { return }
            self.runOnMain {
                switch result {
                case let .success(response):
                    if response.isSuccess {
                        // 只有发送成功才重启完整倒计时
                        self.modelAction?.completeResendingCode(
                            resendAvailableAt: self.now().addingTimeInterval(LoginModel.resendInterval)
                        )
                    } else {
                        // 重发失败：保持当前步骤与原有倒计时
                        self.modelAction?.completeOperation()
                        self.display(AuthError.mapServerCode(response.code))
                    }
                case let .failure(error):
                    self.modelAction?.completeOperation()
                    self.display(AuthError.mapNetworkError(error))
                }
            }
        }
    }

    func onTapVerifyCodeLoginButton(countryRegionCode: String, mobile: String, verifyCode: String) {
        guard modelState?.operation == .idle else { return }
        let code = MobileNumber.normalized(verifyCode)
        guard code.count == 6 else {
            display(.invalidInput)
            return
        }

        modelAction?.beginLoggingIn()
        let normalizedMobile = MobileNumber.normalized(mobile)

        loginService.mobileVerifyCodeLogin(countryRegionCode: countryRegionCode, mobile: normalizedMobile, verifyCode: code) { [weak self] result in
            guard let self = self else { return }
            self.runOnMain {
                self.handleLoginResult(result)
            }
        }
    }
}

// MARK: - Private

private extension LoginIntent {

    func handleLoginResult(_ result: Result<TspResponse<LoginResponse>, Error>) {
        switch result {
        case let .failure(error):
            // 网络失败：停留在验证码步骤，允许重试
            modelAction?.completeOperation()
            display(AuthError.mapNetworkError(error))

        case let .success(response):
            switch LoginResponseValidator.session(from: response) {
            case let .failure(error):
                // 响应不合法或需要挑战：保持未登录，停留在可恢复页面
                modelAction?.completeOperation()
                display(error)

            case let .success(session):
                // 先成功保存凭证，才能发布登录状态
                do {
                    try sessionRepository.saveSession(session)
                } catch {
                    modelAction?.completeOperation()
                    display(.credentialPersistenceFailed)
                    return
                }

                if let data = response.data {
                    profileUpdater(data)
                }

                modelAction?.completeOperation()
                authState.handleLoginCompleted()
                modelRouter?.closeScreen()

                // 资料刷新独立进行，失败不回滚已保存会话
                profileRefresher.refreshProfile { account in
                    guard let account = account else { return }
                    UserManager.updateNicknameAndAvatar(
                        nickname: account.nickname ?? "未设置昵称",
                        avatar: account.avatarUrl ?? ""
                    )
                }
            }
        }
    }

    func display(_ error: AuthError) {
        SafeLog.log("登录流程失败:", error.logCategory)
        modelAction?.showError(message: error.localizedMessage)
    }

    func runOnMain(_ action: @escaping () -> Void) {
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.async(execute: action)
        }
    }
}
