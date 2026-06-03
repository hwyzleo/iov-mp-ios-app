//
//  VehicleModel.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

final class VehicleModelConfigModel: ObservableObject, VehicleModelConfigModelStateProtocol {
    @Published var contentState: MarketingTypes.Model.VehicleModelConfigContentState = .loading
    var saleCode: String = ""
    var featureRanges: [FeatureCodeRangeVo] = []
    @Published var selections: [String: FeatureCodeDetailVo] = [:]
    @Published var totalPrice: Decimal = 0
    var basePrice: Decimal = 0
    var modelMarketingName: String = ""
    var variantMarketingName: String = ""
}

// MARK: - Action Protocol

extension VehicleModelConfigModel: VehicleModelConfigModelActionProtocol {
    func updateFeatureRanges(saleCode: String, featureRanges: [FeatureCodeRangeVo], basePrice: Decimal) {
        self.saleCode = saleCode
        self.featureRanges = featureRanges
        self.selections.removeAll()
        self.basePrice = basePrice
        self.totalPrice = basePrice
        
        for range in featureRanges {
            if let firstFeature = range.featureDetails.first {
                selections[range.familyCode] = firstFeature
                totalPrice += firstFeature.featurePrice
            }
        }
        contentState = .content
    }
    
    func selectFeature(familyCode: String, feature: FeatureCodeDetailVo) {
        if let oldFeature = selections[familyCode] {
            totalPrice -= oldFeature.featurePrice
        }
        totalPrice += feature.featurePrice
        selections[familyCode] = feature
    }
    
    func saveOrder(orderNum: String) {
        VehicleManager.order(orderNum: orderNum)
        AppGlobalState.shared.needRefresh = true
        AppRouter.shared.pop()
    }
    
    func updateModelInfo(modelMarketingName: String, variantMarketingName: String) {
        self.modelMarketingName = modelMarketingName
        self.variantMarketingName = variantMarketingName
    }
    
    func displayError(text: String) {
        contentState = .error(text: text)
    }
    
    func displayLoading() {
        contentState = .loading
    }
}

// MARK: - Route

extension VehicleModelConfigModel: VehicleModelConfigModelRouterProtocol {
    func closeScreen() {
        AppRouter.shared.pop()
    }
    
    func routeToOrderDetail() {
    }
    
    func routeToModelVariantSelection() {
    }
    
    func routeToMarketingIndex() {
        AppRouter.shared.popToRoot()
    }
}

extension MarketingTypes.Model {
    enum VehicleModelConfigContentState {
        case loading
        case content
        case error(text: String)
    }
}