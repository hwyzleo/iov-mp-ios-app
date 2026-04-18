//
//  LoginIntent.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

class LoginIntent {
    
    // MARK: - Model
    
    private weak var modelAction: LoginModelActionProtocol?
    private weak var modelRouter: LoginModelRouterProtocol?
    @AppStorage("userLogin") private var userLogin: Bool = false
    @AppStorage("userNickname") private var userNickname: String = ""
    @AppStorage("userAvatar") private var userAvatar: String = ""
    
    init(model: LoginModelActionProtocol & LoginModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
}

// MARK: - Public

extension LoginIntent: LoginIntentProtocol {
    
    func onTapExitLoginIcon() {
        modelRouter?.closeScreen()
    }
    func onTapSendVerifyCodeButton(countryRegionCode: String, mobile: String) {
        modelAction?.displayLoading()
        let replacedMobile = mobile.replacingOccurrences(of: " ", with: "")
        ServiceContainer.loginService.sendMobileVerifyCode(countryRegionCode: countryRegionCode, mobile: replacedMobile) { (result: Result<TspResponse<NoReply>, Error>) in
            switch result {
            case let .success(response):
                if response.isSuccess {
                    self.modelAction?.routeInputVerify(countryRegionCode: countryRegionCode, mobile: mobile)
                } else {
                    self.modelAction?.displayError(text: response.message ?? "请求异常")
                }
            case .failure(_):
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    func onTapBackMobileLoginIcon() {
        modelAction?.routeMobileLogin()
    }
    func onTapResendVerifyCodeText(countryRegionCode: String, mobile: String) {
        let replacedMobile = mobile.replacingOccurrences(of: " ", with: "")
        ServiceContainer.loginService.sendMobileVerifyCode(countryRegionCode: countryRegionCode, mobile: replacedMobile) { (result: Result<TspResponse<NoReply>, Error>) in
            switch result {
            case let .success(response):
                if !response.isSuccess {
                    self.modelAction?.displayError(text: response.message ?? "请求异常")
                }
            case .failure(_):
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    func onTapVerifyCodeLoginButton(countryRegionCode: String, mobile: String, verifyCode: String) {
        modelAction?.displayLoading()
        let replacedMobile = mobile.replacingOccurrences(of: " ", with: "")
        ServiceContainer.loginService.mobileVerifyCodeLogin(countryRegionCode: countryRegionCode, mobile: replacedMobile, verifyCode: verifyCode) { (result: Result<TspResponse<LoginResponse>, Error>) in
            switch result {
            case let .success(response):
                if response.isSuccess {
                    UserManager.login(response: response.data!)
                    AppGlobalState.shared.isLogin = true
                    TspApi.getAccountInfo() { (result: Result<TspResponse<AccountInfo>, Error>) in
                        switch result {
                        case let .success(accountResponse):
                            if accountResponse.isSuccess, let account = accountResponse.data {
                                let nickname = account.nickname ?? "未设置昵称"
                                let avatar = account.avatarUrl ?? ""
                                UserManager.updateNicknameAndAvatar(nickname: nickname, avatar: avatar)
                            }
                        case .failure(_):
                            break
                        }
                        DispatchQueue.main.async {
                            self.modelRouter?.closeScreen()
                        }
                    }
                } else {
                    self.modelAction?.displayError(text: response.message ?? "异常")
                }
            case .failure(_):
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    
}
