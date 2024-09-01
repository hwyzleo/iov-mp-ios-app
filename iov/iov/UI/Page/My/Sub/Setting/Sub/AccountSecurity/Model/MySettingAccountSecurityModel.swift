//
//  MySettingAccountSecurityModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class MySettingAccountSecurityModel: ObservableObject, MySettingAccountSecurityModelStateProtocol {
    @Published var contentState: MySettingAccountSecurityTypes.Model.ContentState = .content
    let loadingText = "Loading"
    let routerSubject = MySettingAccountSecurityRouter.Subjects()
}

// MARK: - Action Protocol

extension MySettingAccountSecurityModel: MySettingAccountSecurityModelActionProtocol {
    func displayLoading() {
        contentState = .loading
    }
    func displayError(text: String) {
        contentState = .error(text: text)
    }
}

// MARK: - Route Protocol

extension MySettingAccountSecurityModel: MySettingAccountSecurityModelRouterProtocol {
    func routeToLogin() {
        
    }
    func closeScreen() {
        routerSubject.close.send()
    }
}

extension MySettingAccountSecurityTypes.Model {
    enum ContentState {
        case loading
        case content
        case error(text: String)
    }
}
