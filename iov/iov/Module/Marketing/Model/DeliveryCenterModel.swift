//
//  VehicleModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class DeliveryCenterModel: ObservableObject, DeliveryCenterModelStateProtocol {
    @Published var contentState: MarketingTypes.Model.DeliveryCenterContentState = .loading
    let routerSubject = MarketingRouter.Subjects()
    @Published var deliveryCenterList: [Dealership] = []
}

// MARK: - Action Protocol

extension DeliveryCenterModel: DeliveryCenterModelActionProtocol {
    func displayLoading() {
        contentState = .content
    }
    func displayError(text: String) {
        contentState = .error(text: text)
    }
    func displayContent(deliveryCenterList: [Dealership]) {
        self.deliveryCenterList = deliveryCenterList
    }
}

// MARK: - Route

extension DeliveryCenterModel: DeliveryCenterModelRouterProtocol {
    func closeScreen() {
        routerSubject.close.send()
    }
}

extension MarketingTypes.Model {
    enum DeliveryCenterContentState {
        case loading
        case content
        case error(text: String)
    }
}
