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
    
    init(model: VehicleOrderDetailModelActionProtocol & VehicleOrderDetailModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
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
        
        let orderNum = AppGlobalState.shared.parameters["orderNum"] as? String ?? VehicleManager.shared.getCurrentVehicleId()
        
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
                case 650: viewName = "DELIVERED"
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
            default: handleOrder()
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
    
    private func handleWishlist() {
        if let wishlistId = VehicleManager.shared.getCurrentVehicleId() {
            ServiceContainer.marketingService.getWishlist(wishlistId: wishlistId) { (result: Result<TspResponse<Wishlist>, Error>) in
                switch result {
                case .success(let res):
                    guard let wishlist = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: wishlist.saleModelImages)
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: wishlist.displayName ?? wishlist.saleModelDesc,
                        saleModelDesc: wishlist.saleModelDesc
                    )
                    self.modelAction?.updateTotalPrice(totalPrice: wishlist.totalPrice)
                    
                    var displayConfigs: [(String, String, Decimal)] = []
                    for item in wishlist.saleModelConfigs {
                        if item.familyCode == "BASE_MODEL" {
                            displayConfigs.insert((item.featureName, item.featureName, item.featurePrice), at: 0)
                        } else {
                            displayConfigs.append((item.featureName, item.familyName, item.featurePrice))
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
    
    /// 动态处理配置项列表
    private func processConfigItems(_ configItems: [SaleModelConfigItem], totalPrice: Decimal) {
        // 将配置项转换为显示用的数据结构
        var displayConfigs: [(String, String, Decimal)] = []  // (familyName, featureName, featurePrice)
        
        for item in configItems {
            displayConfigs.append((item.familyName, item.featureName, item.featurePrice))
        }
        
        // 更新显示（这里需要Model层提供新的方法）
        self.modelAction?.updateDynamicConfigs(displayConfigs)
        
        // 更新总价
        // Model层会在 updateDynamicConfigs 中处理总价计算
    }
    
    private func handleOrder() {
        let saleModelConfigType = AppGlobalState.shared.parameters["saleModelConfigType"] as? [String: String] ?? [:]
        
        ServiceContainer.marketingService.getSelectedSaleModel(
            saleModelCode: AppGlobalState.shared.parameters["saleModelCode"] as? String ?? "",
            orderNo: nil,
            saleModelConfigType: saleModelConfigType
        ) { (result: Result<TspResponse<SelectedSaleModel>, Error>) in
            switch result {
            case .success(let res):
                if res.isSuccess {
                    guard let selectedSaleModel = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: selectedSaleModel.saleModelImages)
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: selectedSaleModel.saleModelConfigName["BASE_MODEL"] ?? "",
                        saleModelDesc: selectedSaleModel.saleModelDesc
                    )
                    self.modelAction?.updateBookMethod(
                        downPayment: selectedSaleModel.downPayment,
                        downPaymentPrice: selectedSaleModel.downPaymentPrice,
                        earnestMoney: selectedSaleModel.earnestMoney,
                        earnestMoneyPrice: selectedSaleModel.earnestMoneyPrice,
                        purchaseDenefitsIntro: selectedSaleModel.purchaseBenefitsIntro
                    )
                    if selectedSaleModel.downPayment {
                        self.modelAction?.updateSelectOrderPersonType(orderPersonType: 1)
                        self.modelAction?.updateSelectPurchasePlan(purchasePlan: 1)
                    }
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: selectedSaleModel.saleModelConfigName["BASE_MODEL"] ?? "",
                        saleModelPrice: selectedSaleModel.saleModelConfigPrice["BASE_MODEL"] ?? 0,
                        totalPrice: selectedSaleModel.totalPrice
                    )
                    let dynamicConfigs = self.convertToDynamicConfigs(
                        configName: selectedSaleModel.saleModelConfigName,
                        configPrice: selectedSaleModel.saleModelConfigPrice
                    )
                    self.modelAction?.updateDynamicConfigs(dynamicConfigs)
                    self.modelAction?.displayOrder()
                } else {
                    self.modelAction?.displayError(text: res.message ?? "请求异常")
                }
            case .failure(_):
                self.modelAction?.displayError(text: "请求异常")
            }
        }
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
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: orderResponse.saleModelConfigName?["BASE_MODEL"] ?? "",
                        saleModelDesc: orderResponse.saleModelDesc ?? ""
                    )
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: orderResponse.saleModelConfigName?["BASE_MODEL"] ?? "",
                        saleModelPrice: orderResponse.saleModelConfigPrice?["BASE_MODEL"] ?? 0,
                        totalPrice: orderResponse.totalPrice ?? 0
                    )
                    let dynamicConfigs = self.convertToDynamicConfigs(
                        configName: orderResponse.saleModelConfigName,
                        configPrice: orderResponse.saleModelConfigPrice
                    )
                    self.modelAction?.updateDynamicConfigs(dynamicConfigs)
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNo,
                        orderTime: orderResponse.orderTime ?? 0
                    )
                    self.modelAction?.displayEarnestMoneyUnpaid()
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
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: orderResponse.saleModelConfigName?["BASE_MODEL"] ?? "",
                        saleModelDesc: orderResponse.saleModelDesc ?? ""
                    )
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: orderResponse.saleModelConfigName?["BASE_MODEL"] ?? "",
                        saleModelPrice: orderResponse.saleModelConfigPrice?["BASE_MODEL"] ?? 0,
                        totalPrice: orderResponse.totalPrice ?? 0
                    )
                    let dynamicConfigs = self.convertToDynamicConfigs(
                        configName: orderResponse.saleModelConfigName,
                        configPrice: orderResponse.saleModelConfigPrice
                    )
                    self.modelAction?.updateDynamicConfigs(dynamicConfigs)
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNo,
                        orderTime: orderResponse.orderTime ?? 0
                    )
                    self.modelAction?.updateLicenseCity(
                        code: orderResponse.licenseCityCode ?? "",
                        name: orderResponse.licenseCityName ?? ""
                    )
                    self.modelAction?.displayEarnestMoneyPaid()
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
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: orderResponse.saleModelConfigName?["BASE_MODEL"] ?? "",
                        saleModelDesc: orderResponse.saleModelDesc ?? ""
                    )
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: orderResponse.saleModelConfigName?["BASE_MODEL"] ?? "",
                        saleModelPrice: orderResponse.saleModelConfigPrice?["BASE_MODEL"] ?? 0,
                        totalPrice: orderResponse.totalPrice ?? 0
                    )
                    let dynamicConfigs = self.convertToDynamicConfigs(
                        configName: orderResponse.saleModelConfigName,
                        configPrice: orderResponse.saleModelConfigPrice
                    )
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
                    self.modelAction?.displayDownPaymentUnpaid()
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
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: orderResponse.saleModelConfigName?["BASE_MODEL"] ?? "",
                        saleModelDesc: orderResponse.saleModelDesc ?? ""
                    )
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: orderResponse.saleModelConfigName?["BASE_MODEL"] ?? "",
                        saleModelPrice: orderResponse.saleModelConfigPrice?["BASE_MODEL"] ?? 0,
                        totalPrice: orderResponse.totalPrice ?? 0
                    )
                    let dynamicConfigs = self.convertToDynamicConfigs(
                        configName: orderResponse.saleModelConfigName,
                        configPrice: orderResponse.saleModelConfigPrice
                    )
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
                    self.modelAction?.displayDownPaymentUnpaid()
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
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: orderResponse.saleModelConfigName?["BASE_MODEL"] ?? "",
                        saleModelDesc: orderResponse.saleModelDesc ?? ""
                    )
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: orderResponse.saleModelConfigName?["BASE_MODEL"] ?? "",
                        saleModelPrice: orderResponse.saleModelConfigPrice?["BASE_MODEL"] ?? 0,
                        totalPrice: orderResponse.totalPrice ?? 0
                    )
                    let dynamicConfigs = self.convertToDynamicConfigs(
                        configName: orderResponse.saleModelConfigName,
                        configPrice: orderResponse.saleModelConfigPrice
                    )
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
                    self.modelAction?.displayDownPaymentPaid()
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
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: orderResponse.saleModelConfigName?["BASE_MODEL"] ?? "",
                        saleModelDesc: orderResponse.saleModelDesc ?? ""
                    )
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: orderResponse.saleModelConfigName?["BASE_MODEL"] ?? "",
                        saleModelPrice: orderResponse.saleModelConfigPrice?["BASE_MODEL"] ?? 0,
                        totalPrice: orderResponse.totalPrice ?? 0
                    )
                    let dynamicConfigs = self.convertToDynamicConfigs(
                        configName: orderResponse.saleModelConfigName,
                        configPrice: orderResponse.saleModelConfigPrice
                    )
                    self.modelAction?.updateDynamicConfigs(dynamicConfigs)
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNo,
                        orderTime: orderResponse.orderTime ?? 0
                    )
                    self.modelAction?.displayArrangeProduction()
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
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: orderResponse.saleModelConfigName?["BASE_MODEL"] ?? "",
                        saleModelDesc: orderResponse.saleModelDesc ?? ""
                    )
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: orderResponse.saleModelConfigName?["BASE_MODEL"] ?? "",
                        saleModelPrice: orderResponse.saleModelConfigPrice?["BASE_MODEL"] ?? 0,
                        totalPrice: orderResponse.totalPrice ?? 0
                    )
                    let dynamicConfigs = self.convertToDynamicConfigs(
                        configName: orderResponse.saleModelConfigName,
                        configPrice: orderResponse.saleModelConfigPrice
                    )
                    self.modelAction?.updateDynamicConfigs(dynamicConfigs)
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNo,
                        orderTime: orderResponse.orderTime ?? 0
                    )
                    self.modelAction?.displayAllocationVehicle()
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
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: orderResponse.saleModelConfigName?["BASE_MODEL"] ?? "",
                        saleModelDesc: orderResponse.saleModelDesc ?? ""
                    )
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: orderResponse.saleModelConfigName?["BASE_MODEL"] ?? "",
                        saleModelPrice: orderResponse.saleModelConfigPrice?["BASE_MODEL"] ?? 0,
                        totalPrice: orderResponse.totalPrice ?? 0
                    )
                    let dynamicConfigs = self.convertToDynamicConfigs(
                        configName: orderResponse.saleModelConfigName,
                        configPrice: orderResponse.saleModelConfigPrice
                    )
                    self.modelAction?.updateDynamicConfigs(dynamicConfigs)
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNo,
                        orderTime: orderResponse.orderTime ?? 0
                    )
                    self.modelAction?.displayPrepareTransport()
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
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: orderResponse.saleModelConfigName?["BASE_MODEL"] ?? "",
                        saleModelDesc: orderResponse.saleModelDesc ?? ""
                    )
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: orderResponse.saleModelConfigName?["BASE_MODEL"] ?? "",
                        saleModelPrice: orderResponse.saleModelConfigPrice?["BASE_MODEL"] ?? 0,
                        totalPrice: orderResponse.totalPrice ?? 0
                    )
                    let dynamicConfigs = self.convertToDynamicConfigs(
                        configName: orderResponse.saleModelConfigName,
                        configPrice: orderResponse.saleModelConfigPrice
                    )
                    self.modelAction?.updateDynamicConfigs(dynamicConfigs)
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNo,
                        orderTime: orderResponse.orderTime ?? 0
                    )
                    self.modelAction?.displayPrepareDeliver()
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
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: orderResponse.saleModelConfigName?["BASE_MODEL"] ?? "",
                        saleModelDesc: orderResponse.saleModelDesc ?? ""
                    )
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: orderResponse.saleModelConfigName?["BASE_MODEL"] ?? "",
                        saleModelPrice: orderResponse.saleModelConfigPrice?["BASE_MODEL"] ?? 0,
                        totalPrice: orderResponse.totalPrice ?? 0
                    )
                    let dynamicConfigs = self.convertToDynamicConfigs(
                        configName: orderResponse.saleModelConfigName,
                        configPrice: orderResponse.saleModelConfigPrice
                    )
                    self.modelAction?.updateDynamicConfigs(dynamicConfigs)
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNo,
                        orderTime: orderResponse.orderTime ?? 0
                    )
                    self.modelAction?.displayFinalPaymentPaid()
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
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: orderResponse.saleModelConfigName?["BASE_MODEL"] ?? "",
                        saleModelDesc: orderResponse.saleModelDesc ?? ""
                    )
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: orderResponse.saleModelConfigName?["BASE_MODEL"] ?? "",
                        saleModelPrice: orderResponse.saleModelConfigPrice?["BASE_MODEL"] ?? 0,
                        totalPrice: orderResponse.totalPrice ?? 0
                    )
                    let dynamicConfigs = self.convertToDynamicConfigs(
                        configName: orderResponse.saleModelConfigName,
                        configPrice: orderResponse.saleModelConfigPrice
                    )
                    self.modelAction?.updateDynamicConfigs(dynamicConfigs)
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNo,
                        orderTime: orderResponse.orderTime ?? 0
                    )
                    self.modelAction?.displayInvoiced()
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
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: orderResponse.saleModelConfigName?["BASE_MODEL"] ?? "",
                        saleModelDesc: orderResponse.saleModelDesc ?? ""
                    )
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: orderResponse.saleModelConfigName?["BASE_MODEL"] ?? "",
                        saleModelPrice: orderResponse.saleModelConfigPrice?["BASE_MODEL"] ?? 0,
                        totalPrice: orderResponse.totalPrice ?? 0
                    )
                    let dynamicConfigs = self.convertToDynamicConfigs(
                        configName: orderResponse.saleModelConfigName,
                        configPrice: orderResponse.saleModelConfigPrice
                    )
                    self.modelAction?.updateDynamicConfigs(dynamicConfigs)
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNo,
                        orderTime: orderResponse.orderTime ?? 0
                    )
                    self.modelAction?.displayDelivered()
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
                            self.modelRouter?.closeScreen()
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
                self.modelRouter?.closeScreen()
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
                    self.modelRouter?.routeToModelConfig()
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
                    
                    // 将配置项列表转换为特征代码字典
                    let featureCodes = self.extractFeatureCodes(wishlist.saleModelConfigs)
                    
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
    
    /// 从配置项列表提取特征代码字典
    private func extractFeatureCodes(_ configItems: [SaleModelConfigItem]) -> [String: String] {
        var featureCodes: [String: String] = [:]
        for item in configItems {
            featureCodes[item.familyCode] = item.featureCode
        }
        return featureCodes
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
        ServiceContainer.marketingService.earnestMoneyOrder(
            saleModelCode: AppGlobalState.shared.parameters["saleModelCode"] as? String ?? "",
            orderNo: nil,
            saleModelConfigType: saleModelConfigType,
            licenseCityCode: licenseCityCode
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
                
                self?.modelRouter?.routeToEarnestMoneyPay()
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
        let customerType = "personal"
        let paymentMethod = purchasePlan == 1 ? "full_payment" : "loan"
        ServiceContainer.marketingService.downPaymentOrder(
            saleModelCode: AppGlobalState.shared.parameters["saleModelCode"] as? String ?? "",
            orderNo: orderNo,
            saleModelConfigType: saleModelConfigType,
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
                
                self?.modelRouter?.routeToDownPaymentPay()
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
        modelRouter?.routeToLicenseArea()
    }
    func onTapDealership() {
        modelRouter?.routeToDealership()
    }
    func onTapDeliveryCenter() {
        modelRouter?.routeToDeliveryCenter()
    }
    func onTapCancelOrder() {
        if let orderNo = VehicleManager.shared.getCurrentVehicleId() {
            modelAction?.displayLoading()
            ServiceContainer.marketingService.cancelOrder(orderNo: orderNo) { (result: Result<TspResponse<NoReply>, Error>) in
                switch result {
                case .success(_):
                    VehicleManager.shared.delete(orderNum: orderNo)
                    self.modelRouter?.closeScreen()
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    func onTapPayOrder(orderPaymentPhase: Int, paymentAmount: Decimal, paymentChannel: String) {
        if let orderNo = VehicleManager.shared.getCurrentVehicleId() {
            modelAction?.displayLoading()
            ServiceContainer.marketingService.payOrder(orderNo: orderNo, orderPaymentPhase: orderPaymentPhase, paymentAmount: paymentAmount, paymentChannel: paymentChannel) { [weak self] (result: Result<TspResponse<OrderPaymentResponse>, Error>) in
                switch result {
                case .success(let res):
                    if res.isSuccess {
                        // 根据支付阶段更新本地状态码
                        let nextSubState: Int
                        if orderPaymentPhase == 1 {
                            nextSubState = 210 // 意向金已支付
                        } else if orderPaymentPhase == 2 {
                            nextSubState = 310 // 定金已支付
                        } else {
                            nextSubState = 700 // 其他（如尾款）支付后视为激活/完成
                        }
                        
                        // 更新本地存储
                        VehicleManager.shared.updateSubState(id: orderNo, subState: nextSubState)
                        
                        // 如果原来是心愿单，支付后应变为订单类型
                        if let vehicle = VehicleManager.shared.getCurrentVehicle(), vehicle.type == .WISHLIST {
                            VehicleManager.shared.add(orderNum: orderNo, type: .ORDER, subState: nextSubState, displayName: vehicle.displayName)
                        }
                        
                        AppGlobalState.shared.needRefresh = true
                        // 不再关闭页面，而是原地刷新状态
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
                    self?.modelRouter?.routeToEarnestMoneyPay()
                    
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
            ServiceContainer.marketingService.earnestMoneyToDownPayment(parameters: parameters) { [weak self] (result: Result<TspResponse<NoReply>, Error>) in
                switch result {
                case .success(let res):
                    if res.isSuccess {
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
                AppGlobalState.shared.parameters["saleModelConfigType"] = order.saleModelConfigType ?? [:]
                AppGlobalState.shared.parameters["modifyConfigMode"] = "order"
                AppGlobalState.shared.parameters["modifyConfigOrderNo"] = orderNo
                
                self?.modelRouter?.routeToModelConfig()
            case .failure(_):
                self?.modelAction?.displayError(text: "请求异常")
            }
        }
    }
}

