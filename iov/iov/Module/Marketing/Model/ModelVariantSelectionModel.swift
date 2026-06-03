//
//  ModelVariantSelectionModel.swift
//  iov
//
//  Created by iov on 2026/6/2.
//

import SwiftUI

final class ModelVariantSelectionModel: ObservableObject, ModelVariantSelectionModelStateProtocol {
    @Published var contentState: MarketingTypes.Model.ModelVariantSelectionContentState = .loading
    @Published var saleModelCode: String = ""
    @Published var saleModelName: String = ""
    @Published var models: [ConfiguratorResult.ModelItem] = []
}

// MARK: - Action Protocol

extension ModelVariantSelectionModel: ModelVariantSelectionModelActionProtocol {
    func displayError(text: String) {
        contentState = .error(text: text)
    }
    func displayLoading() {
        contentState = .loading
    }
    func displayConfigurator(saleModelCode: String, saleModelName: String, models: [ConfiguratorResult.ModelItem]) {
        self.saleModelCode = saleModelCode
        self.saleModelName = saleModelName
        self.models = models
        contentState = .content
    }
}

// MARK: - Route

extension ModelVariantSelectionModel: ModelVariantSelectionModelRouterProtocol {
    func routeToModelConfig() {
    }
    func closeScreen() {
    }
}

// MARK: - ContentState

extension MarketingTypes.Model {
    enum ModelVariantSelectionContentState {
        case loading
        case content
        case error(text: String)
    }
}
