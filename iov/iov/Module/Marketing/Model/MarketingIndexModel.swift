//
//  VehicleModel.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
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
    @Published var saleModelList: [SaleModelMp] = []
    @Published var selectedSaleModelIndex: Int = 0
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
    func displaySaleModelList(saleModelList: [SaleModelMp]) {
        self.saleModelList = saleModelList
        if !saleModelList.isEmpty {
            self.selectedSaleModelIndex = 0
        }
        contentState = .content
    }
    func selectSaleModel(index: Int) {
        guard index >= 0 && index < saleModelList.count else { return }
        self.selectedSaleModelIndex = index
    }
    func getCurrentSaleModel() -> SaleModelMp? {
        guard selectedSaleModelIndex >= 0 && selectedSaleModelIndex < saleModelList.count else { return nil }
        return saleModelList[selectedSaleModelIndex]
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
