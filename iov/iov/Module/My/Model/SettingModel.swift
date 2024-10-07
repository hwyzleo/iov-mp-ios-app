//
//  SettingModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class SettingModel: ObservableObject, SettingModelStateProtocol {
    @Published var contentState: MyTypes.Model.SettingContentState = .content
    let routerSubject = MyRouter.Subjects()
}

// MARK: - Action Protocol

extension SettingModel: SettingModelActionProtocol {
    func displayLoading() {}
    
    func update() {
        contentState = .content
    }
    func logout() {
        routerSubject.close.send()
    }
    func displayError(text: String) {
        
    }
}

// MARK: - Route

extension SettingModel: SettingModelRouterProtocol {
    func closeScreen() {
        routerSubject.close.send()
    }
    func routeToMy() {
        routerSubject.screen.send(.my)
    }
    func routeToLogin() {
        routerSubject.screen.send(.login)
    }
//    func routeToProfile() {
//        routerSubject.screen.send(.profile)
//    }
//    func routeToAccountChange() {
//        routerSubject.screen.send(.accountChange)
//    }
//    func routeToAccountSecurity() {
//        routerSubject.screen.send(.accountSecurity)
//    }
//    func routeToAccountBinding() {
//        routerSubject.screen.send(.accountBinding)
//    }
//    func routeToPrivillege() {
//        routerSubject.screen.send(.privillege)
//    }
//    func routeToUserProtocol() {
//        routerSubject.screen.send(.userProtocol)
//    }
//    func routeToCommunityConvention() {
//        routerSubject.screen.send(.communityConvention)
//    }
//    func routeToPrivacyAgreement() {
//        routerSubject.screen.send(.privacyAgreement)
//    }
    func routeToSetting() {
        routerSubject.screen.send(.setting)
    }
}

extension MyTypes.Model {
    enum SettingContentState {
        case loading
        case content
        case error(text: String)
    }
}
