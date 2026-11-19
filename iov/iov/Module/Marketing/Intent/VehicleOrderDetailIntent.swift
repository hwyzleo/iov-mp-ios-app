//
//  VehicleWishlistIntent.swift
//  iov
//
//  Created by hwyz_leo on 2024/10/13.
//

import SwiftUI

class VehicleOrderDetailIntent: MviIntentProtocol {
    private weak var modelAction: VehicleOrderDetailModelActionProtocol?
    private weak var modelRouter: VehicleOrderDetailModelRouterProtocol?
    private var loadedAgreements: [PurchaseAgreement] = []
    private var agreementsLoaded = false
    /// 路由传入的订单号/心愿单号（不再通过 AppGlobalState.parameters 传递，避免视图更新期间发布变更）
    private let orderNo: String
    
    init(model: VehicleOrderDetailModelActionProtocol & VehicleOrderDetailModelRouterProtocol, orderNo: String = "") {
        self.modelAction = model
        self.modelRouter = model
        self.orderNo = orderNo
    }
    
func viewOnAppear() {
        let currentState = modelAction?.getContentState()
        
        if modelAction?.getContentState() == .order && AppGlobalState.shared.parameters["orderDetailView"] == nil {
            return
        }
        if currentState != .loading && currentState != .wishlist {
            return
        }
        
        var viewName: String? = AppGlobalState.shared.parameters["orderDetailView"] as? String
        
        let orderNum: String? = orderNo.isEmpty ? VehicleManager.shared.getCurrentVehicleId() : orderNo
        
        if viewName != nil {
            AppGlobalState.shared.parameters["orderDetailView"] = nil
        } else {
            if let id = orderNum, let vehicle = VehicleManager.shared.getVehiclesForMock()[id] {
                switch vehicle.subState {
                case 100: viewName = "WISHLIST"
                case 200: viewName = "EARNEST_MONEY_UNPAID"
                case 210: viewName = "EARNEST_MONEY_PAID"
                case 300: viewName = "DOWN_PAYMENT_UNPAID"
                case 310: viewName = "DOWN_PAYMENT_PAID"
                case 400: viewName = "ARRANGE_PRODUCTION"
                case 450, 470: viewName = "ALLOCATION_VEHICLE"
                case 500, 550: viewName = "PREPARE_TRANSPORT"
                case 600: viewName = "PREPARE_DELIVER"
                case 620: viewName = "FINAL_PAYMENT_PAID"
                case 630: viewName = "INVOICED"
                case 650, 900: viewName = "DELIVERED"
                case 950, 960, 970: viewName = "INVALID"
                default: break
                }
            }
        }
        
        if viewName == nil, let vehicle = VehicleManager.shared.getCurrentVehicle() {
            if vehicle.type == .WISHLIST { viewName = "WISHLIST" }
            else {
                if vehicle.subState == 200 { viewName = "EARNEST_MONEY_UNPAID" }
                else if vehicle.subState == 210 { viewName = "EARNEST_MONEY_PAID" }
            }
        }
        
        if let view = viewName {
            modelAction?.displayLoading()
            switch view {
            case "WISHLIST": handleWishlist()
            case "EARNEST_MONEY_UNPAID": handleEarnestMoneyUnpaid()
            case "EARNEST_MONEY_PAID": handleEarnestMoneyPaid()
            case "DOWN_PAYMENT_UNPAID": handleDownPaymentUnpaid()
            case "DOWN_PAYMENT_PAID": handleDownPaymentPaid()
            case "ARRANGE_PRODUCTION": handleArrangeProduction()
            case "ALLOCATION_VEHICLE": handleAllocationVehicle()
            case "PREPARE_TRANSPORT": handlePrepareTransport()
            case "PREPARE_DELIVER": handlePrepareDeliver()
            case "FINAL_PAYMENT_PAID": handleFinalPaymentPaid()
            case "INVOICED": handleInvoiced()
            case "DELIVERED": handleDelivered()
            case "INVALID": handleInvalidOrder()
            default: handleOrder()
            }
        }
    }
    
    /// 终态订单（失效/取消/关闭）：只读展示，不展示支付按钮；失效可重新发起支付
    private func handleInvalidOrder() {
        let orderNum = orderNo.isEmpty ? (VehicleManager.shared.getCurrentVehicleId() ?? "") : orderNo
        guard !orderNum.isEmpty else {
            modelAction?.displayError(text: "请求异常")
            return
        }
        let localState = VehicleManager.shared.getVehiclesForMock()[orderNum]?.subState
        ServiceContainer.marketingService.getOrder(orderNo: orderNum) { [weak self] (result: Result<TspResponse<Order>, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let res):
                guard let order = res.data else {
                    self.modelAction?.displayError(text: res.message ?? "请求异常")
                    return
                }
                let displayName = order.variantName ?? order.modelName ?? ""
                self.modelAction?.updateSaleModelImages(saleModelImages: order.saleModelImages ?? [])
                self.modelAction?.updateSaleModelIntro(saleModelName: displayName, saleModelDesc: order.saleModelDesc ?? "")
                self.modelAction?.updateSaleModelPrice(saleModelName: displayName,
                                                       saleModelPrice: order.totalPrice ?? 0,
                                                       totalPrice: order.totalPrice ?? 0)
                self.modelAction?.updateOrder(orderNum: order.orderNo, orderTime: order.orderTime ?? 0)
                // 服务端状态为权威来源，同步修正本地缓存
                VehicleManager.shared.updateSubState(id: orderNum, subState: order.orderState)
                let info = Self.invalidTitleAndReopenFlag(for: order.orderState)
                self.modelAction?.displayInvalidOrder(title: info.title, canReopenPayment: info.canReopen)
            case .failure(_):
                let info = Self.invalidTitleAndReopenFlag(for: localState ?? 0)
                self.modelAction?.displayInvalidOrder(title: info.title, canReopenPayment: info.canReopen)
            }
        }
    }

    private static func invalidTitleAndReopenFlag(for state: Int) -> (title: String, canReopen: Bool) {
        switch state {
        case 950: return (String(localized: "order_cancelled"), false)
        case 970: return (String(localized: "order_closed"), false)
        default: return (String(localized: "order_expired"), true)
        }
    }

    /// 重新发起支付：先调用云端恢复，成功后按意向金阶段发起支付
    func onTapReopenPayment() {
        guard let orderNo = VehicleManager.shared.getCurrentVehicleId() else { return }
        modelAction?.displayLoading()
        PaymentFlowService.shared.reopenPayment(orderNo: orderNo) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.onTapPayOrder(orderPaymentPhase: 1, paymentAmount: 0, paymentChannel: "ALIPAY")
            case .failure(let error):
                self.viewOnAppear()
                self.modelAction?.displayError(text: error.localizedDescription)
            }
        }
    }

