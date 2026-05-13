//
//  EarnestMoneyPayRouter.swift
//  iov
//
//  Created on 2026/5/13.
//

import SwiftUI

struct EarnestMoneyPayRouter: RouterProtocol {
    typealias RouterScreenType = ScreenType
    typealias RouterAlertType = AlertScreen
    
    let subjects = MarketingRouter.Subjects()
    
    enum ScreenType: RouterScreenProtocol {
        case index
        
        var routeType: RouterScreenPresentationType {
            return .navigationLink
        }
    }
    
    @ViewBuilder
    func makeScreen(type: RouterScreenType) -> some View {
        switch type {
        case .index:
            EarnestMoneyPayPage.build()
                .navigationBarHidden(true)
        }
    }
    
    func onDismiss(screenType: RouterScreenType) {}
    
    enum AlertScreen: RouterAlertScreenProtocol {
        case defaultAlert(title: String, message: String?)
    }
    
    func makeAlert(type: RouterAlertType) -> Alert {
        switch type {
        case let .defaultAlert(title, message):
            return Alert(title: Text(title), message: message.map { Text($0) }, dismissButton: .cancel(Text("确定")))
        }
    }
}