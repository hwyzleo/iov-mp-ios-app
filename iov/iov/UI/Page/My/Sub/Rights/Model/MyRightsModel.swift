//
//  MyRightsModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class MyRightsModel: ObservableObject, MyRightsModelStateProtocol {
    @Published var contentState: MyRightsTypes.Model.ContentState = .content
    let routerSubject = MyRightsRouter.Subjects()
}

// MARK: - Action Protocol

extension MyRightsModel: MyRightsModelActionProtocol {
    
    func displayLoading() {}
    func displayError(text: String) {
        
    }
}

// MARK: - Route

extension MyRightsModel: MyRightsModelRouterProtocol {
    func routeToLogin() {
        
    }
    
    func closeScreen() {
        
    }
    
}

extension MyRightsTypes.Model {
    enum ContentState {
        case loading
        case content
        case error(text: String)
    }
}
