//
//  MySettingAccountBindingModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class MySettingAccountBindingModel: ObservableObject, MySettingAccountBindingModelStateProtocol {
    @Published var contentState: MySettingAccountBindingTypes.Model.ContentState = .content
    let loadingText = "Loading"
    let routerSubject = MySettingAccountBindingRouter.Subjects()
}

// MARK: - Action Protocol

extension MySettingAccountBindingModel: MySettingAccountBindingModelActionProtocol {
    func displayLoading() {
        contentState = .loading
    }
    func displayError(text: String) {
        contentState = .error(text: text)
    }
}

// MARK: - Route Protocol

extension MySettingAccountBindingModel: MySettingAccountBindingModelRouterProtocol {
    func routeToLogin() {
        
    }
    func closeScreen() {
        routerSubject.close.send()
    }
}

extension MySettingAccountBindingTypes.Model {
    enum ContentState {
        case loading
        case content
        case error(text: String)
    }
}
