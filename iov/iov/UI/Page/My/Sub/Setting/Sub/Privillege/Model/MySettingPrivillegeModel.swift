//
//  MySettingPrivillegeModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class MySettingPrivillegeModel: ObservableObject, MySettingPrivillegeModelStateProtocol {
    @Published var contentState: MySettingPrivillegeTypes.Model.ContentState = .content
    let loadingText = "Loading"
    let routerSubject = MySettingPrivillegeRouter.Subjects()
}

// MARK: - Action Protocol

extension MySettingPrivillegeModel: MySettingPrivillegeModelActionProtocol {
    func displayLoading() {
        contentState = .loading
    }
    func displayError(text: String) {
        contentState = .error(text: text)
    }
}

// MARK: - Route Protocol

extension MySettingPrivillegeModel: MySettingPrivillegeModelRouterProtocol {
    func routeToLogin() {
        
    }
    func closeScreen() {
        routerSubject.close.send()
    }
}

extension MySettingPrivillegeTypes.Model {
    enum ContentState {
        case loading
        case content
        case error(text: String)
    }
}
