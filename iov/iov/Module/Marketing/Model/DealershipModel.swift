//
//  VehicleModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class DealershipModel: ObservableObject, DealershipModelStateProtocol {
    @Published var contentState: MarketingTypes.Model.DealershipContentState = .loading
    let routerSubject = MarketingRouter.Subjects()
    @Published var dealershipList: [Dealership] = []
}

// MARK: - Action Protocol

extension DealershipModel: DealershipModelActionProtocol {
    func displayLoading() {
        contentState = .content
    }
    func displayError(text: String) {
        contentState = .error(text: text)
    }
    func displayContent(dealershipList: [Dealership]) {
        self.dealershipList = dealershipList
    }
}

// MARK: - Route

extension DealershipModel: DealershipModelRouterProtocol {
    func closeScreen() {
        routerSubject.close.send()
    }
}

extension MarketingTypes.Model {
    enum DealershipContentState {
        case loading
        case content
        case error(text: String)
    }
}