private func convertToDynamicConfigs(configName: [String: String]?, configPrice: [String: Decimal]?) -> [(String, String, Decimal)] {
        var configs: [(String, String, Decimal)] = []
        guard let names = configName, let prices = configPrice else { return configs }
        
        for (key, name) in names {
            if key != "BASE_MODEL" {
                let price = prices[key] ?? 0
                configs.append((key, name, price))
            }
        }
        return configs
    }
    
    private func convertOptionBreakdownToDynamicConfigs(_ optionBreakdown: [OptionBreakdownItem]?) -> [(String, String, Decimal)] {
        guard let options = optionBreakdown else { return [] }
        return options.map { option in
            let displayName = option.optionFamilyName ?? option.optionName ?? option.optionCode
            let title = option.optionName ?? option.optionCode
            return (displayName, title, option.optionPrice ?? 0)
        }
    }
    
    private func handleWishlist() {
        if let wishlistId = VehicleManager.shared.getCurrentVehicleId() {
            ServiceContainer.marketingService.getWishlist(wishlistId: wishlistId) { (result: Result<TspResponse<Wishlist>, Error>) in
                switch result {
                case .success(let res):
                    guard let wishlist = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    
                    // 更新车型图片
                    self.modelAction?.updateSaleModelImages(saleModelImages: wishlist.saleModelImages ?? [])
                    
                    // 更新车型简介
                    let saleModelName = wishlist.saleModelName ?? ""
                    let modelMarketingName = wishlist.modelMarketingName ?? ""
                    let variantMarketingName = wishlist.variantMarketingName ?? ""
                    let displayName = [saleModelName, modelMarketingName, variantMarketingName]
                        .filter { !$0.isEmpty }
                        .joined(separator: " ")
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: displayName.isEmpty ? "心愿单配置" : displayName,
                        saleModelDesc: "\(modelMarketingName) | \(variantMarketingName)"
                    )
                    
                    // 更新总价
                    self.modelAction?.updateTotalPrice(totalPrice: wishlist.totalPrice ?? 0)
                    
                    // 显示配置项
                    var displayConfigs: [(String, String, Decimal)] = []
                    
                    // 先添加车型基础价格
                    if let variantPrice = wishlist.variantPrice {
                        displayConfigs.append((wishlist.variantMarketingName ?? "车型", wishlist.variantMarketingName ?? "车型", variantPrice))
                    }
                    
                    // 添加选项配置
                    if let optionDetails = wishlist.optionDetails {
                        for option in optionDetails {
                            let title = option.marketingTitle ?? option.optionCode
                            let familyTitle = option.marketingTitle ?? option.optionFamilyCode
                            displayConfigs.append((familyTitle, title, option.optionPrice ?? 0))
                        }
                    }
                    
                    self.modelAction?.updateDynamicConfigs(displayConfigs)
                    
                    self.modelAction?.displayWishlist()
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    

    
    private func handleOrder() {
        let saleModelCode = AppGlobalState.shared.parameters["saleModelCode"] as? String ?? ""
        loadPurchaseAgreements(saleModelCode: saleModelCode) { [weak self] in
            self?.loadOrderConfigurator(saleModelCode: saleModelCode)
        }
    }

    /// 加载当前车型生效购车协议（下单前必须携带 agreementCode + versionNo）
    private func loadPurchaseAgreements(saleModelCode: String, completion: @escaping () -> Void) {
        guard !saleModelCode.isEmpty else {
            agreementsLoaded = true
            loadedAgreements = []
            modelAction?.updatePurchaseAgreements([])
            completion()
            return
        }
        ServiceContainer.marketingService.getPurchaseAgreements(saleModelCode: saleModelCode) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.isSuccess {
                        self?.loadedAgreements = response.data ?? []
                    } else {
                        self?.loadedAgreements = []
                    }
                case .failure:
                    self?.loadedAgreements = []
                }
                self?.agreementsLoaded = true
                self?.modelAction?.updatePurchaseAgreements(self?.loadedAgreements ?? [])
                completion()
            }
        }
    }

    /// 当前确认的购车协议（与后端 agreementConfirmations 结构一致）
    private func currentAgreementConfirmations() -> [AgreementConfirmation] {
        return loadedAgreements.map {
            AgreementConfirmation(agreementCode: $0.agreementCode, versionNo: $0.versionNo)
        }
    }

    /// 加载选配器 + 实时报价，并进入下单页
    private func loadOrderConfigurator(saleModelCode: String) {
        let saleModelConfigType = AppGlobalState.shared.parameters["saleModelConfigType"] as? [String: String] ?? [:]
        let regionCode = AppGlobalState.shared.parameters["licenseCityCode"] as? String ?? ""
        let savedOptionCodes = AppGlobalState.shared.parameters["optionCodes"] as? [String] ?? []
        
        ServiceContainer.marketingService.getConfigurator(saleModelCode: saleModelCode, regionCode: regionCode) { [weak self] (result: Result<TspResponse<ConfiguratorResult>, Error>) in
            switch result {
            case .success(let res):
                if res.isSuccess {
                    guard let configurator = res.data else {
                        self?.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    
                    self?.updateUIFromConfigurator(configurator, saleModelConfigType: saleModelConfigType)
                    
                    if let firstModel = configurator.models.first,
                       let firstVariant = firstModel.variants.first {
                        let optionCodes = savedOptionCodes.isEmpty ? (self?.extractSelectedOptionCodes(from: firstVariant, saleModelConfigType: saleModelConfigType) ?? []) : savedOptionCodes
                        
                        AppGlobalState.shared.parameters["selectedModelCode"] = firstModel.modelCode
                        AppGlobalState.shared.parameters["selectedVariantCode"] = firstVariant.variantCode
                        
                        ServiceContainer.marketingService.getQuote(
                            saleModelCode: saleModelCode,
                            modelCode: firstModel.modelCode,
                            variantCode: firstVariant.variantCode,
                            optionCodes: optionCodes,
                            regionCode: regionCode
                        ) { [weak self] (quoteResult: Result<TspResponse<QuoteResult>, Error>) in
                            switch quoteResult {
                            case .success(let quoteRes):
                                if quoteRes.isSuccess, let quote = quoteRes.data {
                                    self?.modelAction?.updateSaleModelPrice(
                                        saleModelName: firstModel.modelName,
                                        saleModelPrice: firstVariant.variantPrice,
                                        totalPrice: quote.totalPrice
                                    )
                                    self?.modelAction?.displayOrder()
                                } else {
                                    self?.modelAction?.displayError(text: quoteRes.message ?? "请求异常")
                                }
                            case .failure(_):
                                self?.modelAction?.displayError(text: "请求异常")
                            }
                        }
                    } else {
                        self?.modelAction?.displayError(text: "车型配置数据异常")
                    }
                } else {
                    self?.modelAction?.displayError(text: res.message ?? "请求异常")
                }
            case .failure(_):
                self?.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    
    private func updateUIFromConfigurator(_ configurator: ConfiguratorResult, saleModelConfigType: [String: String]) {
        guard let firstModel = configurator.models.first,
              let firstVariant = firstModel.variants.first else {
            return
        }
        
        // 车型图片：model.marketingImage 可能为空串（真正图片在 variant.marketingImage 上），
        // 需过滤空串，否则会把 [""] 传给图片轮播导致顶部图片区域空白
        let saleModelImages = nonEmptyImageURLs([firstModel.marketingImage, firstVariant.marketingImage])
        if !saleModelImages.isEmpty {
            // 配置器未提供有效图片时保留已有图片（例如从心愿单进入时的车辆图片）
            self.modelAction?.updateSaleModelImages(saleModelImages: saleModelImages)
        }
        
        self.modelAction?.updateSaleModelIntro(
            saleModelName: firstModel.modelName,
            saleModelDesc: firstModel.marketingCopy ?? ""
        )
        
        let hasDownPayment = firstVariant.downPaymentPrice != nil && firstVariant.downPaymentPrice! > 0
        let downPaymentPrice = firstVariant.downPaymentPrice ?? 0
        let hasEarnestMoney = firstVariant.earnestMoneyPrice != nil && firstVariant.earnestMoneyPrice! > 0
        let earnestMoneyPrice = firstVariant.earnestMoneyPrice ?? 0
        
        self.modelAction?.updateBookMethod(
            downPayment: hasDownPayment,
            downPaymentPrice: downPaymentPrice,
            earnestMoney: hasEarnestMoney,
            earnestMoneyPrice: earnestMoneyPrice,
            purchaseDenefitsIntro: ""
        )
        
        if hasDownPayment {
            self.modelAction?.updateSelectOrderPersonType(orderPersonType: 1)
            self.modelAction?.updateSelectPurchasePlan(purchasePlan: 1)
        }
        
        var configName: [String: String] = [:]
        var configPrice: [String: Decimal] = [:]
        configName["BASE_MODEL"] = firstModel.modelName
        configPrice["BASE_MODEL"] = firstVariant.variantPrice
        
        for family in firstVariant.selectableFamilies {
            if let selectedCode = saleModelConfigType[family.optionFamilyCode],
               let selectedOption = family.options.first(where: { $0.optionCode == selectedCode }) {
                configName[family.optionFamilyCode] = selectedOption.optionName
                configPrice[family.optionFamilyCode] = selectedOption.price
            }
        }
        
        let dynamicConfigs = self.convertToDynamicConfigs(
            configName: configName,
            configPrice: configPrice
        )
        self.modelAction?.updateDynamicConfigs(dynamicConfigs)
    }
    
    private func extractSelectedOptionCodes(from variant: ConfiguratorResult.VariantItem?, saleModelConfigType: [String: String]) -> [String] {
        var optionCodes: [String] = []
        if let variant = variant {
            for family in variant.selectableFamilies {
                if let selectedCode = saleModelConfigType[family.optionFamilyCode] {
                    optionCodes.append(selectedCode)
                }
            }
        } else {
            // 如果没有variant，直接从saleModelConfigType中提取所有值作为optionCodes
            for (_, value) in saleModelConfigType {
                optionCodes.append(value)
            }
        }
        return optionCodes
    }
    private func handleEarnestMoneyUnpaid() {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            ServiceContainer.marketingService.getOrder(orderNo: orderNum) { (result: Result<TspResponse<Order>, Error>) in
                switch result {
                case .success(let res):
                    guard let orderResponse = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: orderResponse.saleModelImages ?? [])
                    let displayName = orderResponse.variantName ?? orderResponse.modelName ?? ""
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: displayName,
                        saleModelDesc: orderResponse.saleModelDesc ?? ""
                    )
                    let optionTotalPrice = orderResponse.optionBreakdown?.compactMap({ $0.optionPrice }).reduce(0, +) ?? 0
                    let basePrice = (orderResponse.totalPrice ?? 0) - optionTotalPrice
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: displayName,
                        saleModelPrice: basePrice,
                        totalPrice: orderResponse.totalPrice ?? 0
                    )
                    let dynamicConfigs = self.convertOptionBreakdownToDynamicConfigs(orderResponse.optionBreakdown)
                    self.modelAction?.updateDynamicConfigs(dynamicConfigs)
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNo,
                        orderTime: orderResponse.orderTime ?? 0
                    )
                    
                    if let modelCode = orderResponse.modelCode, let variantCode = orderResponse.variantCode {
                        AppGlobalState.shared.parameters["selectedModelCode"] = modelCode
                        AppGlobalState.shared.parameters["selectedVariantCode"] = variantCode
                        self.modelAction?.displayEarnestMoneyUnpaid()
                    } else if let saleModelCode = orderResponse.saleModelCode {
                        let regionCode = orderResponse.licenseCityCode ?? ""
                        ServiceContainer.marketingService.getConfigurator(saleModelCode: saleModelCode, regionCode: regionCode) { [weak self] (configuratorResult: Result<TspResponse<ConfiguratorResult>, Error>) in
                            switch configuratorResult {
                            case .success(let configuratorRes):
                                if let configurator = configuratorRes.data,
                                   let firstModel = configurator.models.first,
                                   let firstVariant = firstModel.variants.first {
                                    AppGlobalState.shared.parameters["selectedModelCode"] = firstModel.modelCode
                                    AppGlobalState.shared.parameters["selectedVariantCode"] = firstVariant.variantCode
                                }
                            case .failure(_):
                                break
                            }
                            self?.modelAction?.displayEarnestMoneyUnpaid()
                        }
                    } else {
                        self.modelAction?.displayEarnestMoneyUnpaid()
                    }
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    private func handleEarnestMoneyPaid() {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            ServiceContainer.marketingService.getOrder(orderNo: orderNum) { (result: Result<TspResponse<Order>, Error>) in
                switch result {
                case .success(let res):
                    guard let orderResponse = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: orderResponse.saleModelImages ?? [])
                    let displayName = orderResponse.variantName ?? orderResponse.modelName ?? ""
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: displayName,
                        saleModelDesc: orderResponse.saleModelDesc ?? ""
                    )
                    let optionTotalPrice = orderResponse.optionBreakdown?.compactMap({ $0.optionPrice }).reduce(0, +) ?? 0
                    let basePrice = (orderResponse.totalPrice ?? 0) - optionTotalPrice
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: displayName,
                        saleModelPrice: basePrice,
                        totalPrice: orderResponse.totalPrice ?? 0
                    )
                    let dynamicConfigs = self.convertOptionBreakdownToDynamicConfigs(orderResponse.optionBreakdown)
                    self.modelAction?.updateDynamicConfigs(dynamicConfigs)
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNo,
                        orderTime: orderResponse.orderTime ?? 0
                    )
                    self.modelAction?.updateLicenseCity(
                        code: orderResponse.licenseCityCode ?? "",
                        name: orderResponse.licenseCityName ?? ""
                    )
                    
                    if let modelCode = orderResponse.modelCode, let variantCode = orderResponse.variantCode {
                        AppGlobalState.shared.parameters["selectedModelCode"] = modelCode
                        AppGlobalState.shared.parameters["selectedVariantCode"] = variantCode
                        self.modelAction?.displayEarnestMoneyPaid()
                    } else if let saleModelCode = orderResponse.saleModelCode {
                        let regionCode = orderResponse.licenseCityCode ?? ""
                        ServiceContainer.marketingService.getConfigurator(saleModelCode: saleModelCode, regionCode: regionCode) { [weak self] (configuratorResult: Result<TspResponse<ConfiguratorResult>, Error>) in
                            switch configuratorResult {
                            case .success(let configuratorRes):
                                if let configurator = configuratorRes.data,
                                   let firstModel = configurator.models.first,
                                   let firstVariant = firstModel.variants.first {
                                    AppGlobalState.shared.parameters["selectedModelCode"] = firstModel.modelCode
                                    AppGlobalState.shared.parameters["selectedVariantCode"] = firstVariant.variantCode
                                }
                            case .failure(_):
                                break
                            }
                            self?.modelAction?.displayEarnestMoneyPaid()
                        }
                    } else {
                        self.modelAction?.displayEarnestMoneyPaid()
                    }
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    private func handleDownPaymentUnpaidFromEarnestMoneyPaid() {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            modelAction?.displayLoading()
            ServiceContainer.marketingService.getOrder(orderNo: orderNum) { (result: Result<TspResponse<Order>, Error>) in
                switch result {
                case .success(let res):
                    guard let orderResponse = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: orderResponse.saleModelImages ?? [])
                    let displayName = orderResponse.variantName ?? orderResponse.modelName ?? ""
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: displayName,
                        saleModelDesc: orderResponse.saleModelDesc ?? ""
                    )
                    let optionTotalPrice = orderResponse.optionBreakdown?.compactMap({ $0.optionPrice }).reduce(0, +) ?? 0
                    let basePrice = (orderResponse.totalPrice ?? 0) - optionTotalPrice
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: displayName,
                        saleModelPrice: basePrice,
                        totalPrice: orderResponse.totalPrice ?? 0
                    )
                    let dynamicConfigs = self.convertOptionBreakdownToDynamicConfigs(orderResponse.optionBreakdown)
                    self.modelAction?.updateDynamicConfigs(dynamicConfigs)
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNo,
                        orderTime: orderResponse.orderTime ?? 0
                    )
                    self.modelAction?.updateOrderPerson(
                        orderPersonType: 1,
                        orderPersonName: "",
                        orderPersonIdType: 1,
                        orderPersonIdNum: ""
                    )
                    self.modelAction?.updatePurchasePlan(purchasePlan: 1)
                    self.modelAction?.updateLicenseCity(
                        code: orderResponse.licenseCityCode ?? "",
                        name: orderResponse.licenseCityName ?? ""
                    )
                    self.modelAction?.updateDealership(
                        code: "",
                        name: ""
                    )
                    self.modelAction?.updateDeliveryCenter(
                        code: "",
                        name: ""
                    )
                    self.modelAction?.setIsFromEarnestMoneyConversion(isFrom: true)
                    
                    if let modelCode = orderResponse.modelCode, let variantCode = orderResponse.variantCode {
                        AppGlobalState.shared.parameters["selectedModelCode"] = modelCode
                        AppGlobalState.shared.parameters["selectedVariantCode"] = variantCode
                        self.modelAction?.displayDownPaymentUnpaid()
                    } else if let saleModelCode = orderResponse.saleModelCode {
                        let regionCode = orderResponse.licenseCityCode ?? ""
                        ServiceContainer.marketingService.getConfigurator(saleModelCode: saleModelCode, regionCode: regionCode) { [weak self] (configuratorResult: Result<TspResponse<ConfiguratorResult>, Error>) in
                            switch configuratorResult {
                            case .success(let configuratorRes):
                                if let configurator = configuratorRes.data,
                                   let firstModel = configurator.models.first,
                                   let firstVariant = firstModel.variants.first {
                                    AppGlobalState.shared.parameters["selectedModelCode"] = firstModel.modelCode
                                    AppGlobalState.shared.parameters["selectedVariantCode"] = firstVariant.variantCode
                                }
                            case .failure(_):
                                break
                            }
                            self?.modelAction?.displayDownPaymentUnpaid()
                        }
                    } else {
                        self.modelAction?.displayDownPaymentUnpaid()
                    }
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    private func handleDownPaymentUnpaid() {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            ServiceContainer.marketingService.getOrder(orderNo: orderNum) { (result: Result<TspResponse<Order>, Error>) in
                switch result {
                case .success(let res):
                    guard let orderResponse = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: orderResponse.saleModelImages ?? [])
                    let displayName = orderResponse.variantName ?? orderResponse.modelName ?? ""
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: displayName,
                        saleModelDesc: orderResponse.saleModelDesc ?? ""
                    )
                    let optionTotalPrice = orderResponse.optionBreakdown?.compactMap({ $0.optionPrice }).reduce(0, +) ?? 0
                    let basePrice = (orderResponse.totalPrice ?? 0) - optionTotalPrice
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: displayName,
                        saleModelPrice: basePrice,
                        totalPrice: orderResponse.totalPrice ?? 0
                    )
                    let dynamicConfigs = self.convertOptionBreakdownToDynamicConfigs(orderResponse.optionBreakdown)
                    self.modelAction?.updateDynamicConfigs(dynamicConfigs)
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNo,
                        orderTime: orderResponse.orderTime ?? 0
                    )
                    self.modelAction?.updateOrderPerson(
                        orderPersonType: orderResponse.orderPersonType ?? 1,
                        orderPersonName: orderResponse.orderPersonName ?? "",
                        orderPersonIdType: orderResponse.orderPersonIdType ?? 0,
                        orderPersonIdNum: orderResponse.orderPersonIdNum ?? ""
                    )
                    self.modelAction?.updatePurchasePlan(purchasePlan: orderResponse.purchasePlan ?? 1)
                    self.modelAction?.updateLicenseCity(
                        code: orderResponse.licenseCityCode ?? "",
                        name: orderResponse.licenseCityName ?? ""
                    )
                    self.modelAction?.updateDealership(
                        code: orderResponse.dealershipCode ?? "",
                        name: orderResponse.dealershipName ?? ""
                    )
                    self.modelAction?.updateDeliveryCenter(
                        code: orderResponse.deliveryCenterCode ?? "",
                        name: orderResponse.deliveryCenterName ?? ""
                    )
                    self.modelAction?.setIsFromEarnestMoneyConversion(isFrom: false)
                    
                    if let modelCode = orderResponse.modelCode, let variantCode = orderResponse.variantCode {
                        AppGlobalState.shared.parameters["selectedModelCode"] = modelCode
                        AppGlobalState.shared.parameters["selectedVariantCode"] = variantCode
                        self.modelAction?.displayDownPaymentUnpaid()
                    } else if let saleModelCode = orderResponse.saleModelCode {
                        let regionCode = orderResponse.licenseCityCode ?? ""
                        ServiceContainer.marketingService.getConfigurator(saleModelCode: saleModelCode, regionCode: regionCode) { [weak self] (configuratorResult: Result<TspResponse<ConfiguratorResult>, Error>) in
                            switch configuratorResult {
                            case .success(let configuratorRes):
                                if let configurator = configuratorRes.data,
                                   let firstModel = configurator.models.first,
                                   let firstVariant = firstModel.variants.first {
                                    AppGlobalState.shared.parameters["selectedModelCode"] = firstModel.modelCode
                                    AppGlobalState.shared.parameters["selectedVariantCode"] = firstVariant.variantCode
                                }
                            case .failure(_):
                                break
                            }
                            self?.modelAction?.displayDownPaymentUnpaid()
                        }
                    } else {
                        self.modelAction?.displayDownPaymentUnpaid()
                    }
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    private func handleDownPaymentPaid() {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            ServiceContainer.marketingService.getOrder(orderNo: orderNum) { (result: Result<TspResponse<Order>, Error>) in
                switch result {
                case .success(let res):
                    guard let orderResponse = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: orderResponse.saleModelImages ?? [])
                    let displayName = orderResponse.variantName ?? orderResponse.modelName ?? ""
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: displayName,
                        saleModelDesc: orderResponse.saleModelDesc ?? ""
                    )
                    let optionTotalPrice = orderResponse.optionBreakdown?.compactMap({ $0.optionPrice }).reduce(0, +) ?? 0
                    let basePrice = (orderResponse.totalPrice ?? 0) - optionTotalPrice
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: displayName,
                        saleModelPrice: basePrice,
                        totalPrice: orderResponse.totalPrice ?? 0
                    )
                    let dynamicConfigs = self.convertOptionBreakdownToDynamicConfigs(orderResponse.optionBreakdown)
                    self.modelAction?.updateDynamicConfigs(dynamicConfigs)
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNo,
                        orderTime: orderResponse.orderTime ?? 0
                    )
                    let orderPersonType = orderResponse.orderPersonType ?? (orderResponse.customerType == "personal" ? 1 : 2)
                    let purchasePlan = orderResponse.purchasePlan ?? (orderResponse.paymentMethod == "full_payment" ? 1 : 2)
                    self.modelAction?.updateOrderPerson(
                        orderPersonType: orderPersonType,
                        orderPersonName: orderResponse.orderPersonName ?? "",
                        orderPersonIdType: orderResponse.orderPersonIdType ?? 1,
                        orderPersonIdNum: orderResponse.orderPersonIdNum ?? ""
                    )
                    self.modelAction?.updatePurchasePlan(purchasePlan: purchasePlan)
                    self.modelAction?.updateLicenseCity(
                        code: orderResponse.licenseCityCode ?? "",
                        name: orderResponse.licenseCityName ?? ""
                    )
                    let dealershipCode = orderResponse.orderStoreCode ?? orderResponse.dealershipCode ?? ""
                    let dealershipName = orderResponse.orderStoreName ?? orderResponse.dealershipName ?? ""
                    self.modelAction?.updateDealership(code: dealershipCode, name: dealershipName)
                    let deliveryCode = orderResponse.deliveryStoreCode ?? orderResponse.deliveryCenterCode ?? ""
                    let deliveryName = orderResponse.deliveryStoreName ?? orderResponse.deliveryCenterName ?? ""
                    self.modelAction?.updateDeliveryCenter(code: deliveryCode, name: deliveryName)
                    
                    if let modelCode = orderResponse.modelCode, let variantCode = orderResponse.variantCode {
                        AppGlobalState.shared.parameters["selectedModelCode"] = modelCode
                        AppGlobalState.shared.parameters["selectedVariantCode"] = variantCode
                        self.modelAction?.displayDownPaymentPaid()
                    } else if let saleModelCode = orderResponse.saleModelCode {
                        let regionCode = orderResponse.licenseCityCode ?? ""
                        ServiceContainer.marketingService.getConfigurator(saleModelCode: saleModelCode, regionCode: regionCode) { [weak self] (configuratorResult: Result<TspResponse<ConfiguratorResult>, Error>) in
                            switch configuratorResult {
                            case .success(let configuratorRes):
                                if let configurator = configuratorRes.data,
                                   let firstModel = configurator.models.first,
                                   let firstVariant = firstModel.variants.first {
                                    AppGlobalState.shared.parameters["selectedModelCode"] = firstModel.modelCode
                                    AppGlobalState.shared.parameters["selectedVariantCode"] = firstVariant.variantCode
                                }
                            case .failure(_):
                                break
                            }
                            self?.modelAction?.displayDownPaymentPaid()
                        }
                    } else {
                        self.modelAction?.displayDownPaymentPaid()
                    }
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    private func handleArrangeProduction() {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            ServiceContainer.marketingService.getOrder(orderNo: orderNum) { (result: Result<TspResponse<Order>, Error>) in
                switch result {
                case .success(let res):
                    guard let orderResponse = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: orderResponse.saleModelImages ?? [])
                    let displayName = orderResponse.variantName ?? orderResponse.modelName ?? ""
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: displayName,
                        saleModelDesc: orderResponse.saleModelDesc ?? ""
                    )
                    let optionTotalPrice = orderResponse.optionBreakdown?.compactMap({ $0.optionPrice }).reduce(0, +) ?? 0
                    let basePrice = (orderResponse.totalPrice ?? 0) - optionTotalPrice
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: displayName,
                        saleModelPrice: basePrice,
                        totalPrice: orderResponse.totalPrice ?? 0
                    )
                    let dynamicConfigs = self.convertOptionBreakdownToDynamicConfigs(orderResponse.optionBreakdown)
                    self.modelAction?.updateDynamicConfigs(dynamicConfigs)
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNo,
                        orderTime: orderResponse.orderTime ?? 0
                    )
                    let orderPersonType = orderResponse.orderPersonType ?? (orderResponse.customerType == "personal" ? 1 : 2)
                    let purchasePlan = orderResponse.purchasePlan ?? (orderResponse.paymentMethod == "full_payment" ? 1 : 2)
                    self.modelAction?.updateOrderPerson(
                        orderPersonType: orderPersonType,
                        orderPersonName: orderResponse.orderPersonName ?? "",
                        orderPersonIdType: orderResponse.orderPersonIdType ?? 1,
                        orderPersonIdNum: orderResponse.orderPersonIdNum ?? ""
                    )
                    self.modelAction?.updatePurchasePlan(purchasePlan: purchasePlan)
                    self.modelAction?.updateLicenseCity(
                        code: orderResponse.licenseCityCode ?? "",
                        name: orderResponse.licenseCityName ?? ""
                    )
                    let dealershipCode = orderResponse.orderStoreCode ?? orderResponse.dealershipCode ?? ""
                    let dealershipName = orderResponse.orderStoreName ?? orderResponse.dealershipName ?? ""
                    self.modelAction?.updateDealership(code: dealershipCode, name: dealershipName)
                    let deliveryCode = orderResponse.deliveryStoreCode ?? orderResponse.deliveryCenterCode ?? ""
                    let deliveryName = orderResponse.deliveryStoreName ?? orderResponse.deliveryCenterName ?? ""
                    self.modelAction?.updateDeliveryCenter(code: deliveryCode, name: deliveryName)
                    
                    if let modelCode = orderResponse.modelCode, let variantCode = orderResponse.variantCode {
                        AppGlobalState.shared.parameters["selectedModelCode"] = modelCode
                        AppGlobalState.shared.parameters["selectedVariantCode"] = variantCode
                        self.modelAction?.displayArrangeProduction()
                    } else if let saleModelCode = orderResponse.saleModelCode {
                        let regionCode = orderResponse.licenseCityCode ?? ""
                        ServiceContainer.marketingService.getConfigurator(saleModelCode: saleModelCode, regionCode: regionCode) { [weak self] (configuratorResult: Result<TspResponse<ConfiguratorResult>, Error>) in
                            switch configuratorResult {
                            case .success(let configuratorRes):
                                if let configurator = configuratorRes.data,
                                   let firstModel = configurator.models.first,
                                   let firstVariant = firstModel.variants.first {
                                    AppGlobalState.shared.parameters["selectedModelCode"] = firstModel.modelCode
                                    AppGlobalState.shared.parameters["selectedVariantCode"] = firstVariant.variantCode
                                }
                            case .failure(_):
                                break
                            }
                            self?.modelAction?.displayArrangeProduction()
                        }
                    } else {
                        self.modelAction?.displayArrangeProduction()
                    }
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    private func handleAllocationVehicle() {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            ServiceContainer.marketingService.getOrder(orderNo: orderNum) { (result: Result<TspResponse<Order>, Error>) in
                switch result {
                case .success(let res):
                    guard let orderResponse = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: orderResponse.saleModelImages ?? [])
                    let displayName = orderResponse.variantName ?? orderResponse.modelName ?? ""
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: displayName,
                        saleModelDesc: orderResponse.saleModelDesc ?? ""
                    )
                    let optionTotalPrice = orderResponse.optionBreakdown?.compactMap({ $0.optionPrice }).reduce(0, +) ?? 0
                    let basePrice = (orderResponse.totalPrice ?? 0) - optionTotalPrice
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: displayName,
                        saleModelPrice: basePrice,
                        totalPrice: orderResponse.totalPrice ?? 0
                    )
                    let dynamicConfigs = self.convertOptionBreakdownToDynamicConfigs(orderResponse.optionBreakdown)
                    self.modelAction?.updateDynamicConfigs(dynamicConfigs)
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNo,
                        orderTime: orderResponse.orderTime ?? 0
                    )
                    
                    // 从configurator获取modelCode和variantCode
                    if let modelCode = orderResponse.modelCode, let variantCode = orderResponse.variantCode {
                        AppGlobalState.shared.parameters["selectedModelCode"] = modelCode
                        AppGlobalState.shared.parameters["selectedVariantCode"] = variantCode
                        self.modelAction?.displayAllocationVehicle()
                    } else if let saleModelCode = orderResponse.saleModelCode {
                        let regionCode = orderResponse.licenseCityCode ?? ""
                        ServiceContainer.marketingService.getConfigurator(saleModelCode: saleModelCode, regionCode: regionCode) { [weak self] (configuratorResult: Result<TspResponse<ConfiguratorResult>, Error>) in
                            switch configuratorResult {
                            case .success(let configuratorRes):
                                if let configurator = configuratorRes.data,
                                   let firstModel = configurator.models.first,
                                   let firstVariant = firstModel.variants.first {
                                    AppGlobalState.shared.parameters["selectedModelCode"] = firstModel.modelCode
                                    AppGlobalState.shared.parameters["selectedVariantCode"] = firstVariant.variantCode
                                }
                            case .failure(_):
                                break
                            }
                            self?.modelAction?.displayAllocationVehicle()
                        }
                    } else {
                        self.modelAction?.displayAllocationVehicle()
                    }
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    private func handlePrepareTransport() {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            ServiceContainer.marketingService.getOrder(orderNo: orderNum) { (result: Result<TspResponse<Order>, Error>) in
                switch result {
                case .success(let res):
                    guard let orderResponse = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: orderResponse.saleModelImages ?? [])
                    let displayName = orderResponse.variantName ?? orderResponse.modelName ?? ""
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: displayName,
                        saleModelDesc: orderResponse.saleModelDesc ?? ""
                    )
                    let optionTotalPrice = orderResponse.optionBreakdown?.compactMap({ $0.optionPrice }).reduce(0, +) ?? 0
                    let basePrice = (orderResponse.totalPrice ?? 0) - optionTotalPrice
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: displayName,
                        saleModelPrice: basePrice,
                        totalPrice: orderResponse.totalPrice ?? 0
                    )
                    let dynamicConfigs = self.convertOptionBreakdownToDynamicConfigs(orderResponse.optionBreakdown)
                    self.modelAction?.updateDynamicConfigs(dynamicConfigs)
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNo,
                        orderTime: orderResponse.orderTime ?? 0
                    )
                    
                    if let modelCode = orderResponse.modelCode, let variantCode = orderResponse.variantCode {
                        AppGlobalState.shared.parameters["selectedModelCode"] = modelCode
                        AppGlobalState.shared.parameters["selectedVariantCode"] = variantCode
                        self.modelAction?.displayPrepareTransport()
                    } else if let saleModelCode = orderResponse.saleModelCode {
                        let regionCode = orderResponse.licenseCityCode ?? ""
                        ServiceContainer.marketingService.getConfigurator(saleModelCode: saleModelCode, regionCode: regionCode) { [weak self] (configuratorResult: Result<TspResponse<ConfiguratorResult>, Error>) in
                            switch configuratorResult {
                            case .success(let configuratorRes):
                                if let configurator = configuratorRes.data,
                                   let firstModel = configurator.models.first,
                                   let firstVariant = firstModel.variants.first {
                                    AppGlobalState.shared.parameters["selectedModelCode"] = firstModel.modelCode
                                    AppGlobalState.shared.parameters["selectedVariantCode"] = firstVariant.variantCode
                                }
                            case .failure(_):
                                break
                            }
                            self?.modelAction?.displayPrepareTransport()
                        }
                    } else {
                        self.modelAction?.displayPrepareTransport()
                    }
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    private func handlePrepareDeliver() {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            ServiceContainer.marketingService.getOrder(orderNo: orderNum) { (result: Result<TspResponse<Order>, Error>) in
                switch result {
                case .success(let res):
                    guard let orderResponse = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: orderResponse.saleModelImages ?? [])
                    let displayName = orderResponse.variantName ?? orderResponse.modelName ?? ""
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: displayName,
                        saleModelDesc: orderResponse.saleModelDesc ?? ""
                    )
                    let optionTotalPrice = orderResponse.optionBreakdown?.compactMap({ $0.optionPrice }).reduce(0, +) ?? 0
                    let basePrice = (orderResponse.totalPrice ?? 0) - optionTotalPrice
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: displayName,
                        saleModelPrice: basePrice,
                        totalPrice: orderResponse.totalPrice ?? 0
                    )
                    let dynamicConfigs = self.convertOptionBreakdownToDynamicConfigs(orderResponse.optionBreakdown)
                    self.modelAction?.updateDynamicConfigs(dynamicConfigs)
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNo,
                        orderTime: orderResponse.orderTime ?? 0
                    )
                    // 购车合同与尾款以服务端为唯一事实源（OTD-VSO-DSN-CR-014）
                    self.modelAction?.updateOrderState(orderState: orderResponse.orderState,
                                                       paymentMethod: orderResponse.paymentMethod)
                    self.modelAction?.updateTailPaymentAmount(orderResponse.tailPaymentAmount ?? 0)
                    self.loadContract(orderNo: orderResponse.orderNo)
                    
                    if let modelCode = orderResponse.modelCode, let variantCode = orderResponse.variantCode {
                        AppGlobalState.shared.parameters["selectedModelCode"] = modelCode
                        AppGlobalState.shared.parameters["selectedVariantCode"] = variantCode
                        self.modelAction?.displayPrepareDeliver()
                    } else if let saleModelCode = orderResponse.saleModelCode {
                        let regionCode = orderResponse.licenseCityCode ?? ""
                        ServiceContainer.marketingService.getConfigurator(saleModelCode: saleModelCode, regionCode: regionCode) { [weak self] (configuratorResult: Result<TspResponse<ConfiguratorResult>, Error>) in
                            switch configuratorResult {
                            case .success(let configuratorRes):
                                if let configurator = configuratorRes.data,
                                   let firstModel = configurator.models.first,
                                   let firstVariant = firstModel.variants.first {
                                    AppGlobalState.shared.parameters["selectedModelCode"] = firstModel.modelCode
                                    AppGlobalState.shared.parameters["selectedVariantCode"] = firstVariant.variantCode
                                }
                            case .failure(_):
                                break
                            }
                            self?.modelAction?.displayPrepareDeliver()
                        }
                    } else {
                        self.modelAction?.displayPrepareDeliver()
                    }
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    private func handleFinalPaymentPaid() {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            ServiceContainer.marketingService.getOrder(orderNo: orderNum) { (result: Result<TspResponse<Order>, Error>) in
                switch result {
                case .success(let res):
                    guard let orderResponse = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: orderResponse.saleModelImages ?? [])
                    let displayName = orderResponse.variantName ?? orderResponse.modelName ?? ""
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: displayName,
                        saleModelDesc: orderResponse.saleModelDesc ?? ""
                    )
                    let optionTotalPrice = orderResponse.optionBreakdown?.compactMap({ $0.optionPrice }).reduce(0, +) ?? 0
                    let basePrice = (orderResponse.totalPrice ?? 0) - optionTotalPrice
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: displayName,
                        saleModelPrice: basePrice,
                        totalPrice: orderResponse.totalPrice ?? 0
                    )
                    let dynamicConfigs = self.convertOptionBreakdownToDynamicConfigs(orderResponse.optionBreakdown)
                    self.modelAction?.updateDynamicConfigs(dynamicConfigs)
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNo,
                        orderTime: orderResponse.orderTime ?? 0
                    )
                    
                    if let modelCode = orderResponse.modelCode, let variantCode = orderResponse.variantCode {
                        AppGlobalState.shared.parameters["selectedModelCode"] = modelCode
                        AppGlobalState.shared.parameters["selectedVariantCode"] = variantCode
                        self.modelAction?.displayFinalPaymentPaid()
                    } else if let saleModelCode = orderResponse.saleModelCode {
                        let regionCode = orderResponse.licenseCityCode ?? ""
                        ServiceContainer.marketingService.getConfigurator(saleModelCode: saleModelCode, regionCode: regionCode) { [weak self] (configuratorResult: Result<TspResponse<ConfiguratorResult>, Error>) in
                            switch configuratorResult {
                            case .success(let configuratorRes):
                                if let configurator = configuratorRes.data,
                                   let firstModel = configurator.models.first,
                                   let firstVariant = firstModel.variants.first {
                                    AppGlobalState.shared.parameters["selectedModelCode"] = firstModel.modelCode
                                    AppGlobalState.shared.parameters["selectedVariantCode"] = firstVariant.variantCode
                                }
                            case .failure(_):
                                break
                            }
                            self?.modelAction?.displayFinalPaymentPaid()
                        }
                    } else {
                        self.modelAction?.displayFinalPaymentPaid()
                    }
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    private func handleInvoiced() {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            ServiceContainer.marketingService.getOrder(orderNo: orderNum) { (result: Result<TspResponse<Order>, Error>) in
                switch result {
                case .success(let res):
                    guard let orderResponse = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: orderResponse.saleModelImages ?? [])
                    let displayName = orderResponse.variantName ?? orderResponse.modelName ?? ""
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: displayName,
                        saleModelDesc: orderResponse.saleModelDesc ?? ""
                    )
                    let optionTotalPrice = orderResponse.optionBreakdown?.compactMap({ $0.optionPrice }).reduce(0, +) ?? 0
                    let basePrice = (orderResponse.totalPrice ?? 0) - optionTotalPrice
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: displayName,
                        saleModelPrice: basePrice,
                        totalPrice: orderResponse.totalPrice ?? 0
                    )
                    let dynamicConfigs = self.convertOptionBreakdownToDynamicConfigs(orderResponse.optionBreakdown)
                    self.modelAction?.updateDynamicConfigs(dynamicConfigs)
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNo,
                        orderTime: orderResponse.orderTime ?? 0
                    )
                    
                    if let modelCode = orderResponse.modelCode, let variantCode = orderResponse.variantCode {
                        AppGlobalState.shared.parameters["selectedModelCode"] = modelCode
                        AppGlobalState.shared.parameters["selectedVariantCode"] = variantCode
                        self.modelAction?.displayInvoiced()
                    } else if let saleModelCode = orderResponse.saleModelCode {
                        let regionCode = orderResponse.licenseCityCode ?? ""
                        ServiceContainer.marketingService.getConfigurator(saleModelCode: saleModelCode, regionCode: regionCode) { [weak self] (configuratorResult: Result<TspResponse<ConfiguratorResult>, Error>) in
                            switch configuratorResult {
                            case .success(let configuratorRes):
                                if let configurator = configuratorRes.data,
                                   let firstModel = configurator.models.first,
                                   let firstVariant = firstModel.variants.first {
                                    AppGlobalState.shared.parameters["selectedModelCode"] = firstModel.modelCode
                                    AppGlobalState.shared.parameters["selectedVariantCode"] = firstVariant.variantCode
                                }
                            case .failure(_):
                                break
                            }
                            self?.modelAction?.displayInvoiced()
                        }
                    } else {
                        self.modelAction?.displayInvoiced()
                    }
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    private func handleDelivered() {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            ServiceContainer.marketingService.getOrder(orderNo: orderNum) { (result: Result<TspResponse<Order>, Error>) in
                switch result {
                case .success(let res):
                    guard let orderResponse = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: orderResponse.saleModelImages ?? [])
                    let displayName = orderResponse.variantName ?? orderResponse.modelName ?? ""
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: displayName,
                        saleModelDesc: orderResponse.saleModelDesc ?? ""
                    )
                    let optionTotalPrice = orderResponse.optionBreakdown?.compactMap({ $0.optionPrice }).reduce(0, +) ?? 0
                    let basePrice = (orderResponse.totalPrice ?? 0) - optionTotalPrice
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: displayName,
                        saleModelPrice: basePrice,
                        totalPrice: orderResponse.totalPrice ?? 0
                    )
                    let dynamicConfigs = self.convertOptionBreakdownToDynamicConfigs(orderResponse.optionBreakdown)
                    self.modelAction?.updateDynamicConfigs(dynamicConfigs)
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNo,
                        orderTime: orderResponse.orderTime ?? 0
                    )
                    
                    if let modelCode = orderResponse.modelCode, let variantCode = orderResponse.variantCode {
                        AppGlobalState.shared.parameters["selectedModelCode"] = modelCode
                        AppGlobalState.shared.parameters["selectedVariantCode"] = variantCode
                        self.modelAction?.displayDelivered()
                    } else if let saleModelCode = orderResponse.saleModelCode {
                        let regionCode = orderResponse.licenseCityCode ?? ""
                        ServiceContainer.marketingService.getConfigurator(saleModelCode: saleModelCode, regionCode: regionCode) { [weak self] (configuratorResult: Result<TspResponse<ConfiguratorResult>, Error>) in
                            switch configuratorResult {
                            case .success(let configuratorRes):
                                if let configurator = configuratorRes.data,
                                   let firstModel = configurator.models.first,
                                   let firstVariant = firstModel.variants.first {
                                    AppGlobalState.shared.parameters["selectedModelCode"] = firstModel.modelCode
                                    AppGlobalState.shared.parameters["selectedVariantCode"] = firstVariant.variantCode
                                }
                            case .failure(_):
                                break
                            }
                            self?.modelAction?.displayDelivered()
                        }
                    } else {
                        self.modelAction?.displayDelivered()
                    }
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
}

