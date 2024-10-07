//
//  LoginIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
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
        TspApi.sendMobileVerifyCode(countryRegionCode: countryRegionCode, mobile: replacedMobile) { (result: Result<TspResponse<NoReply>, Error>) in
            switch result {
            case .success(_):
                self.modelAction?.routeInputVerify(countryRegionCode: countryRegionCode, mobile: mobile)
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
        TspApi.sendMobileVerifyCode(countryRegionCode: countryRegionCode, mobile: replacedMobile) { (result: Result<TspResponse<NoReply>, Error>) in
            switch result {
            case .success(_):
                debugPrint("resend success")
            case .failure(_):
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    func onTapVerifyCodeLoginButton(countryRegionCode: String, mobile: String, verifyCode: String) {
        modelAction?.displayLoading()
        let replacedMobile = mobile.replacingOccurrences(of: " ", with: "")
        TspApi.mobileVerifyCodeLogin(countryRegionCode: countryRegionCode, mobile: replacedMobile, verifyCode: verifyCode) { (result: Result<TspResponse<LoginResponse>, Error>) in
            switch result {
            case let .success(response):
                if response.code == 0 {
                    UserManager.login(response: response.data!)
                    self.modelRouter?.closeScreen()
                } else if response.code > 0 {
                    self.modelAction?.displayError(text: response.message ?? "异常")
                }
            case .failure(_):
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    
}
