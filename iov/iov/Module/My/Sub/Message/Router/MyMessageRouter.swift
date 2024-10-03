//
//  MyMessageRouter.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct MyMessageRouter: RouterProtocol {
    typealias RouterScreenType = ScreenType
    typealias RouterAlertType = AlertScreen

    let subjects: Subjects
    let intent: MyMessageIntentProtocol
}

// MARK: - Navigation Screens

extension MyMessageRouter {
    enum ScreenType: RouterScreenProtocol {
        case login

        var routeType: RouterScreenPresentationType {
            switch self {
            case .login:
                return .navigationLink
            }
        }
    }

    @ViewBuilder
    func makeScreen(type: RouterScreenType) -> some View {
        switch type {
        case .login:
            LoginPage.buildMobileLogin()
                .navigationBarHidden(true)
        }
    }

    func onDismiss(screenType: RouterScreenType) {}
}

// MARK: - Alerts

extension MyMessageRouter {
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
