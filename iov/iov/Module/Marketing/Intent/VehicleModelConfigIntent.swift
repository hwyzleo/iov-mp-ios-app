//
//  VehicleIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

class VehicleModelConfigIntent: MviIntentProtocol {
    private weak var modelAction: VehicleModelConfigModelActionProtocol?
    private weak var modelRouter: VehicleModelConfigModelRouterProtocol?
    
    init(model: VehicleModelConfigModelActionProtocol & VehicleModelConfigModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    func viewOnAppear() {
        modelAction?.displayLoading()
        var backCount = 0
        if let count = AppGlobalState.shared.parameters["backCount"] as? Int {
            backCount = count
        }
        if backCount > 0 {
            AppGlobalState.shared.parameters["backCount"] = backCount-1
            self.modelRouter?.closeScreen()
        } else {
            TspApi.getSaleModelList(saleCode: "H01") { (result: Result<TspResponse<[SaleModelConfig]>, Error>) in
                switch result {
                case .success(let res):
                    if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
                        TspApi.getWishlist(orderNum: orderNum) { (result: Result<TspResponse<Wishlist>, Error>) in
                            switch result {
                            case .success(let res):
                                let wishlist = res.data!
                                self.modelAction?.selectModel(
                                    code: wishlist.saleModelConfigType["MODEL"] ?? "",
                                    name: wishlist.saleModelConfigName["MODEL"] ?? "",
                                    price: wishlist.saleModelConfigPrice["MODEL"] ?? 0
                                )
                                self.modelAction?.selectSpareTire(
                                    code: wishlist.saleModelConfigType["SPARE_TIRE"] ?? "",
                                    price: wishlist.saleModelConfigPrice["SPARE_TIRE"] ?? 0
                                )
                                self.modelAction?.selectExterior(
                                    code: wishlist.saleModelConfigType["EXTERIOR"] ?? "",
                                    price: wishlist.saleModelConfigPrice["EXTERIOR"] ?? 0
                                )
                                self.modelAction?.selectWheel(
                                    code: wishlist.saleModelConfigType["WHEEL"] ?? "",
                                    price: wishlist.saleModelConfigPrice["WHEEL"] ?? 0
                                )
                                self.modelAction?.selectInterior(
                                    code: wishlist.saleModelConfigType["INTERIOR"] ?? "",
                                    price: wishlist.saleModelConfigPrice["INTERIOR"] ?? 0
                                )
                                self.modelAction?.selectAdas(
                                    code: wishlist.saleModelConfigType["ADAS"] ?? "",
                                    price: wishlist.saleModelConfigPrice["ADAS"] ?? 0
                                )
                            case .failure(_):
                                self.modelAction?.displayError(text: "请求异常")
                            }
                        }
                    }
                    self.modelAction?.updateSaleModel(saleCode: "H01", saleModels: res.data!)
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
}

extension VehicleModelConfigIntent: VehicleModelConfigIntentProtocol {
    func onTapModel(code: String, name: String, price: Decimal) {
        modelAction?.selectModel(code: code, name: name, price: price)
    }
    func onTapSpareTire(code: String, price: Decimal) {
        modelAction?.selectSpareTire(code: code, price: price)
    }
    func onTapExterior(code: String, price: Decimal) {
        modelAction?.selectExterior(code: code, price: price)
    }
    func onTapWheel(code: String, price: Decimal) {
        modelAction?.selectWheel(code: code, price: price)
    }
    func onTapInterior(code: String, price: Decimal) {
        modelAction?.selectInterior(code: code, price: price)
    }
    func onTapAdas(code: String, price: Decimal) {
        modelAction?.selectAdas(code: code, price: price)
    }
    func onTapSaveWishlist(saleCode: String, modelCode: String, modelName: String, spareTireCode: String, exteriorCode: String, wheelCode: String, interiorCode: String, adasCode: String) {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            TspApi.modifyWishlist(orderNum: orderNum, saleCode: saleCode, modelCode: modelCode, spareTireCode: spareTireCode, exteriorCode: exteriorCode, wheelCode: wheelCode, interiorCode: interiorCode, adasCode: adasCode) { (result: Result<TspResponse<String>, Error>) in
                switch result {
                case .success(let res):
                    if res.code == 0 {
                        AppGlobalState.shared.backRefresh = true
                        AppGlobalState.shared.parameters["orderDetailView"] = "WISHLIST"
                        self.modelRouter?.closeScreen()
                    } else {
                        self.modelAction?.displayError(text: res.message ?? "请求异常")
                    }
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        } else {
            TspApi.createWishlist(saleCode: saleCode, modelCode: modelCode, spareTireCode: spareTireCode, exteriorCode: exteriorCode, wheelCode: wheelCode, interiorCode: interiorCode, adasCode: adasCode) { (result: Result<TspResponse<String>, Error>) in
                switch result {
                case .success(let res):
                    if res.code == 0 {
                        VehicleManager.shared.add(orderNum: res.data!, type: .WISHLIST, displayName: modelName)
                        VehicleManager.shared.setCurrentVehicleId(id: res.data!)
                        AppGlobalState.shared.backRefresh = true
                        AppGlobalState.shared.parameters["orderDetailView"] = "WISHLIST"
                        self.modelRouter?.closeScreen()
                    } else {
                        self.modelAction?.displayError(text: res.message ?? "请求异常")
                    }
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    func onTapOrder(saleCode: String, modelCode: String, modelName: String, spareTireCode: String, exteriorCode: String, wheelCode: String, interiorCode: String, adasCode: String) {
        AppGlobalState.shared.parameters["lastView"] = "MODEL_CONFIG"
        AppGlobalState.shared.parameters["orderDetailView"] = "ORDER"
        AppGlobalState.shared.parameters["saleCode"] = saleCode
        AppGlobalState.shared.parameters["modelCode"] = modelCode
        AppGlobalState.shared.parameters["exteriorCode"] = exteriorCode
        AppGlobalState.shared.parameters["interiorCode"] = interiorCode
        AppGlobalState.shared.parameters["wheelCode"] = wheelCode
        AppGlobalState.shared.parameters["spareTireCode"] = spareTireCode
        AppGlobalState.shared.parameters["adasCode"] = adasCode
        self.modelRouter?.routeToOrderDetail()
    }
}
