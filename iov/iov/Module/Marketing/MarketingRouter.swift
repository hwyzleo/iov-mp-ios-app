//
//  VehicleRouter.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

/// 购车模块路由
struct MarketingRouter: RouterProtocol {
    typealias RouterScreenType = ScreenType
    typealias RouterAlertType = AlertScreen

    let subjects: Subjects
}

// MARK: - Navigation Screens

extension MarketingRouter {
    enum ScreenType: RouterScreenProtocol {
        case index
        case modelConfig
        case orderDetail
        case vehicle
        case login

        var routeType: RouterScreenPresentationType {
            switch self {
            case .index:
                return .navigationLink
            case .orderDetail:
                return .navigationLink
            case .modelConfig:
                return .navigationLink
            case .vehicle:
                return .navigationLink
            case .login:
                return .navigationLink
            }
        }
    }

    @ViewBuilder
    func makeScreen(type: RouterScreenType) -> some View {
        switch type {
        case .index:
            MarketingIndexPage.build()
                .ignoresSafeArea()
                .navigationBarHidden(true)
        case .orderDetail:
            VehicleOrderDetailPage.build()
                .navigationBarHidden(true)
        case .modelConfig:
            VehicleModelConfigPage.build()
                .navigationBarHidden(true)
        case .vehicle:
            VehiclePage.build()
                .navigationBarHidden(true)
        case .login:
            LoginPage.buildMobileLogin()
                .navigationBarHidden(true)
        }
    }

    func onDismiss(screenType: RouterScreenType) {}
}

// MARK: - Alerts

extension MarketingRouter {
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
