//
//  MySettingAccountChangeModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class MySettingAccountChangeModel: ObservableObject, MySettingAccountChangeModelStateProtocol {
    @Published var contentState: MySettingAccountChangeTypes.Model.ContentState = .content
    let loadingText = "Loading"
    let routerSubject = MySettingAccountChangeRouter.Subjects()
}

// MARK: - Action Protocol

extension MySettingAccountChangeModel: MySettingAccountChangeModelActionProtocol {
    func displayLoading() {
        contentState = .loading
    }
    func displayError(text: String) {
        contentState = .error(text: text)
    }
}

// MARK: - Route Protocol

extension MySettingAccountChangeModel: MySettingAccountChangeModelRouterProtocol {
    func routeToLogin() {
        
    }
    func closeScreen() {
        routerSubject.close.send()
    }
}

extension MySettingAccountChangeTypes.Model {
    enum ContentState {
        case loading
        case content
        case error(text: String)
    }
}
