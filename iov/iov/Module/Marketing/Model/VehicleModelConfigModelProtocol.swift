//
//  VehicleModelProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

// MARK: - View State

protocol VehicleModelConfigModelStateProtocol {
    var contentState: MarketingTypes.Model.VehicleModelConfigContentState { get }
    var routerSubject: MarketingRouter.Subjects { get }
    var saleCode: String { get }
    var featureRanges: [FeatureCodeRangeVo] { get }
    var selections: [String: FeatureCodeDetailVo] { get }
    var totalPrice: Decimal { get }
    var modelMarketingName: String { get }
    var variantMarketingName: String { get }
}

// MARK: - Intent Action

protocol VehicleModelConfigModelActionProtocol: MviModelActionProtocol {
    func updateFeatureRanges(saleCode: String, featureRanges: [FeatureCodeRangeVo], basePrice: Decimal)
    func selectFeature(familyCode: String, feature: FeatureCodeDetailVo)
    func saveOrder(orderNum: String)
    func updateModelInfo(modelMarketingName: String, variantMarketingName: String)
}

// MARK: - Route

protocol VehicleModelConfigModelRouterProtocol: MviModelRouterProtocol {
    func routeToOrderDetail()
    func routeToModelVariantSelection()
    func routeToMarketingIndex()
}