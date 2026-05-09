//
//  VehicleModel.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

final class VehicleModelConfigModel: ObservableObject, VehicleModelConfigModelStateProtocol {
    @Published var contentState: MarketingTypes.Model.VehicleModelConfigContentState = .loading
    let routerSubject = MarketingRouter.Subjects()
    var saleCode: String = ""
    var featureRanges: [FeatureCodeRangeVo] = []
    @Published var selections: [String: FeatureCodeDetailVo] = [:]
    @Published var totalPrice: Decimal = 0
}

// MARK: - Action Protocol

extension VehicleModelConfigModel: VehicleModelConfigModelActionProtocol {
    func updateFeatureRanges(saleCode: String, featureRanges: [FeatureCodeRangeVo]) {
        self.saleCode = saleCode
        self.featureRanges = featureRanges
        self.selections.removeAll()
        self.totalPrice = 0
        
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
        routerSubject.close.send()
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