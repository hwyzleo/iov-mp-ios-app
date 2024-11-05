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
    @Published var hasOrder: Bool = false
    /// 当前选择车辆的类型
    @Published var currentVehicleType: VehicleType = .ACTIVATED
    @Published var orderState: OrderState = .WISHLIST
    @Published var saleModelImages: [String] = []
    @Published var totalPrice: Decimal = 0
    @Published var saleModelDesc: String = ""
}

// MARK: - Action Protocol

extension MarketingIndexModel: MarketingIndexModelActionProtocol {
    func displayError(text: String) {
        contentState = .error(text: text)
    }
    func displayLoading() {
        contentState = .loading
    }
    func displayNoOrder() {
        self.hasOrder = false
        contentState = .content
    }
    func displayWishlist(wishlist: Wishlist) {
        self.hasOrder = true
        self.currentVehicleType = .WISHLIST
        self.saleModelImages = wishlist.saleModelImages
        self.totalPrice = wishlist.totalPrice
        self.saleModelDesc = wishlist.saleModelDesc
        contentState = .content
    }
    func displayOrder(order: Order) {
        self.hasOrder = true
        self.currentVehicleType = .ORDER
        if let orderState = OrderState(rawValue: order.orderState) {
            self.orderState = orderState
        } else {
            self.orderState = .EARNEST_MONEY_UNPAID
        }
        self.saleModelImages = order.saleModelImages
        self.totalPrice = order.totalPrice
        self.saleModelDesc = order.saleModelDesc
        contentState = .content
    }
    func displayVehicle() {
        AppGlobalState.shared.needRefresh = true
        self.hasOrder = true
        self.currentVehicleType = .ACTIVATED
        self.orderState = .ACTIVATED
        contentState = .content
    }
}

// MARK: - Route

extension MarketingIndexModel: MarketingIndexModelRouterProtocol {
    func routeToModelConfig() {
        routerSubject.screen.send(.modelConfig)
    }
    func routeToOrderDetail() {
        routerSubject.screen.send(.orderDetail)
    }
    func routeToLogin() {
        routerSubject.screen.send(.login)
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