extension VehicleOrderDetailIntent: VehicleOrderDetailIntentProtocol {
    func onTapDelete() {
        if let vehiclePo = VehicleManager.shared.getCurrentVehicle() {
            if vehiclePo.type == .WISHLIST {
                ServiceContainer.marketingService.deleteWishlist(wishlistId: vehiclePo.id) { (result: Result<TspResponse<NoReply>, Error>) in
                    switch result {
                    case .success(let res):
                        if res.isSuccess {
                            VehicleManager.shared.delete(orderNum: vehiclePo.id)
                            DispatchQueue.main.async {
                                AppRouter.shared.pop()
                            }
                        } else {
                            self.modelAction?.displayError(text: res.message ?? "请求异常")
                        }
                    case .failure(_):
                        self.modelAction?.displayError(text: "请求异常")
                    }
                }
            }
            if vehiclePo.type == .ORDER {
                VehicleManager.shared.clear()
                AppRouter.shared.pop()
            }
        }
        
    }
    func onTapModifySaleModel() {
        if let vehiclePo = VehicleManager.shared.getCurrentVehicle() {
            modelAction?.displayLoading()
            ServiceContainer.marketingService.getWishlist(wishlistId: vehiclePo.id) { (result: Result<TspResponse<Wishlist>, Error>) in
                switch result {
                case .success(let res):
                    guard let wishlist = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    AppGlobalState.shared.parameters["saleModelCode"] = wishlist.saleModelCode
                    AppRouter.shared.push(.marketing(.modelConfig(saleModelCode: wishlist.saleModelCode ?? "")))
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        } else {
            self.modelAction?.displayError(text: "未找到当前车辆")
        }
    }
    func onTapOrder() {
        if let vehiclePo = VehicleManager.shared.getCurrentVehicle() {
            modelAction?.displayLoading()
            ServiceContainer.marketingService.getWishlist(wishlistId: vehiclePo.id) { (result: Result<TspResponse<Wishlist>, Error>) in
                switch result {
                case .success(let res):
                    guard let wishlist = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    
                    // 从 optionDetails 重建 saleModelConfigType 字典
                    var featureCodes: [String: String] = [:]
                    if let optionDetails = wishlist.optionDetails {
                        for option in optionDetails {
                            featureCodes[option.optionFamilyCode] = option.optionCode
                        }
                    }
                    
                    AppGlobalState.shared.parameters["saleModelCode"] = wishlist.saleModelCode
                    AppGlobalState.shared.parameters["saleModelConfigType"] = featureCodes
                    AppGlobalState.shared.parameters["orderDetailView"] = "ORDER"
                    AppGlobalState.shared.parameters["lastView"] = "ORDER_DETAIL"
                    self.viewOnAppear()
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    

    func onTapDownPaymentBookMethod() {
        self.modelAction?.updateSelectBookMethod(bookMethod: "downPayment")
        self.modelAction?.updateSelectOrderPersonType(orderPersonType: 1)
        self.modelAction?.updateSelectPurchasePlan(purchasePlan: 1)
    }
    func onTapEarnestMoneyBookMethod() {
        self.modelAction?.updateSelectBookMethod(bookMethod: "earnestMoney")
    }
    func onTapOrderPersonTypePerson() {
        self.modelAction?.updateSelectOrderPersonType(orderPersonType: 1)
    }
    func onTapOrderPersonTypeOrg() {
        self.modelAction?.updateSelectOrderPersonType(orderPersonType: 2)
    }
    func onTapPurchasePlanFullPayment() {
        self.modelAction?.updateSelectPurchasePlan(purchasePlan: 1)
    }
    func onTapPurchasePlanStaging() {
        self.modelAction?.updateSelectPurchasePlan(purchasePlan: 2)
    }
    func onTapAgreement() {
        self.modelAction?.toggleAgreement()
    }
    func onTapEarnestMoneyOrder(saleModelName: String, licenseCityCode: String) {
        modelAction?.displayLoading()
        let saleModelConfigType = AppGlobalState.shared.parameters["saleModelConfigType"] as? [String: String] ?? [:]
        let modelCode = AppGlobalState.shared.parameters["selectedModelCode"] as? String ?? ""
        let variantCode = AppGlobalState.shared.parameters["selectedVariantCode"] as? String ?? ""
        let savedOptionCodes = AppGlobalState.shared.parameters["optionCodes"] as? [String] ?? []
        let optionCodes = savedOptionCodes.isEmpty ? self.extractSelectedOptionCodes(from: nil, saleModelConfigType: saleModelConfigType) : savedOptionCodes
        ServiceContainer.marketingService.earnestMoneyOrder(
            saleModelCode: AppGlobalState.shared.parameters["saleModelCode"] as? String ?? "",
            modelCode: modelCode,
            variantCode: variantCode,
            orderNo: nil,
            optionCodes: optionCodes,
            licenseCityCode: licenseCityCode,
            agreementConfirmations: currentAgreementConfirmations()
        ) { [weak self] (result: Result<TspResponse<EarnestMoneyOrderResult>, Error>) in
            switch result {
            case .success(let res):
                guard let resData = res.data else {
                    self?.modelAction?.displayError(text: "请求异常")
                    return
                }
                VehicleManager.shared.add(orderNum: resData.orderNo, type: .ORDER, displayName: saleModelName)
                VehicleManager.shared.setCurrentVehicleId(id: resData.orderNo)
                
                let payInfo = EarnestMoneyPayInfo(from: resData)
                AppGlobalState.shared.parameters["earnestMoneyPayInfo"] = payInfo
                
                DispatchQueue.main.async {
                    AppRouter.shared.push(.marketing(.earnestMoneyPay))
                }
            case .failure(_):
                self?.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    func onTapDownPaymentOrder(orderPersonType: Int, purchasePlan: Int, orderPersonName: String, orderPersonIdType: Int, orderPersonIdNum: String, saleModelName: String, licenseCityCode: String, dealership: String, deliveryCenter: String) {
        modelAction?.displayLoading()
        var orderNo: String = ""
        if let id = VehicleManager.shared.getCurrentVehicleId() {
            orderNo = id
        }
        let saleModelConfigType = AppGlobalState.shared.parameters["saleModelConfigType"] as? [String: String] ?? [:]
        let modelCode = AppGlobalState.shared.parameters["selectedModelCode"] as? String ?? ""
        let variantCode = AppGlobalState.shared.parameters["selectedVariantCode"] as? String ?? ""
        let savedOptionCodes = AppGlobalState.shared.parameters["optionCodes"] as? [String] ?? []
        let optionCodes = savedOptionCodes.isEmpty ? self.extractSelectedOptionCodes(from: nil, saleModelConfigType: saleModelConfigType) : savedOptionCodes
        let customerType = "personal"
        let paymentMethod = purchasePlan == 1 ? "full_payment" : "loan"
        ServiceContainer.marketingService.downPaymentOrder(
            saleModelCode: AppGlobalState.shared.parameters["saleModelCode"] as? String ?? "",
            orderNo: orderNo,
            modelCode: modelCode,
            variantCode: variantCode,
            optionCodes: optionCodes,
            agreementConfirmations: orderNo.isEmpty ? currentAgreementConfirmations() : [],
            customerType: customerType,
            paymentMethod: paymentMethod,
            orderPersonType: orderPersonType,
            purchasePlan: purchasePlan,
            orderPersonName: orderPersonName,
            orderPersonIdType: orderPersonIdType,
            orderPersonIdNum: orderPersonIdNum,
            licenseCityCode: licenseCityCode,
            orderStoreCode: dealership,
            deliveryStoreCode: deliveryCenter
        ) { [weak self] (result: Result<TspResponse<DownPaymentOrderResult>, Error>) in
            switch result {
            case .success(let res):
                guard let resData = res.data else {
                    self?.modelAction?.displayError(text: "请求异常")
                    return
                }
                let newOrderNo = resData.orderNo ?? orderNo
                if !orderNo.isEmpty {
                    VehicleManager.shared.delete(orderNum: orderNo)
                }
                if !newOrderNo.isEmpty {
                    VehicleManager.shared.add(orderNum: newOrderNo, type: .ORDER, displayName: saleModelName)
                    VehicleManager.shared.setCurrentVehicleId(id: newOrderNo)
                }
                AppGlobalState.shared.needRefresh = true
                let lastView = AppGlobalState.shared.parameters["lastView"] as? String ?? ""
                if lastView == "MODEL_CONFIG" {
                    AppGlobalState.shared.parameters["backCount"] = 1
                }
                AppGlobalState.shared.parameters["licenseCityCode"] = nil
                AppGlobalState.shared.parameters["licenseCityName"] = nil
                AppGlobalState.shared.parameters["dealershipCode"] = nil
                AppGlobalState.shared.parameters["dealershipName"] = nil
                AppGlobalState.shared.parameters["deliveryCenterCode"] = nil
                AppGlobalState.shared.parameters["deliveryCenterName"] = nil
                
                let payInfo = DownPaymentPayInfo(
                    orderNo: newOrderNo.isEmpty ? nil : newOrderNo,
                    downPaymentAmount: resData.downPaymentAmount,
                    paymentChannels: resData.paymentChannels,
                    expireTime: resData.expireTime
                )
                AppGlobalState.shared.parameters["downPaymentPayInfo"] = payInfo
                
                DispatchQueue.main.async {
                    AppRouter.shared.push(.marketing(.downPaymentPay))
                }
            case .failure(_):
                self?.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    func onUpdateOrderPersonName(name: String) {
        modelAction?.updateOrderPersonName(name: name)
    }
    func onUpdateOrderPersonIdNum(idNum: String) {
        modelAction?.updateOrderPersonIdNum(idNum: idNum)
    }
    func onUpdateDealership(code: String, name: String) {
        modelAction?.updateDealership(code: code, name: name)
    }
    func onUpdateDeliveryCenter(code: String, name: String) {
        modelAction?.updateDeliveryCenter(code: code, name: name)
    }
    func onTapLicenseCity() {
        AppRouter.shared.push(.marketing(.licenseArea))
    }
    func onTapDealership() {
        AppRouter.shared.push(.marketing(.dealership))
    }
    func onTapDeliveryCenter() {
        AppRouter.shared.push(.marketing(.deliveryCenter))
    }
    func onTapCancelOrder() {
        if let orderNo = VehicleManager.shared.getCurrentVehicleId() {
            modelAction?.displayLoading()
            ServiceContainer.marketingService.cancelOrder(orderNo: orderNo) { (result: Result<TspResponse<NoReply>, Error>) in
                switch result {
                case .success(_):
                    VehicleManager.shared.delete(orderNum: orderNo)
                    DispatchQueue.main.async {
                        AppRouter.shared.pop()
                    }
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    func onTapPayOrder(orderPaymentPhase: Int, paymentAmount: Decimal, paymentChannel: String) {
        guard let orderNo = VehicleManager.shared.getCurrentVehicleId() else { return }
        modelAction?.displayLoading()

        // 后端仅支持意向金/定金两个支付阶段；尾款走独立入口（OTD-VSO-DSN-CR-014），
        // 金额与阶段由服务端判定，客户端不做本地状态推进。
        guard orderPaymentPhase == 1 || orderPaymentPhase == 2 else {
            onTapPayTailPayment()
            return
        }

        let stage: PaymentStageValue = orderPaymentPhase == 1 ? .earnestMoney : .downPayment
        PaymentFlowService.shared.pay(orderNo: orderNo, stage: stage, paymentChannel: paymentChannel) { [weak self] result in
            switch result {
            case .success:
                let nextSubState = orderPaymentPhase == 1 ? 210 : 310
                VehicleManager.shared.updateSubState(id: orderNo, subState: nextSubState)
                if let vehicle = VehicleManager.shared.getCurrentVehicle(), vehicle.type == .WISHLIST {
                    VehicleManager.shared.add(orderNum: orderNo, type: .ORDER, subState: nextSubState, displayName: vehicle.displayName)
                }
                AppGlobalState.shared.needRefresh = true
                self?.viewOnAppear()
            case .failure(let error):
                self?.modelAction?.displayError(text: error.localizedDescription)
            }
        }
    }

    // MARK: - 购车合同签署与尾款（OTD-VSO-DSN-CR-014）

    /// 发起合同签署：已签署直接刷新状态；SIGNING 时仅在 signUrl 可加载时打开签署页
    func onTapSignContract() {
        guard let orderNo = currentOrderNo() else {
            modelAction?.displayError(text: String(localized: "order_not_exist"))
            return
        }
        guard modelAction?.getCanSignContract() == true else { return }
        modelAction?.setContractBusy(true)
        ServiceContainer.marketingService.initiateContractSign(orderNo: orderNo) { [weak self] (result: Result<TspResponse<ContractInfo>, Error>) in
            guard let self = self else { return }
            self.modelAction?.setContractBusy(false)
            switch result {
            case .success(let res):
                guard res.isSuccess, let contract = res.data else {
                    self.modelAction?.displayError(text: res.message ?? String(localized: "sign_contract_failed"))
                    return
                }
                self.applyContract(contract)
                if contract.isSignEffective {
                    return
                }
                if contract.isSigning, let url = Self.loadableSignUrl(contract.signUrl) {
                    self.modelAction?.showContractWebPage(url: url)
                }
            case .failure(let error):
                self.modelAction?.displayError(text: error.localizedDescription)
            }
        }
    }

    /// 刷新合同签署状态（仅拉取事实，不代替用户签署）
    func onTapRefreshContract() {
        guard let orderNo = currentOrderNo() else { return }
        modelAction?.setContractBusy(true)
        ServiceContainer.marketingService.getContract(orderNo: orderNo) { [weak self] (result: Result<TspResponse<ContractInfo>, Error>) in
            guard let self = self else { return }
            self.modelAction?.setContractBusy(false)
            switch result {
            case .success(let res):
                if res.isSuccess, let contract = res.data {
                    self.applyContract(contract)
                } else if res.code == ContractErrorCode.notExist {
                    self.modelAction?.updateContract(status: nil, signUrl: nil, fileUrl: nil)
                } else {
                    self.modelAction?.displayError(text: res.message ?? String(localized: "sign_contract_failed"))
                }
            case .failure(let error):
                self.modelAction?.displayError(text: error.localizedDescription)
            }
        }
    }

    /// 支付尾款：请求不传金额/阶段，成功以服务端 orderState=620 为准
    func onTapPayTailPayment() {
        guard let orderNo = currentOrderNo() else { return }
        guard modelAction?.getCanPayTailPayment() == true else {
            modelAction?.displayError(text: String(localized: "tail_payment_sign_first"))
            return
        }
        modelAction?.setTailPaymentBusy(true)
        PaymentFlowService.shared.pay(orderNo: orderNo,
                                      stage: .tailPayment,
                                      paymentChannel: "ALIPAY") { [weak self] result in
            guard let self = self else { return }
            self.modelAction?.setTailPaymentBusy(false)
            switch result {
            case .success:
                self.refreshAfterTailPayment(orderNo: orderNo)
            case .failure(let error):
                self.modelAction?.displayError(text: error.localizedDescription)
            }
        }
    }

    func onCloseContractWebPage() {
        modelAction?.clearContractWebPage()
        onTapRefreshContract()
    }

    private func currentOrderNo() -> String? {
        if !orderNo.isEmpty { return orderNo }
        return VehicleManager.shared.getCurrentVehicleId()
    }

    private func applyContract(_ contract: ContractInfo) {
        modelAction?.updateContract(status: contract.contractStatus,
                                    signUrl: contract.signUrl,
                                    fileUrl: contract.fileUrl)
    }

    /// 加载合同：201061 视为未签署；其他错误不阻断详情页，交给后续操作暴露
    private func loadContract(orderNo: String) {
        ServiceContainer.marketingService.getContract(orderNo: orderNo) { [weak self] (result: Result<TspResponse<ContractInfo>, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let res):
                if res.isSuccess, let contract = res.data {
                    self.applyContract(contract)
                } else if res.code == ContractErrorCode.notExist {
                    self.modelAction?.updateContract(status: nil, signUrl: nil, fileUrl: nil)
                }
            case .failure:
                break
            }
        }
    }

    /// 尾款支付成功：重新拉订单，以服务端状态刷新页面
    private func refreshAfterTailPayment(orderNo: String) {
        ServiceContainer.marketingService.getOrder(orderNo: orderNo) { [weak self] (result: Result<TspResponse<Order>, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let res):
                guard let order = res.data else {
                    self.modelAction?.displayError(text: res.message ?? "请求异常")
                    return
                }
                VehicleManager.shared.updateSubState(id: orderNo, subState: order.orderState)
                AppGlobalState.shared.needRefresh = true
                if order.orderState == OrderState.FINAL_PAYMENT_PAID.rawValue {
                    self.handleFinalPaymentPaid()
                } else {
                    self.modelAction?.displayError(text: String(localized: "tail_payment_pending"))
                }
            case .failure(let error):
                self.modelAction?.displayError(text: error.localizedDescription)
            }
        }
    }

    /// 仅 http/https 的签署地址可加载；Mock 的 mock:// 走「签署中」占位
    private static func loadableSignUrl(_ raw: String?) -> URL? {
        guard let raw = raw, let url = URL(string: raw),
              let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https" else {
            return nil
        }
        return url
    }
    
    func onTapPayEarnestMoney() {
        if let orderNo = VehicleManager.shared.getCurrentVehicleId() {
            modelAction?.displayLoading()
            
            ServiceContainer.marketingService.getOrder(orderNo: orderNo) { [weak self] (result: Result<TspResponse<Order>, Error>) in
                switch result {
                case .success(let res):
                    guard let orderResponse = res.data else {
                        self?.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    
                    let payInfo = EarnestMoneyPayInfo(
                        orderNo: orderNo,
                        earnestMoneyAmount: 5000,
                        paymentChannels: [
                            PaymentChannelInfo(channelCode: "WECHAT", channelName: "微信支付", isDefault: true),
                            PaymentChannelInfo(channelCode: "ALIPAY", channelName: "支付宝", isDefault: false),
                            PaymentChannelInfo(channelCode: "UNION_PAY", channelName: "银联支付", isDefault: false)
                        ],
                        expireTime: Date().addingTimeInterval(900)
                    )
                    
                    AppGlobalState.shared.parameters["earnestMoneyPayInfo"] = payInfo
                    DispatchQueue.main.async {
                        AppRouter.shared.push(.marketing(.earnestMoneyPay))
                    }
                    
                case .failure(_):
                    self?.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    
    func onTapEarnestMoneyToDownPayment() {
        handleDownPaymentUnpaidFromEarnestMoneyPaid()
    }

    func onTapConvertToDownPayment(orderPersonType: Int, purchasePlan: Int, orderPersonName: String, orderPersonIdType: Int, orderPersonIdNum: String, licenseCityCode: String, dealership: String, deliveryCenter: String) {
        if let orderNo = VehicleManager.shared.getCurrentVehicleId() {
            modelAction?.displayLoading()
            let customerType = "personal"
            let paymentMethod = purchasePlan == 1 ? "full_payment" : "loan"
            let parameters: [String: Any] = [
                "orderNo": orderNo,
                "customerType": customerType,
                "paymentMethod": paymentMethod,
                "orderPersonType": orderPersonType,
                "purchasePlan": purchasePlan,
                "orderPersonName": orderPersonName,
                "orderPersonIdType": orderPersonIdType,
                "orderPersonIdNum": orderPersonIdNum,
                "licenseCityCode": licenseCityCode,
                "orderStoreCode": dealership,
                "deliveryStoreCode": deliveryCenter
            ]
            ServiceContainer.marketingService.earnestMoneyToDownPayment(parameters: parameters) { [weak self] (result: Result<TspResponse<EarnestToDownResponse>, Error>) in
                switch result {
                case .success(let res):
                    if res.isSuccess {
                        if let supplementary = res.data?.supplementaryPayment {
                            let amount = supplementary.amount ?? 0
                            self?.modelAction?.displayError(text: "需补款 ￥\(amount.formatted())，补款支付暂未接入")
                            return
                        }
                        VehicleManager.shared.updateSubState(id: orderNo, subState: 310)
                        AppGlobalState.shared.needRefresh = true
                        self?.handleDownPaymentPaid()
                    } else {
                        self?.modelAction?.displayError(text: res.message ?? "请求异常")
                    }
                case .failure(_):
                    self?.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    func onTapLockOrder() {
        if let orderNo = VehicleManager.shared.getCurrentVehicleId() {
            modelAction?.displayLoading()
            ServiceContainer.marketingService.lockOrder(orderNo: orderNo) { [weak self] (result: Result<TspResponse<NoReply>, Error>) in
                switch result {
                case .success(let res):
                    if res.isSuccess {
                        VehicleManager.shared.updateSubState(id: orderNo, subState: 400)
                        AppGlobalState.shared.needRefresh = true
                        self?.viewOnAppear()
                    } else {
                        self?.modelAction?.displayError(text: res.message ?? "请求异常")
                    }
                case .failure(_):
                    self?.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    
func onTapModifyOrderConfig() {
        guard let orderNo = VehicleManager.shared.getCurrentVehicleId() else {
            modelAction?.displayError(text: "未找到当前订单")
            return
        }
        modelAction?.displayLoading()
        
        ServiceContainer.marketingService.getOrder(orderNo: orderNo) { [weak self] (result: Result<TspResponse<Order>, Error>) in
            switch result {
            case .success(let res):
                guard let order = res.data else {
                    self?.modelAction?.displayError(text: "请求异常")
                    return
                }
                
                AppGlobalState.shared.parameters["saleModelCode"] = order.saleModelCode ?? ""
                if let optionCodes = order.optionCodes {
                    var featureCodes: [String: String] = [:]
                    for code in optionCodes {
                        featureCodes[code] = code
                    }
                    AppGlobalState.shared.parameters["saleModelConfigType"] = featureCodes
                } else {
                    AppGlobalState.shared.parameters["saleModelConfigType"] = order.saleModelConfigType ?? [:]
                }
                AppGlobalState.shared.parameters["modifyConfigMode"] = "order"
                AppGlobalState.shared.parameters["modifyConfigOrderNo"] = orderNo
                
                DispatchQueue.main.async {
                    AppRouter.shared.push(.marketing(.modelConfig(saleModelCode: order.saleModelCode ?? "")))
                }
            case .failure(_):
                self?.modelAction?.displayError(text: "请求异常")
            }
        }
    }
}

