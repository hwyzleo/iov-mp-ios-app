//
//  ModelVariantSelectionIntent.swift
//  iov
//
//  Created by iov on 2026/6/2.
//

import SwiftUI

class ModelVariantSelectionIntent: MviIntentProtocol {
    private weak var modelAction: ModelVariantSelectionModelActionProtocol?
    private weak var modelRouter: ModelVariantSelectionModelRouterProtocol?
    /// 路由携带的销售车型代码（优先于全局参数）
    private let routeSaleModelCode: String
    
    init(model: ModelVariantSelectionModelActionProtocol & ModelVariantSelectionModelRouterProtocol, saleModelCode: String = "") {
        self.modelAction = model
        self.modelRouter = model
        self.routeSaleModelCode = saleModelCode
    }
    
    func viewOnAppear() {
        let saleModelCode = syncSaleModelCode()
        let regionCode = AppGlobalState.shared.parameters["licenseCityCode"] as? String ?? ""
        
        modelAction?.displayLoading()
        ServiceContainer.marketingService.getConfigurator(saleModelCode: saleModelCode, regionCode: regionCode) { [weak self] (result: Result<TspResponse<ConfiguratorResult>, Error>) in
            switch result {
            case .success(let res):
                if res.isSuccess, let configurator = res.data {
                    self?.modelAction?.displayConfigurator(
                        saleModelCode: configurator.saleModelCode,
                        saleModelName: configurator.modelName,
                        models: configurator.models
                    )
                } else {
                    self?.modelAction?.displayError(text: res.message ?? "请求异常")
                }
            case .failure(_):
                self?.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    
    /// 以路由携带的车型代码为准；仅在值发生变化时写回全局参数
    /// （在 onAppear 阶段调用，属于合法时机，不会触发“视图更新期间发布变更”）
    private func syncSaleModelCode() -> String {
        let current = AppGlobalState.shared.parameters["saleModelCode"] as? String ?? ""
        guard !routeSaleModelCode.isEmpty, routeSaleModelCode != current else { return current }
        AppGlobalState.shared.parameters["saleModelCode"] = routeSaleModelCode
        return routeSaleModelCode
    }
}

// MARK: - Intent Protocol

extension ModelVariantSelectionIntent: ModelVariantSelectionIntentProtocol {
    func onTapVariant(model: ConfiguratorResult.ModelItem, variant: ConfiguratorResult.VariantItem) {
        AppGlobalState.shared.parameters["selectedModelCode"] = model.modelCode
        AppGlobalState.shared.parameters["selectedModelName"] = model.modelName
        AppGlobalState.shared.parameters["selectedVariantCode"] = variant.variantCode
        AppGlobalState.shared.parameters["selectedVariantName"] = variant.variantName
        AppGlobalState.shared.parameters["selectedVariantPrice"] = variant.variantPrice
        AppGlobalState.shared.parameters["selectedVariantEarnestMoneyPrice"] = variant.earnestMoneyPrice
        AppGlobalState.shared.parameters["selectedVariantDownPaymentPrice"] = variant.downPaymentPrice
        AppGlobalState.shared.parameters["selectedVariantSelectableFamilies"] = variant.selectableFamilies
        let saleModelCode = AppGlobalState.shared.parameters["saleModelCode"] as? String ?? ""
        AppRouter.shared.push(.marketing(.modelConfig(saleModelCode: saleModelCode)))
    }
}
