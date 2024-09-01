//
//  LoginModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class LoginModel: ObservableObject, LoginModelStateProtocol {
    @Published var contentState: LoginTypes.Model.ContentState = .inputMobile
    var countryRegionCode: String = "+86"
    var mobile: String = ""
    var agree: Bool = false
    let routerSubject = LoginRouter.Subjects()
}

// MARK: - Action Protocol

extension LoginModel: LoginModelActionProtocol {
    func displayLoading() {
        contentState = .loading
    }
    func routeInputVerify(countryRegionCode: String, mobile: String) {
        self.countryRegionCode = countryRegionCode
        self.mobile = mobile
        self.agree = true
        contentState = .inputVerifyCode
    }
    func routeMobileLogin() {
        contentState = .inputMobile
    }
    func displayError(text: String) {
        contentState = .error(text: text)
        
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
    enum ContentState {
        case loading
        case inputMobile
        case inputVerifyCode
        case error(text: String)
    }
}
