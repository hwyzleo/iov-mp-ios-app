//
//  MySettingIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

class MySettingIntent: MviIntentProtocol {
    private weak var modelAction: MySettingModelActionProtocol?
    private weak var modelRouter: MySettingModelRouterProtocol?
    
    init(model: MySettingModelActionProtocol & MySettingModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    func viewOnAppear() {}
}

extension MySettingIntent: MySettingIntentProtocol {
    func onTapLogin() {
        modelRouter?.routeToLogin()
    }
    func onTapBack() {
        modelRouter?.closeScreen()
    }
    func onTapProfile() {
        modelRouter?.routeToProfile()
    }
    func onTapAccountChange() {
        modelRouter?.routeToAccountChange()
    }
    func onTapAccountSecurity() {
        modelRouter?.routeToAccountSecurity()
    }
    func onTapAccountBinding() {
        modelRouter?.routeToAccountBinding()
    }
    func onTapPrivillege() {
        modelRouter?.routeToPrivillege()
    }
    func onTapUserProtocol() {
        modelRouter?.routeToUserProtocol()
    }
    func onTapCommunityConvention() {
        modelRouter?.routeToCommunityConvention()
    }
    func onTapPrivacyAgreement() {
        modelRouter?.routeToPrivacyAgreement()
    }
    func onTapLogout() {
        modelAction?.logout()
    }
}
