//
//  VehicleModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class VehicleModelConfigModel: ObservableObject, VehicleModelConfigModelStateProtocol {
    @Published var contentState: MarketingTypes.Model.VehicleModelConfigContentState = .loading
    let routerSubject = MarketingRouter.Subjects()
    var saleCode: String = ""
    var models: [SaleModelConfig] = []
    @Published var selectModel: String = ""
    var selectModelName: String = ""
    @Published var selectModelPrice: Decimal = 0
    var spareTires: [SaleModelConfig] = []
    @Published var selectSpareTire: String = ""
    @Published var selectSpareTirePrice: Decimal = 0
    var exteriors: [SaleModelConfig] = []
    @Published var selectExterior: String = ""
    @Published var selectExteriorPrice: Decimal = 0
    var wheels: [SaleModelConfig] = []
    @Published var selectWheel: String = ""
    @Published var selectWheelPrice: Decimal = 0
    var interiors: [SaleModelConfig] = []
    @Published var selectInterior: String = ""
    @Published var selectInteriorPrice: Decimal = 0
    var adases: [SaleModelConfig] = []
    @Published var selectAdas: String = ""
    @Published var selectAdasPrice: Decimal = 0
    @Published var totalPrice: Decimal = 0
}

// MARK: - Action Protocol

extension VehicleModelConfigModel: VehicleModelConfigModelActionProtocol {
    func updateSaleModel(saleCode: String, saleModels: [SaleModelConfig]) {
        self.saleCode = saleCode
        models.removeAll()
        spareTires.removeAll()
        exteriors.removeAll()
        wheels.removeAll()
        interiors.removeAll()
        adases.removeAll()
        for saleModel in saleModels {
            switch saleModel.type {
            case "MODEL":
                models.append(saleModel)
            case "SPARE_TIRE":
                spareTires.append(saleModel)
            case "EXTERIOR":
                exteriors.append(saleModel)
            case "WHEEL":
                wheels.append(saleModel)
            case "INTERIOR":
                interiors.append(saleModel)
            case "ADAS":
                adases.append(saleModel)
            default:
                break
            }
        }
        contentState = .content
    }
    func selectModel(code: String, name: String, price: Decimal) {
        selectModel = code
        selectModelName = name
        selectModelPrice = price
        totalPrice = selectModelPrice + selectSpareTirePrice + selectExteriorPrice + selectWheelPrice + selectInteriorPrice
    }
    func selectSpareTire(code: String, price: Decimal) {
        selectSpareTire = code
        selectSpareTirePrice = price
        totalPrice = selectModelPrice + selectSpareTirePrice + selectExteriorPrice + selectWheelPrice + selectInteriorPrice
    }
    func selectExterior(code: String, price: Decimal) {
        selectExterior = code
        selectExteriorPrice = price
        totalPrice = selectModelPrice + selectSpareTirePrice + selectExteriorPrice + selectWheelPrice + selectInteriorPrice
    }
    func selectWheel(code: String, price: Decimal) {
        selectWheel = code
        selectWheelPrice = price
        totalPrice = selectModelPrice + selectSpareTirePrice + selectExteriorPrice + selectWheelPrice + selectInteriorPrice
    }
    func selectInterior(code: String, price: Decimal) {
        selectInterior = code
        selectInteriorPrice = price
        totalPrice = selectModelPrice + selectSpareTirePrice + selectExteriorPrice + selectWheelPrice + selectInteriorPrice
    }
    func saveOrder(orderNum: String) {
        VehicleManager.order(orderNum: orderNum)
        AppGlobalState.shared.needRefresh = true
        routerSubject.close.send()
    }
    func displayError(text: String) {
        
    }
    func displayLoading() {
        self.contentState = .loading
    }
}

// MARK: - Route

extension VehicleModelConfigModel: VehicleModelConfigModelRouterProtocol {
    func closeScreen() {
        routerSubject.close.send()
    }
    func routeToOrderDetail() {
        routerSubject.screen.send(.orderDetail)
    }
}

extension MarketingTypes.Model {
    enum VehicleModelConfigContentState {
        case loading
        case content
        case error(text: String)
    }
}
