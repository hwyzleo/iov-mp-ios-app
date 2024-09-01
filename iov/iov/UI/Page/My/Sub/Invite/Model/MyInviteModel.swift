//
//  MyInviteModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class MyInviteModel: ObservableObject, MyInviteModelStateProtocol {
    @Published var contentState: MyInviteTypes.Model.ContentState = .content
    let routerSubject = MyInviteRouter.Subjects()
}

// MARK: - Action Protocol

extension MyInviteModel: MyInviteModelActionProtocol {
    
    func displayLoading() {}
    func displayError(text: String) {
        
    }
}

// MARK: - Route

extension MyInviteModel: MyInviteModelRouterProtocol {
    func routeToLogin() {
        
    }
    
    func closeScreen() {
        
    }
    
}

extension MyInviteTypes.Model {
    enum ContentState {
        case loading
        case content
        case error(text: String)
    }
}
