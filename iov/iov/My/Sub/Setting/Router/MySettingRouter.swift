//
//  MySettingRouter.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct MySettingRouter: RouterProtocol {
    typealias RouterScreenType = ScreenType
    typealias RouterAlertType = AlertScreen

    let subjects: Subjects
    let intent: MySettingIntentProtocol
}

// MARK: - Navigation Screens

extension MySettingRouter {
    enum ScreenType: RouterScreenProtocol {
        case login
        case my
        case profile
        case accountChange
        case accountSecurity
        case accountBinding
        case privillege
        case userProtocol
        case communityConvention
        case privacyAgreement
        case setting

        var routeType: RouterScreenPresentationType {
            switch self {
            case .login:
                return .navigationLink
            case .my:
                return .navigationLink
            case .profile:
                return .navigationLink
            case .accountChange:
                return .navigationLink
            case .accountSecurity:
                return .navigationLink
            case .accountBinding:
                return .navigationLink
            case .privillege:
                return .navigationLink
            case .userProtocol:
                return .navigationLink
            case .communityConvention:
                return .navigationLink
            case .privacyAgreement:
                return .navigationLink
            case .setting:
                return .navigationLink
            }
        }
    }

    @ViewBuilder
    func makeScreen(type: RouterScreenType) -> some View {
        switch type {
        case .login:
            LoginView.buildMobileLogin()
                .navigationBarHidden(true)
        case .my:
            MyView.build()
                .navigationBarHidden(true)
        case .profile:
            MySettingProfileView.build()
                .navigationBarHidden(true)
        case .accountChange:
            MySettingAccountChangeView.build()
                .navigationBarHidden(true)
        case .accountSecurity:
            MySettingAccountSecurityView.build()
                .navigationBarHidden(true)
        case .accountBinding:
            MySettingAccountBindingView.build()
                .navigationBarHidden(true)
        case .privillege:
            MySettingPrivillegeView.build()
                .navigationBarHidden(true)
        case .userProtocol:
            MySettingUserProtocolView.build()
                .navigationBarHidden(true)
        case .communityConvention:
            MySettingCommunityConventionView.build()
                .navigationBarHidden(true)
        case .privacyAgreement:
            MySettingPrivacyAgreementView.build()
                .navigationBarHidden(true)
        case .setting:
            MySettingView.build()
                .navigationBarHidden(true)
        }
    }

    func onDismiss(screenType: RouterScreenType) {}
}

// MARK: - Alerts

extension MySettingRouter {
    enum AlertScreen: RouterAlertScreenProtocol {
        case defaultAlert(title: String, message: String?)
    }

    func makeAlert(type: RouterAlertType) -> Alert {
        switch type {
        case let .defaultAlert(title, message):
            return Alert(title: Text(title),
                         message: message.map { Text($0) },
                         dismissButton: .cancel(Text("Cancel")))
        }
    }
}
