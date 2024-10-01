//
//  MyPointsModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class MyPointsModel: ObservableObject, MyPointsModelStateProtocol {
    @Published var contentState: MyPointsTypes.Model.ContentState = .content
    let routerSubject = MyPointsRouter.Subjects()
}

// MARK: - Action Protocol

extension MyPointsModel: MyPointsModelActionProtocol {
    
    func displayLoading() {}
    func displayError(text: String) {
        
    }
}

// MARK: - Route

extension MyPointsModel: MyPointsModelRouterProtocol {
    func routeToLogin() {
        
    }
    
    func closeScreen() {
        
    }
    
}

extension MyPointsTypes.Model {
    enum ContentState {
        case loading
        case content
        case error(text: String)
    }
}
