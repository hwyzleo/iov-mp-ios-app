//
//  VehicleModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class VehicleOrderModel: ObservableObject, VehicleOrderModelStateProtocol {
    @Published var contentState: MarketingTypes.Model.VehicleOrderContentState = .content
    let routerSubject = MarketingRouter.Subjects()
}

// MARK: - Action Protocol

extension VehicleOrderModel: VehicleOrderModelActionProtocol {
    func saveOrder(orderNum: String) {
        VehicleManager.order(orderNum: orderNum)
        AppGlobalState.shared.needRefresh = true
        routerSubject.close.send()
    }
    func displayError(text: String) {
        
    }
    func displayLoading() {
        
    }
}

// MARK: - Route

extension VehicleOrderModel: VehicleOrderModelRouterProtocol {
    func closeScreen() {
        
    }
}

extension MarketingTypes.Model {
    enum VehicleOrderContentState {
        case loading
        case content
        case error(text: String)
    }
}
