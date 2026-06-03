//
//  VehicleModel.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

final class MarketingIndexModel: ObservableObject, MarketingIndexModelStateProtocol {
    @Published var contentState: MarketingTypes.Model.MarketingIndexContentState = .content
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
    func displayMyVehicle(vehicle: MyVehicleVo) {
        self.hasOrder = true
        switch vehicle.type {
        case "WISHLIST":
            self.currentVehicleType = .WISHLIST
            self.orderState = .WISHLIST
        case "ORDER":
            self.currentVehicleType = .ORDER
            if let orderState = OrderState(rawValue: vehicle.state) {
                self.orderState = orderState
            } else {
                self.orderState = .EARNEST_MONEY_UNPAID
            }
        case "ACTIVATED":
            self.currentVehicleType = .ACTIVATED
            self.orderState = .ACTIVATED
        default:
            self.currentVehicleType = .ORDER
            self.orderState = .EARNEST_MONEY_UNPAID
        }
        self.saleModelImages = vehicle.saleModelImages ?? []
        self.totalPrice = vehicle.totalPrice ?? 0
        self.saleModelDesc = vehicle.saleModelDesc ?? ""
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
    func routeToModelVariantSelection() {
    }
    func routeToModelConfig() {
    }
    func routeToOrderDetail() {
    }
    func routeToLogin() {
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
