//
//  VehicleModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class VehicleOrderModel: ObservableObject, VehicleOrderModelStateProtocol {
    @Published var contentState: MarketingTypes.Model.VehicleOrderContentState = .loading
    let routerSubject = MarketingRouter.Subjects()
    var models: [SaleModel] = []
    @Published var selectModel: String = ""
    @Published var selectModelPrice: Decimal = 0
    var spareTires: [SaleModel] = []
    @Published var selectSpareTire: String = ""
    @Published var selectSpareTirePrice: Decimal = 0
    var exteriors: [SaleModel] = []
    @Published var selectExterior: String = ""
    @Published var selectExteriorPrice: Decimal = 0
    var wheels: [SaleModel] = []
    @Published var selectWheel: String = ""
    @Published var selectWheelPrice: Decimal = 0
    var interiors: [SaleModel] = []
    @Published var selectInterior: String = ""
    @Published var selectInteriorPrice: Decimal = 0
    var optionals: [SaleModel] = []
    @Published var selectOptional: String = ""
    @Published var selectOptionalPrice: Decimal = 0
    @Published var totalPrice: Decimal = 0
}

// MARK: - Action Protocol

extension VehicleOrderModel: VehicleOrderModelActionProtocol {
    func updateSaleModel(saleModels: [SaleModel]) {
        for saleModel in saleModels {
            switch saleModel.saleModelType {
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
            case "OPTIONAL":
                optionals.append(saleModel)
            default:
                break
            }
        }
        contentState = .content
    }
    func selectModel(code: String, price: Decimal) {
        selectModel = code
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
        
    }
}

func safeIntFromString(_ string: String) -> Int {
    return Int(string) ?? 0
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
