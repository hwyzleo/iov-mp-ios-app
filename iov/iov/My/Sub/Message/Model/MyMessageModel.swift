//
//  MyMessageModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class MyMessageModel: ObservableObject, MyMessageModelStateProtocol {
    @Published var contentState: MyMessageTypes.Model.ContentState = .content
    let routerSubject = MyMessageRouter.Subjects()
}

// MARK: - Action Protocol

extension MyMessageModel: MyMessageModelActionProtocol {
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

extension MyMessageModel: MyMessageModelRouterProtocol {
    func closeScreen() {
        routerSubject.close.send()
    }
}

extension MyMessageTypes.Model {
    enum ContentState {
        case loading
        case content
        case error(text: String)
    }
}
