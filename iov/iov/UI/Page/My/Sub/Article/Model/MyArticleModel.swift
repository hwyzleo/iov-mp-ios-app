//
//  MyArticleModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class MyArticleModel: ObservableObject, MyArticleModelStateProtocol {
    @Published var contentState: MyArticleTypes.Model.ContentState = .content
    let routerSubject = MyArticleRouter.Subjects()
}

// MARK: - Action Protocol

extension MyArticleModel: MyArticleModelActionProtocol {
    func displayLoading() {}
    func displayError(text: String) {
        
    }
}

// MARK: - Route

extension MyArticleModel: MyArticleModelRouterProtocol {
    func routeToLogin() {
        
    }
    
    func closeScreen() {
        routerSubject.close.send()
    }
    
}

extension MyArticleTypes.Model {
    enum ContentState {
        case loading
        case content
        case error(text: String)
    }
}
