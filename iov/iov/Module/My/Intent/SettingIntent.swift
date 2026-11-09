//
//  SettingIntent.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

class SettingIntent: MviIntentProtocol {
    private weak var modelAction: SettingModelActionProtocol?
    private weak var modelRouter: SettingModelRouterProtocol?
    
    init(model: SettingModelActionProtocol & SettingModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    func viewOnAppear() {}
}

extension SettingIntent: SettingIntentProtocol {
    func onTapLogin() {
        modelRouter?.routeToLogin()
    }
    func onTapBack() {
        modelRouter?.closeScreen()
    }
    func onTapProfile() {
        modelRouter?.routeToProfile()
    }
    func onTapPermissionManagement() {
        modelRouter?.routeToPermissionManagement()
    }
    func onTapClearCache() {}
    func onTapAboutUs() {
        modelRouter?.routeToAboutUs()
    }
    func onTapLanguageSetting() {
        modelRouter?.routeToLanguageSetting()
    }
//    func onTapAccountChange() {
//        modelRouter?.routeToAccountChange()
//    }
//    func onTapAccountSecurity() {
//        modelRouter?.routeToAccountSecurity()
//    }
//    func onTapAccountBinding() {
//        modelRouter?.routeToAccountBinding()
//    }
//    func onTapPrivillege() {
//        modelRouter?.routeToPrivillege()
//    }
//    func onTapUserProtocol() {
//        modelRouter?.routeToUserProtocol()
//    }
//    func onTapCommunityConvention() {
//        modelRouter?.routeToCommunityConvention()
//    }
//    func onTapPrivacyAgreement() {
//        modelRouter?.routeToPrivacyAgreement()
//    }
    func onTapLogout() {
        TspApi.logout { result in
            switch result {
            case .success(let response):
                if !response.isSuccess {
                    SafeLog.log("退出登录失败:", response.code)
                }
            case .failure(let error):
                SafeLog.log("退出登录请求失败:", AuthError.mapNetworkError(error).logCategory)
            }
            // 无论服务端结果如何，本地会话都必须清理并发布未登录状态
            DispatchQueue.main.async {
                AuthEnvironment.shared.handleLogoutCompleted()
                self.modelAction?.logout()
            }
        }
    }
}
