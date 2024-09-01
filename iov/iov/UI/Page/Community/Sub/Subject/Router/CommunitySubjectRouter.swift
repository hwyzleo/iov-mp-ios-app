//
//  CommunitySubjectRouter.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct CommunitySubjectRouter: RouterProtocol {
    typealias RouterScreenType = ScreenType
    typealias RouterAlertType = AlertScreen

    let subjects: Subjects
    let intent: CommunitySubjectIntentProtocol
}

// MARK: - Navigation Screens

extension CommunitySubjectRouter {
    enum ScreenType: RouterScreenProtocol {
        case article
        case subject
        case topic

        var routeType: RouterScreenPresentationType {
            switch self {
            case .article:
                return .navigationLink
            case .subject:
                return .navigationLink
            case .topic:
                return .navigationLink
            }
        }
    }

    @ViewBuilder
    func makeScreen(type: RouterScreenType) -> some View {
        switch type {
        case .article:
            CommunityArticleView.build()
                .navigationBarHidden(true)
        case .subject:
            CommunitySubjectView.build()
                .navigationBarHidden(true)
        case .topic:
            CommunityTopicView.build()
                .navigationBarHidden(true)
        }
    }

    func onDismiss(screenType: RouterScreenType) {}
}

// MARK: - Alerts

extension CommunitySubjectRouter {
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
