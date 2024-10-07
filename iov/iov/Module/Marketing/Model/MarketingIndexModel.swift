//
//  VehicleModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class MarketingIndexModel: ObservableObject, MarketingIndexModelStateProtocol {
    @Published var contentState: MarketingTypes.Model.MarketingIndexContentState = .content
    let routerSubject = MarketingRouter.Subjects()
}

// MARK: - Action Protocol

extension MarketingIndexModel: MarketingIndexModelActionProtocol {
    func displayError(text: String) {
        
    }
    func displayLoading() {
        contentState = .loading
    }
}

// MARK: - Route

extension MarketingIndexModel: MarketingIndexModelRouterProtocol {
    func routeToLogin() {
        routerSubject.screen.send(.login)
    }
    func routeToOrder() {
        routerSubject.screen.send(.order)
    }
    func closeScreen() {
        
    }
}

extension MarketingTypes.Model {
    enum MarketingIndexContentState {
        case loading
        case content
        case error(text: String)
    }
}
