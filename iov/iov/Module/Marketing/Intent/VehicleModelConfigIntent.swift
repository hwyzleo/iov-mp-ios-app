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
            let mode = AppGlobalState.shared.parameters["modifyConfigMode"] as? String ?? "wishlist"
            
            guard let saleCode = AppGlobalState.shared.parameters["saleModelCode"] as? String, !saleCode.isEmpty else {
                self.modelAction?.displayError(text: "销售车型代码不能为空")
                return
            }
            
            // Check if variant data is pre-fetched from ModelVariantSelectionPage
            if let selectableFamilies = AppGlobalState.shared.parameters["selectedVariantSelectableFamilies"] as? [ConfiguratorResult.SelectableFamily] {
                loadFromPreselectedVariant(saleCode: saleCode, selectableFamilies: selectableFamilies, mode: mode)
            } else if mode == "order" {
                loadOrderConfig(saleCode: saleCode)
            } else {
                loadWishlistConfig(saleCode: saleCode)
            }
        }
    }
    
    private func loadFromPreselectedVariant(saleCode: String, selectableFamilies: [ConfiguratorResult.SelectableFamily], mode: String) {
        let featureRanges = convertSelectableFamiliesToFeatureCodeRanges(selectableFamilies)
        let basePrice = AppGlobalState.shared.parameters["selectedVariantPrice"] as? Decimal ?? 0
        modelAction?.updateFeatureRanges(saleCode: saleCode, featureRanges: featureRanges, basePrice: basePrice)
        
        if mode == "order" {
            if let saleModelConfigType = AppGlobalState.shared.parameters["saleModelConfigType"] as? [String: String] {
                for range in featureRanges {
                    if let featureCode = saleModelConfigType[range.familyCode],
                       let feature = range.featureDetails.first(where: { $0.featureCode == featureCode }) {
                        self.modelAction?.selectFeature(familyCode: range.familyCode, feature: feature)
                    }
                }
            }
        } else {
            if let wishlistId = VehicleManager.shared.getCurrentVehicleId() {
                TspApi.getWishlist(wishlistId: wishlistId) { (result: Result<TspResponse<Wishlist>, Error>) in
                    switch result {
                    case .success(let res):
                        if let wishlist = res.data {
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
    }
    
    private func convertSelectableFamiliesToFeatureCodeRanges(_ families: [ConfiguratorResult.SelectableFamily]) -> [FeatureCodeRangeVo] {
        return families.map { family in
            let featureDetails = family.options.map { option in
                FeatureCodeDetailVo(
                    featureCode: option.optionCode,
                    featureName: option.optionName,
                    featurePrice: option.price,
                    featureImage: option.image != nil ? [option.image!] : [],
                    featureDesc: option.marketingCopy,
                    featureParam: nil,
                    enable: option.saleStatus == "active",
                    sort: 0
                )
            }
            
            return FeatureCodeRangeVo(
                familyCode: family.optionFamilyCode,
                familyName: family.optionFamilyName,
                familyPrice: 0,
                familyImage: family.marketingImage != nil ? [family.marketingImage!] : [],
                familyDesc: family.marketingDesc,
                familyParam: nil,
                enable: true,
                sort: family.sortWeight ?? 0,
                featureDetails: featureDetails
            )
        }
    }
    
    private func loadOrderConfig(saleCode: String) {
        let regionCode = AppGlobalState.shared.parameters["licenseCityCode"] as? String ?? ""
        ServiceContainer.marketingService.getConfigurator(saleModelCode: saleCode, regionCode: regionCode) { (result: Result<TspResponse<ConfiguratorResult>, Error>) in
            switch result {
            case .success(let res):
                if let configurator = res.data {
                    let featureRanges = self.convertToFeatureCodeRanges(configurator)
                    let basePrice = AppGlobalState.shared.parameters["selectedVariantPrice"] as? Decimal ?? 0
                    self.modelAction?.updateFeatureRanges(saleCode: saleCode, featureRanges: featureRanges, basePrice: basePrice)
                    
                    if let saleModelConfigType = AppGlobalState.shared.parameters["saleModelConfigType"] as? [String: String] {
                        for range in featureRanges {
                            if let featureCode = saleModelConfigType[range.familyCode],
                               let feature = range.featureDetails.first(where: { $0.featureCode == featureCode }) {
                                self.modelAction?.selectFeature(familyCode: range.familyCode, feature: feature)
                            }
                        }
                    }
                }
            case .failure(_):
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    
    private func loadWishlistConfig(saleCode: String) {
        let regionCode = AppGlobalState.shared.parameters["licenseCityCode"] as? String ?? ""
        ServiceContainer.marketingService.getConfigurator(saleModelCode: saleCode, regionCode: regionCode) { (result: Result<TspResponse<ConfiguratorResult>, Error>) in
            switch result {
            case .success(let res):
                if let configurator = res.data {
                    let featureRanges = self.convertToFeatureCodeRanges(configurator)
                    let basePrice = AppGlobalState.shared.parameters["selectedVariantPrice"] as? Decimal ?? 0
                    self.modelAction?.updateFeatureRanges(saleCode: saleCode, featureRanges: featureRanges, basePrice: basePrice)
                    
                    if let wishlistId = VehicleManager.shared.getCurrentVehicleId() {
                        TspApi.getWishlist(wishlistId: wishlistId) { (result: Result<TspResponse<Wishlist>, Error>) in
                            switch result {
                            case .success(let res):
                                if let wishlist = res.data {
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
    
    /// 从配置项列表提取特征代码字典
    private func extractFeatureCodes(_ configItems: [SaleModelConfigItem]) -> [String: String] {
        var featureCodes: [String: String] = [:]
        for item in configItems {
            featureCodes[item.familyCode] = item.featureCode
        }
        return featureCodes
    }
    
    /// 将ConfiguratorResult转换为[FeatureCodeRangeVo]
    private func convertToFeatureCodeRanges(_ configurator: ConfiguratorResult) -> [FeatureCodeRangeVo] {
        guard let firstModel = configurator.models.first,
              let firstVariant = firstModel.variants.first else {
            return []
        }
        
        return firstVariant.selectableFamilies.map { family in
            let featureDetails = family.options.map { option in
                FeatureCodeDetailVo(
                    featureCode: option.optionCode,
                    featureName: option.optionName,
                    featurePrice: option.price,
                    featureImage: option.image != nil ? [option.image!] : [],
                    featureDesc: option.marketingCopy,
                    featureParam: nil,
                    enable: option.saleStatus == "ON_SALE",
                    sort: 0
                )
            }
            
            return FeatureCodeRangeVo(
                familyCode: family.optionFamilyCode,
                familyName: family.optionFamilyName,
                familyPrice: 0,
                familyImage: family.marketingImage != nil ? [family.marketingImage!] : [],
                familyDesc: family.marketingDesc,
                familyParam: nil,
                enable: true,
                sort: family.sortWeight ?? 0,
                featureDetails: featureDetails
            )
        }
    }
}

extension VehicleModelConfigIntent: VehicleModelConfigIntentProtocol {
    func onTapFeature(familyCode: String, feature: FeatureCodeDetailVo) {
        modelAction?.selectFeature(familyCode: familyCode, feature: feature)
    }
    
    func onTapSaveWishlist() {
        let mode = AppGlobalState.shared.parameters["modifyConfigMode"] as? String ?? "wishlist"
        
        if mode == "order" {
            saveOrderConfig()
        } else {
            saveWishlist()
        }
    }
    
    private func saveOrderConfig() {
        guard let modelState = modelAction as? VehicleModelConfigModelStateProtocol else { return }
        guard let orderNo = AppGlobalState.shared.parameters["modifyConfigOrderNo"] as? String else { return }
        
        let selections = modelState.selections
        
        var saleModelConfigType: [String: String] = [:]
        for (familyCode, feature) in selections {
            saleModelConfigType[familyCode] = feature.featureCode
        }
        
        ServiceContainer.marketingService.modifyConfig(
            orderNo: orderNo,
            saleModelConfigType: saleModelConfigType
        ) { [weak self] result in
            switch result {
            case .success(let res):
                if res.isSuccess {
                    AppGlobalState.shared.backRefresh = true
                    AppGlobalState.shared.parameters["modifyConfigMode"] = nil
                    AppGlobalState.shared.parameters["modifyConfigOrderNo"] = nil
                    AppGlobalState.shared.parameters["saleModelConfigType"] = nil
                    self?.modelRouter?.closeScreen()
                } else {
                    self?.modelAction?.displayError(text: res.message ?? "请求异常")
                }
            case .failure(_):
                self?.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    
    private func saveWishlist() {
        guard let modelState = modelAction as? VehicleModelConfigModelStateProtocol else { return }
        
        let saleModelCode = modelState.saleCode
        let selections = modelState.selections
        
        var featureConfig: [String: String] = [:]
        for (familyCode, feature) in selections {
            featureConfig[familyCode] = feature.featureCode
        }
        
        let currentId = VehicleManager.shared.getCurrentVehicleId()
        
        if let wishlistId = currentId {
            TspApi.modifyWishlist(wishlistId: wishlistId, featureConfig: featureConfig) { [weak self] (result: Result<TspResponse<String>, Error>) in
                switch result {
                case .success(let res):
                    if res.isSuccess {
                        AppGlobalState.shared.backRefresh = true
                        AppGlobalState.shared.parameters["orderDetailView"] = "WISHLIST"
                        self?.modelRouter?.closeScreen()
                    } else {
                        self?.modelAction?.displayError(text: res.message ?? "请求异常")
                    }
                case .failure(_):
                    self?.modelAction?.displayError(text: "请求异常")
                }
            }
        } else {
            TspApi.createWishlist(saleModelCode: saleModelCode, featureConfig: featureConfig) { [weak self] (result: Result<TspResponse<String>, Error>) in
                switch result {
                case .success(let res):
                    if res.isSuccess {
                        let modelName = selections.first(where: { $0.key == "MODEL" })?.value.featureName ?? ""
                        VehicleManager.shared.add(orderNum: res.data!, type: .WISHLIST, displayName: modelName)
                        VehicleManager.shared.setCurrentVehicleId(id: res.data!)
                        AppGlobalState.shared.backRefresh = true
                        AppGlobalState.shared.parameters["orderDetailView"] = "WISHLIST"
                        self?.modelRouter?.closeScreen()
                    } else {
                        self?.modelAction?.displayError(text: res.message ?? "请求异常")
                    }
                case .failure(_):
                    self?.modelAction?.displayError(text: "请求异常")
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
