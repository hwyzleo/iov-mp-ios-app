//
//  LoginModel.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

final class LoginModel: ObservableObject, LoginModelStateProtocol {
    @Published private(set) var step: LoginTypes.Model.LoginStep = .inputMobile
    @Published private(set) var operation: LoginTypes.Model.LoginOperation = .idle
    @Published private(set) var errorMessage: String?
    @Published private(set) var resendAvailableAt: Date?
    @Published private(set) var mobile: String = ""
    @Published private(set) var agree: Bool = false
    private(set) var countryRegionCode: String = "+86"
    let routerSubject = LoginRouter.Subjects()

    /// 重发倒计时（秒）
    static let resendInterval: TimeInterval = 60

    func resendRemainingSeconds(now: Date) -> Int {
        return LoginModel.resendRemainingSeconds(availableAt: resendAvailableAt, now: now)
    }

    /// 按可重发时刻计算剩余秒数（供视图时间轴直接使用）
    static func resendRemainingSeconds(availableAt: Date?, now: Date) -> Int {
        guard let availableAt = availableAt else { return 0 }
        return max(0, Int(ceil(availableAt.timeIntervalSince(now))))
    }
}

// MARK: - Action Protocol

extension LoginModel: LoginModelActionProtocol {
    func displayLoading() {
        // 请求处理中不再整页替换为 LoadingTip（IOS-APP-DSN-CR-001 §4.1）
    }

    func displayError(text: String) {
        errorMessage = text
    }

    func updateMobile(_ mobile: String) {
        self.mobile = mobile
    }

    func updateAgree(_ agree: Bool) {
        self.agree = agree
    }

    func beginSendingCode() {
        errorMessage = nil
        operation = .sendingCode
    }

    func beginResendingCode() {
        errorMessage = nil
        operation = .resendingCode
    }

    func beginLoggingIn() {
        errorMessage = nil
        operation = .loggingIn
    }

    func completeSendingCode(countryRegionCode: String, mobile: String, resendAvailableAt: Date) {
        self.countryRegionCode = countryRegionCode
        self.mobile = mobile
        self.agree = true
        self.resendAvailableAt = resendAvailableAt
        self.errorMessage = nil
        self.operation = .idle
        self.step = .inputVerifyCode
    }

    func completeResendingCode(resendAvailableAt: Date) {
        self.resendAvailableAt = resendAvailableAt
        self.errorMessage = nil
        self.operation = .idle
    }

    func completeOperation() {
        operation = .idle
    }

    func showError(message: String) {
        errorMessage = message
    }

    func routeMobileLogin() {
        errorMessage = nil
        operation = .idle
        step = .inputMobile
    }
}

// MARK: - Router Protocol

extension LoginModel: LoginModelRouterProtocol {
    func routeToLogin() {}
    func closeScreen() {
        routerSubject.close.send()
    }
    func routeToMy() {
        routerSubject.screen.send(.my)
    }
}

extension LoginTypes.Model {
    /// 登录步骤
    enum LoginStep: Equatable {
        case inputMobile
        case inputVerifyCode
    }

    /// 请求状态
    enum LoginOperation: Equatable {
        case idle
        case sendingCode
        case resendingCode
        case loggingIn
    }
}
