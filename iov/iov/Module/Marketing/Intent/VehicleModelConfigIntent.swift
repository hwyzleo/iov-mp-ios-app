//
//  VehicleIntent.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
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
            AppGlobalState.shared.parameters["backCount"] = backCount - 1
            self.modelRouter?.closeScreen()
        } else {
            TspApi.getFeatureCodeRanges(saleCode: "HS5") { (result: Result<TspResponse<[FeatureCodeRangeVo]>, Error>) in
                switch result {
                case .success(let res):
                    if let featureRanges = res.data {
                        self.modelAction?.updateFeatureRanges(saleCode: "HS5", featureRanges: featureRanges)
                        
                        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
                            TspApi.getWishlist(orderNum: orderNum) { (result: Result<TspResponse<Wishlist>, Error>) in
                                switch result {
                                case .success(let res):
                                    if let wishlist = res.data {
                                        for range in featureRanges {
                                            if let code = wishlist.saleModelConfigType[range.familyCode],
                                               let feature = range.featureDetails.first(where: { $0.featureCode == code }) {
                                                self.modelAction?.selectFeature(familyCode: range.familyCode, feature: feature)
                                            }
                                        }
                                    }
                                case .failure(_):
                                    self.modelAction?.displayError(text: "请求异常")
                                }
                            }
                        }
                    }
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
}

extension VehicleModelConfigIntent: VehicleModelConfigIntentProtocol {
    func onTapFeature(familyCode: String, feature: FeatureCodeDetailVo) {
        modelAction?.selectFeature(familyCode: familyCode, feature: feature)
    }
    
    func onTapSaveWishlist() {
        guard let modelState = modelAction as? VehicleModelConfigModelStateProtocol else { return }
        
        let saleCode = modelState.saleCode
        let selections = modelState.selections
        
        var saleModelConfigType: [String: String] = [:]
        for (familyCode, feature) in selections {
            saleModelConfigType[familyCode] = feature.featureCode
        }
        
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            TspApi.modifyWishlist(orderNum: orderNum, saleCode: saleCode, saleModelConfigType: saleModelConfigType) { (result: Result<TspResponse<String>, Error>) in
                switch result {
                case .success(let res):
                    if res.isSuccess {
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
            TspApi.createWishlistNew(saleCode: saleCode, saleModelConfigType: saleModelConfigType) { (result: Result<TspResponse<String>, Error>) in
                switch result {
                case .success(let res):
                    if res.isSuccess {
                        let modelName = selections.first(where: { $0.key == "MODEL" })?.value.featureName ?? ""
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
    
    func onTapOrder() {
        guard let modelState = modelAction as? VehicleModelConfigModelStateProtocol else { return }
        
        let saleCode = modelState.saleCode
        let selections = modelState.selections
        
        AppGlobalState.shared.parameters["lastView"] = "MODEL_CONFIG"
        AppGlobalState.shared.parameters["orderDetailView"] = "ORDER"
        AppGlobalState.shared.parameters["saleCode"] = saleCode
        AppGlobalState.shared.parameters["featureSelections"] = selections
        
        self.modelRouter?.routeToOrderDetail()
    }
}