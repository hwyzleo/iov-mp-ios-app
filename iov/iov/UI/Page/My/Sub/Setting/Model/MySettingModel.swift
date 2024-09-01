//
//  MySettingModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class MySettingModel: ObservableObject, MySettingModelStateProtocol {
    @Published var contentState: MySettingTypes.Model.ContentState = .content
    let routerSubject = MySettingRouter.Subjects()
}

// MARK: - Action Protocol

extension MySettingModel: MySettingModelActionProtocol {
    func displayLoading() {}
    
    func update() {
        contentState = .content
    }
    func logout() {
        User.clear()
        routerSubject.close.send()
    }
    func displayError(text: String) {
        
    }
}

// MARK: - Route

extension MySettingModel: MySettingModelRouterProtocol {
    func closeScreen() {
        routerSubject.close.send()
    }
    func routeToMy() {
        routerSubject.screen.send(.my)
    }
    func routeToLogin() {
        routerSubject.screen.send(.login)
    }
    func routeToProfile() {
        routerSubject.screen.send(.profile)
    }
    func routeToAccountChange() {
        routerSubject.screen.send(.accountChange)
    }
    func routeToAccountSecurity() {
        routerSubject.screen.send(.accountSecurity)
    }
    func routeToAccountBinding() {
        routerSubject.screen.send(.accountBinding)
    }
    func routeToPrivillege() {
        routerSubject.screen.send(.privillege)
    }
    func routeToUserProtocol() {
        routerSubject.screen.send(.userProtocol)
    }
    func routeToCommunityConvention() {
        routerSubject.screen.send(.communityConvention)
    }
    func routeToPrivacyAgreement() {
        routerSubject.screen.send(.privacyAgreement)
    }
    func routeToSetting() {
        routerSubject.screen.send(.setting)
    }
}

extension MySettingTypes.Model {
    enum ContentState {
        case loading
        case content
        case error(text: String)
    }
}
