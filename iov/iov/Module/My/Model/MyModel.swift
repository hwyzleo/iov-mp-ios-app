//
//  MyModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class MyModel: ObservableObject, MyModelStateProtocol {
    @Published var contentState: MyTypes.Model.MyContentState = .notLogin
    let routerSubject = MyRouter.Subjects()
    var nickname: String = ""
    var avatar: String = ""
}

// MARK: - Action Protocol

extension MyModel: MyModelActionProtocol {
    func displayNotLogin() {
        contentState = .notLogin
    }
    
    func displayLogin() {
        contentState = .login
    }
    
    func displayLoading() {
        contentState = .loading
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
    enum MyContentState {
        case loading
        case notLogin
        case login
        case error(text: String)
    }
}
