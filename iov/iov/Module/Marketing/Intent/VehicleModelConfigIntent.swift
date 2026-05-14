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
            guard let saleCode = AppGlobalState.shared.parameters["saleModelCode"] as? String, !saleCode.isEmpty else {
                self.modelAction?.displayError(text: "销售车型代码不能为空")
                return
            }
            TspApi.getFeatureCodeRanges(saleCode: saleCode) { (result: Result<TspResponse<[FeatureCodeRangeVo]>, Error>) in
                switch result {
                case .success(let res):
                    if let featureRanges = res.data {
                        self.modelAction?.updateFeatureRanges(saleCode: saleCode, featureRanges: featureRanges)
                        
                        if let wishlistId = VehicleManager.shared.getCurrentVehicleId() {
                            TspApi.getWishlist(wishlistId: wishlistId) { (result: Result<TspResponse<Wishlist>, Error>) in
                                switch result {
                                case .success(let res):
                                    if let wishlist = res.data {
                                        // 将配置项列表转换为特征代码字典
                                        let featureCodes = self.extractFeatureCodes(wishlist.saleModelConfigs)
                                        
                                        for range in featureRanges {
                                            if let code = featureCodes[range.familyCode],
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
    
    /// 从配置项列表提取特征代码字典
    private func extractFeatureCodes(_ configItems: [SaleModelConfigItem]) -> [String: String] {
        var featureCodes: [String: String] = [:]
        for item in configItems {
            featureCodes[item.familyCode] = item.featureCode
        }
        return featureCodes
    }
}

extension VehicleModelConfigIntent: VehicleModelConfigIntentProtocol {
    func onTapFeature(familyCode: String, feature: FeatureCodeDetailVo) {
        modelAction?.selectFeature(familyCode: familyCode, feature: feature)
    }
    
    func onTapSaveWishlist() {
        guard let modelState = modelAction as? VehicleModelConfigModelStateProtocol else { return }
        
        let saleModelCode = modelState.saleCode
        let selections = modelState.selections
        
        var featureConfig: [String: String] = [:]
        for (familyCode, feature) in selections {
            featureConfig[familyCode] = feature.featureCode
        }
        
        // 打印当前状态
        let currentId = VehicleManager.shared.getCurrentVehicleId()
        print("🚗 onTapSaveWishlist() - CurrentVehicleId: \(currentId ?? "nil")")
        print("🚗 onTapSaveWishlist() - Vehicles count: \(VehicleManager.shared.getVehiclesForMock().count)")
        
        if let wishlistId = currentId {
            print("📝 onTapSaveWishlist() - MODIFYING existing wishlist: \(wishlistId)")
            TspApi.modifyWishlist(wishlistId: wishlistId, featureConfig: featureConfig) { (result: Result<TspResponse<String>, Error>) in
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
            print("🆕 onTapSaveWishlist() - CREATING new wishlist")
            TspApi.createWishlist(saleModelCode: saleModelCode, featureConfig: featureConfig) { (result: Result<TspResponse<String>, Error>) in
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
        
        var saleModelConfigType: [String: String] = [:]
        for (familyCode, feature) in selections {
            saleModelConfigType[familyCode] = feature.featureCode
        }
        
        AppGlobalState.shared.parameters["lastView"] = "MODEL_CONFIG"
        AppGlobalState.shared.parameters["orderDetailView"] = "ORDER"
        AppGlobalState.shared.parameters["saleModelCode"] = saleCode
        AppGlobalState.shared.parameters["saleModelConfigType"] = saleModelConfigType
        
        self.modelRouter?.routeToOrderDetail()
    }
}
