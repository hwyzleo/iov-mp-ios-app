//
//  ModelVariantSelectionModelProtocol.swift
//  iov
//
//  Created by iov on 2026/6/2.
//

import SwiftUI

// MARK: - View State

protocol ModelVariantSelectionModelStateProtocol {
    var contentState: MarketingTypes.Model.ModelVariantSelectionContentState { get }
    var routerSubject: MarketingRouter.Subjects { get }
    var saleModelCode: String { get }
    var saleModelName: String { get }
    var models: [ConfiguratorResult.ModelItem] { get }
}

// MARK: - Intent Action

protocol ModelVariantSelectionModelActionProtocol: MviModelActionProtocol {
    func displayConfigurator(saleModelCode: String, saleModelName: String, models: [ConfiguratorResult.ModelItem])
}

// MARK: - Route

protocol ModelVariantSelectionModelRouterProtocol: MviModelRouterProtocol {
    func routeToModelConfig()
}
