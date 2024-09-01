//
//  MySettingProfileRouter.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct MySettingProfileRouter: RouterProtocol {
    typealias RouterScreenType = ScreenType
    typealias RouterAlertType = AlertScreen

    let subjects: Subjects
    let intent: MySettingProfileIntentProtocol
}

// MARK: - Navigation Screens

extension MySettingProfileRouter {
    enum ScreenType: RouterScreenProtocol {
        case login

        var routeType: RouterScreenPresentationType {
            switch self {
            case .login:
                return .fullScreenCover
            }
        }
    }

    @ViewBuilder
    func makeScreen(type: RouterScreenType) -> some View {
        switch type {
        case .login:
            LoginView.buildMobileLogin()
        }
    }

    func onDismiss(screenType: RouterScreenType) {}
}

// MARK: - Alerts

extension MySettingProfileRouter {
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
