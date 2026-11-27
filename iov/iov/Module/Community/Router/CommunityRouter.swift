//
//  CommunityRouter.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

struct CommunityRouter: RouterProtocol {
    typealias RouterScreenType = ScreenType
    typealias RouterAlertType = AlertScreen

    let subjects: Subjects
    let intent: CommunityIntentProtocol
}

// MARK: - Navigation Screens

extension CommunityRouter {
    enum ScreenType: RouterScreenProtocol {
        case article(articleId: String, revisionId: String)
        case topic(topicId: String, revisionId: String)
        case web(URL)
        case nativeOrderDetail(orderNo: String)

        var routeType: RouterScreenPresentationType {
            switch self {
            case .article, .topic, .web, .nativeOrderDetail:
                return .navigationLink
            }
        }
    }

    @ViewBuilder
    func makeScreen(type: RouterScreenType) -> some View {
        switch type {
        case let .article(articleId, revisionId):
            CommunityArticleView.build(articleId: articleId, revisionId: revisionId)
                .navigationBarHidden(true)
        case let .topic(topicId, revisionId):
            CommunityTopicView.build(topicId: topicId, revisionId: revisionId)
                .navigationBarHidden(true)
        case let .web(url):
            ExploreManagedWebView(url: url)
                .navigationBarHidden(true)
        case let .nativeOrderDetail(orderNo):
            VehicleOrderDetailPage.build(orderNo: orderNo)
                .navigationBarHidden(true)
        }
    }

    func onDismiss(screenType: RouterScreenType) {}
}

// MARK: - Alerts

extension CommunityRouter {
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
