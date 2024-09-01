//
//  MyModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class MyModel: ObservableObject, MyModelStateProtocol {
    @Published var contentState: MyTypes.Model.ContentState = .content
    let routerSubject = MyRouter.Subjects()
    var nickname: String = ""
    var avatar: String = ""
}

// MARK: - Action Protocol

extension MyModel: MyModelActionProtocol {
    func displayLoading() {
        contentState = .loading
    }
    func logout() {
        User.clear()
        routerSubject.screen.send(.my)
    }
    func displayError(text: String) {
        contentState = .error(text: text)
    }
}

// MARK: - Route

extension MyModel: MyModelRouterProtocol {
    func closeScreen() {}
    func routeToLogin() {
        routerSubject.screen.send(.login)
    }
    func routeToMessage() {
        routerSubject.screen.send(.message)
    }
    func routeToSetting() {
        routerSubject.screen.send(.setting)
    }
    func routeToProfile() {
        routerSubject.screen.send(.profile)
    }
    func routeToMyArticle() {
        routerSubject.screen.send(.myArticle)
    }
    func routeToMyPoints() {
        routerSubject.screen.send(.myPoints)
    }
    func routeToMyRights() {
        routerSubject.screen.send(.myRights)
    }
    func routeToMyOrder() {
        routerSubject.screen.send(.myOrder)
    }
    func routeToMyInvite() {
        routerSubject.screen.send(.myInvite)
    }
    func routeToTestDriveReport() {
        routerSubject.screen.send(.testDriveReport)
    }
    func routeToChargingPile() {
        routerSubject.screen.send(.chargingPile)
    }
}

extension MyTypes.Model {
    enum ContentState {
        case loading
        case content
        case error(text: String)
    }
}
