//
//  MyRouter.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct MyRouter: RouterProtocol {
    typealias RouterScreenType = ScreenType
    typealias RouterAlertType = AlertScreen

    let subjects: Subjects
    let intent: MyIntentProtocol
}

// MARK: - Navigation Screens

extension MyRouter {
    enum ScreenType: RouterScreenProtocol {
        case login
        case my
        case message
        case setting
        case profile
        case myArticle
        case myPoints
        case myRights
        case myOrder
        case myInvite
        case testDriveReport
        case chargingPile

        var routeType: RouterScreenPresentationType {
            switch self {
            case .login:
                return .navigationLink
            case .my:
                return .fullScreenCover
            case .message:
                return .navigationLink
            case .setting:
                return .navigationLink
            case .profile:
                return .navigationLink
            case .myArticle:
                return .navigationLink
            case .myPoints:
                return .navigationLink
            case .myRights:
                return .navigationLink
            case .myOrder:
                return .navigationLink
            case .myInvite:
                return .navigationLink
            case .testDriveReport:
                return .navigationLink
            case .chargingPile:
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
        case .my:
            MyPage.build()
        case .message:
            MyMessageView.build()
                .navigationBarHidden(true)
        case .setting:
            SettingPage.build()
                .navigationBarHidden(true)
        case .profile:
            MySettingProfileView.build()
                .navigationBarHidden(true)
        case .myArticle:
            MyArticleView.build()
                .navigationBarHidden(true)
        case .myPoints:
            MyPointsView.build()
                .navigationBarHidden(true)
        case .myRights:
            MyRightsView.build()
                .navigationBarHidden(true)
        case .myOrder:
            MyOrderView.build()
                .navigationBarHidden(true)
        case .myInvite:
            MyInviteView.build()
                .navigationBarHidden(true)
        case .testDriveReport:
            TestDriveReportView.build()
                .navigationBarHidden(true)
        case .chargingPile:
            ChargingPileView.build()
                .navigationBarHidden(true)
        }
    }

    func onDismiss(screenType: RouterScreenType) {}
}

// MARK: - Alerts

extension MyRouter {
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
