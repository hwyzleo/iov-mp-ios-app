//
//  VehicleRouter.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

struct VehicleRouter: RouterProtocol {
    typealias RouterScreenType = ScreenType
    typealias RouterAlertType = AlertScreen

    let subjects: Subjects
    let intent: VehicleIntentProtocol
}

// MARK: - Navigation Screens

extension VehicleRouter {
    enum ScreenType: RouterScreenProtocol {
        case scan
        /// 扫码前登录门禁（IOS-APP-DSN-CR-011 D-011-1）
        case login

        var routeType: RouterScreenPresentationType {
            switch self {
            case .scan, .login:
                return .fullScreenCover
            }
        }
    }

    @ViewBuilder
    func makeScreen(type: RouterScreenType) -> some View {
        switch type {
        case .scan:
            VehicleBindingScanView(onResult: { code in
                intent.onScanResult(payload: code)
            })
        case .login:
            LoginPage.buildMobileLogin()
        }
    }

    func onDismiss(screenType: RouterScreenType) {}
}

// MARK: - Alerts

extension VehicleRouter {
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
