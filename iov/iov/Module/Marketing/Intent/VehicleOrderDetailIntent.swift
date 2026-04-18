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
        // 如果已经是在下单页（ORDER），且是从子页面返回（没有新的 orderDetailView 参数），则不重新加载，避免跳回心愿单
        if modelAction?.getContentState() == .order && AppGlobalState.shared.parameters["orderDetailView"] == nil {
            return
        }
        
        var viewName: String? = AppGlobalState.shared.parameters["orderDetailView"] as? String
        
        // 尝试获取当前操作的订单号
        let orderNum = AppGlobalState.shared.parameters["orderNum"] as? String ?? VehicleManager.shared.getCurrentVehicleId()
        
        if viewName != nil {
            AppGlobalState.shared.parameters["orderDetailView"] = nil
        } else {
            // 如果是页面内原地刷新，根据本地最新的 subState 推断视图
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
        
        // 最终兜底：如果还是找不到视图名，尝试从状态推断（兼容各种刷新场景）
        if viewName == nil, let vehicle = VehicleManager.shared.getCurrentVehicle() {
            if vehicle.type == .WISHLIST { viewName = "WISHLIST" }
            else {
                // 根据 subState 兜底
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
            default: handleOrder() // 默认走下单流程
            }
        }
    }
    
    private func handleWishlist() {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            ServiceContainer.marketingService.getWishlist(orderNum: orderNum) { (result: Result<TspResponse<Wishlist>, Error>) in
                switch result {
                case .success(let res):
                    guard let wishlist = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: wishlist.saleModelImages)
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: wishlist.saleModelConfigName["MODEL"] ?? "",
                        saleModelPrice: wishlist.saleModelConfigPrice["MODEL"] ?? 0,
                        saleSpareTireName: wishlist.saleModelConfigName["SPARE_TIRE"] ?? "",
                        saleSpareTirePrice: wishlist.saleModelConfigPrice["SPARE_TIRE"] ?? 0,
                        saleExteriorName: wishlist.saleModelConfigName["EXTERIOR"] ?? "",
                        saleExteriorPrice: wishlist.saleModelConfigPrice["EXTERIOR"] ?? 0,
                        saleWheelName: wishlist.saleModelConfigName["WHEEL"] ?? "",
                        saleWheelPrice: wishlist.saleModelConfigPrice["WHEEL"] ?? 0,
                        saleInteriorName: wishlist.saleModelConfigName["INTERIOR"] ?? "",
                        saleInteriorPrice: wishlist.saleModelConfigPrice["INTERIOR"] ?? 0,
                        saleAdasName: wishlist.saleModelConfigName["ADAS"] ?? "",
                        saleAdasPrice: wishlist.saleModelConfigPrice["ADAS"] ?? 0,
                        totalPrice: wishlist.totalPrice
                    )
                    self.modelAction?.displayWishlist()
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    
    private func handleOrder() {
        ServiceContainer.marketingService.getSelectedSaleModel(
            saleCode: AppGlobalState.shared.parameters["saleCode"] as? String ?? "",
            modelCode: AppGlobalState.shared.parameters["modelCode"] as? String ?? "",
            exteriorCode: AppGlobalState.shared.parameters["exteriorCode"] as? String ?? "",
            interiorCode: AppGlobalState.shared.parameters["interiorCode"] as? String ?? "",
            wheelCode: AppGlobalState.shared.parameters["wheelCode"] as? String ?? "",
            spareTireCode: AppGlobalState.shared.parameters["spareTireCode"] as? String ?? "",
            adasCode: AppGlobalState.shared.parameters["adasCode"] as? String ?? ""
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
                        saleModelName: selectedSaleModel.saleModelConfigName["MODEL"] ?? "",
                        saleModelDesc: selectedSaleModel.saleModelDesc
                    )
                    self.modelAction?.updateBookMethod(
                        downPayment: selectedSaleModel.downPayment,
                        downPaymentPrice: selectedSaleModel.downPaymentPrice,
                        earnestMoney: selectedSaleModel.earnestMoney,
                        earnestMoneyPrice: selectedSaleModel.earnestMoneyPrice,
                        purchaseDenefitsIntro: selectedSaleModel.purchaseBenefitsIntro
                    )
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: selectedSaleModel.saleModelConfigName["MODEL"] ?? "",
                        saleModelPrice: selectedSaleModel.saleModelConfigPrice["MODEL"] ?? 0,
                        saleSpareTireName: selectedSaleModel.saleModelConfigName["SPARE_TIRE"] ?? "",
                        saleSpareTirePrice: selectedSaleModel.saleModelConfigPrice["SPARE_TIRE"] ?? 0,
                        saleExteriorName: selectedSaleModel.saleModelConfigName["EXTERIOR"] ?? "",
                        saleExteriorPrice: selectedSaleModel.saleModelConfigPrice["EXTERIOR"] ?? 0,
                        saleWheelName: selectedSaleModel.saleModelConfigName["WHEEL"] ?? "",
                        saleWheelPrice: selectedSaleModel.saleModelConfigPrice["WHEEL"] ?? 0,
                        saleInteriorName: selectedSaleModel.saleModelConfigName["INTERIOR"] ?? "",
                        saleInteriorPrice: selectedSaleModel.saleModelConfigPrice["INTERIOR"] ?? 0,
                        saleAdasName: selectedSaleModel.saleModelConfigName["ADAS"] ?? "",
                        saleAdasPrice: selectedSaleModel.saleModelConfigPrice["ADAS"] ?? 0,
                        totalPrice: selectedSaleModel.totalPrice
                    )
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
            ServiceContainer.marketingService.getOrder(orderNum: orderNum) { (result: Result<TspResponse<Order>, Error>) in
                switch result {
                case .success(let res):
                    guard let orderResponse = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: orderResponse.saleModelImages)
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: orderResponse.saleModelConfigName["MODEL"] ?? "",
                        saleModelDesc: orderResponse.saleModelDesc
                    )
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: orderResponse.saleModelConfigName["MODEL"] ?? "",
                        saleModelPrice: orderResponse.saleModelConfigPrice["MODEL"] ?? 0,
                        saleSpareTireName: orderResponse.saleModelConfigName["SPARE_TIRE"] ?? "",
                        saleSpareTirePrice: orderResponse.saleModelConfigPrice["SPARE_TIRE"] ?? 0,
                        saleExteriorName: orderResponse.saleModelConfigName["EXTERIOR"] ?? "",
                        saleExteriorPrice: orderResponse.saleModelConfigPrice["EXTERIOR"] ?? 0,
                        saleWheelName: orderResponse.saleModelConfigName["WHEEL"] ?? "",
                        saleWheelPrice: orderResponse.saleModelConfigPrice["WHEEL"] ?? 0,
                        saleInteriorName: orderResponse.saleModelConfigName["INTERIOR"] ?? "",
                        saleInteriorPrice: orderResponse.saleModelConfigPrice["INTERIOR"] ?? 0,
                        saleAdasName: orderResponse.saleModelConfigName["ADAS"] ?? "",
                        saleAdasPrice: orderResponse.saleModelConfigPrice["ADAS"] ?? 0,
                        totalPrice: orderResponse.totalPrice
                    )
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNum,
                        orderTime: orderResponse.orderTime
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
            ServiceContainer.marketingService.getOrder(orderNum: orderNum) { (result: Result<TspResponse<Order>, Error>) in
                switch result {
                case .success(let res):
                    guard let orderResponse = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: orderResponse.saleModelImages)
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: orderResponse.saleModelConfigName["MODEL"] ?? "",
                        saleModelDesc: orderResponse.saleModelDesc
                    )
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: orderResponse.saleModelConfigName["MODEL"] ?? "",
                        saleModelPrice: orderResponse.saleModelConfigPrice["MODEL"] ?? 0,
                        saleSpareTireName: orderResponse.saleModelConfigName["SPARE_TIRE"] ?? "",
                        saleSpareTirePrice: orderResponse.saleModelConfigPrice["SPARE_TIRE"] ?? 0,
                        saleExteriorName: orderResponse.saleModelConfigName["EXTERIOR"] ?? "",
                        saleExteriorPrice: orderResponse.saleModelConfigPrice["EXTERIOR"] ?? 0,
                        saleWheelName: orderResponse.saleModelConfigName["WHEEL"] ?? "",
                        saleWheelPrice: orderResponse.saleModelConfigPrice["WHEEL"] ?? 0,
                        saleInteriorName: orderResponse.saleModelConfigName["INTERIOR"] ?? "",
                        saleInteriorPrice: orderResponse.saleModelConfigPrice["INTERIOR"] ?? 0,
                        saleAdasName: orderResponse.saleModelConfigName["ADAS"] ?? "",
                        saleAdasPrice: orderResponse.saleModelConfigPrice["ADAS"] ?? 0,
                        totalPrice: orderResponse.totalPrice
                    )
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNum,
                        orderTime: orderResponse.orderTime
                    )
                    self.modelAction?.displayEarnestMoneyPaid()
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    private func handleDownPaymentUnpaid() {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            ServiceContainer.marketingService.getOrder(orderNum: orderNum) { (result: Result<TspResponse<Order>, Error>) in
                switch result {
                case .success(let res):
                    guard let orderResponse = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: orderResponse.saleModelImages)
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: orderResponse.saleModelConfigName["MODEL"] ?? "",
                        saleModelDesc: orderResponse.saleModelDesc
                    )
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: orderResponse.saleModelConfigName["MODEL"] ?? "",
                        saleModelPrice: orderResponse.saleModelConfigPrice["MODEL"] ?? 0,
                        saleSpareTireName: orderResponse.saleModelConfigName["SPARE_TIRE"] ?? "",
                        saleSpareTirePrice: orderResponse.saleModelConfigPrice["SPARE_TIRE"] ?? 0,
                        saleExteriorName: orderResponse.saleModelConfigName["EXTERIOR"] ?? "",
                        saleExteriorPrice: orderResponse.saleModelConfigPrice["EXTERIOR"] ?? 0,
                        saleWheelName: orderResponse.saleModelConfigName["WHEEL"] ?? "",
                        saleWheelPrice: orderResponse.saleModelConfigPrice["WHEEL"] ?? 0,
                        saleInteriorName: orderResponse.saleModelConfigName["INTERIOR"] ?? "",
                        saleInteriorPrice: orderResponse.saleModelConfigPrice["INTERIOR"] ?? 0,
                        saleAdasName: orderResponse.saleModelConfigName["ADAS"] ?? "",
                        saleAdasPrice: orderResponse.saleModelConfigPrice["ADAS"] ?? 0,
                        totalPrice: orderResponse.totalPrice
                    )
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNum,
                        orderTime: orderResponse.orderTime
                    )
                    self.modelAction?.updateOrderPerson(
                        orderPersonType: orderResponse.orderPersonType ?? 0,
                        orderPersonName: orderResponse.orderPersonName ?? "",
                        orderPersonIdType: orderResponse.orderPersonIdType ?? 0,
                        orderPersonIdNum: orderResponse.orderPersonIdNum ?? ""
                    )
                    self.modelAction?.updatePurchasePlan(purchasePlan: orderResponse.purchasePlan ?? 0)
                    self.modelAction?.displayDownPaymentUnpaid()
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    private func handleDownPaymentPaid() {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            ServiceContainer.marketingService.getOrder(orderNum: orderNum) { (result: Result<TspResponse<Order>, Error>) in
                switch result {
                case .success(let res):
                    guard let orderResponse = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: orderResponse.saleModelImages)
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: orderResponse.saleModelConfigName["MODEL"] ?? "",
                        saleModelDesc: orderResponse.saleModelDesc
                    )
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: orderResponse.saleModelConfigName["MODEL"] ?? "",
                        saleModelPrice: orderResponse.saleModelConfigPrice["MODEL"] ?? 0,
                        saleSpareTireName: orderResponse.saleModelConfigName["SPARE_TIRE"] ?? "",
                        saleSpareTirePrice: orderResponse.saleModelConfigPrice["SPARE_TIRE"] ?? 0,
                        saleExteriorName: orderResponse.saleModelConfigName["EXTERIOR"] ?? "",
                        saleExteriorPrice: orderResponse.saleModelConfigPrice["EXTERIOR"] ?? 0,
                        saleWheelName: orderResponse.saleModelConfigName["WHEEL"] ?? "",
                        saleWheelPrice: orderResponse.saleModelConfigPrice["WHEEL"] ?? 0,
                        saleInteriorName: orderResponse.saleModelConfigName["INTERIOR"] ?? "",
                        saleInteriorPrice: orderResponse.saleModelConfigPrice["INTERIOR"] ?? 0,
                        saleAdasName: orderResponse.saleModelConfigName["ADAS"] ?? "",
                        saleAdasPrice: orderResponse.saleModelConfigPrice["ADAS"] ?? 0,
                        totalPrice: orderResponse.totalPrice
                    )
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNum,
                        orderTime: orderResponse.orderTime
                    )
                    self.modelAction?.displayDownPaymentPaid()
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    private func handleArrangeProduction() {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            ServiceContainer.marketingService.getOrder(orderNum: orderNum) { (result: Result<TspResponse<Order>, Error>) in
                switch result {
                case .success(let res):
                    guard let orderResponse = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: orderResponse.saleModelImages)
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: orderResponse.saleModelConfigName["MODEL"] ?? "",
                        saleModelDesc: orderResponse.saleModelDesc
                    )
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: orderResponse.saleModelConfigName["MODEL"] ?? "",
                        saleModelPrice: orderResponse.saleModelConfigPrice["MODEL"] ?? 0,
                        saleSpareTireName: orderResponse.saleModelConfigName["SPARE_TIRE"] ?? "",
                        saleSpareTirePrice: orderResponse.saleModelConfigPrice["SPARE_TIRE"] ?? 0,
                        saleExteriorName: orderResponse.saleModelConfigName["EXTERIOR"] ?? "",
                        saleExteriorPrice: orderResponse.saleModelConfigPrice["EXTERIOR"] ?? 0,
                        saleWheelName: orderResponse.saleModelConfigName["WHEEL"] ?? "",
                        saleWheelPrice: orderResponse.saleModelConfigPrice["WHEEL"] ?? 0,
                        saleInteriorName: orderResponse.saleModelConfigName["INTERIOR"] ?? "",
                        saleInteriorPrice: orderResponse.saleModelConfigPrice["INTERIOR"] ?? 0,
                        saleAdasName: orderResponse.saleModelConfigName["ADAS"] ?? "",
                        saleAdasPrice: orderResponse.saleModelConfigPrice["ADAS"] ?? 0,
                        totalPrice: orderResponse.totalPrice
                    )
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNum,
                        orderTime: orderResponse.orderTime
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
            ServiceContainer.marketingService.getOrder(orderNum: orderNum) { (result: Result<TspResponse<Order>, Error>) in
                switch result {
                case .success(let res):
                    guard let orderResponse = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: orderResponse.saleModelImages)
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: orderResponse.saleModelConfigName["MODEL"] ?? "",
                        saleModelDesc: orderResponse.saleModelDesc
                    )
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: orderResponse.saleModelConfigName["MODEL"] ?? "",
                        saleModelPrice: orderResponse.saleModelConfigPrice["MODEL"] ?? 0,
                        saleSpareTireName: orderResponse.saleModelConfigName["SPARE_TIRE"] ?? "",
                        saleSpareTirePrice: orderResponse.saleModelConfigPrice["SPARE_TIRE"] ?? 0,
                        saleExteriorName: orderResponse.saleModelConfigName["EXTERIOR"] ?? "",
                        saleExteriorPrice: orderResponse.saleModelConfigPrice["EXTERIOR"] ?? 0,
                        saleWheelName: orderResponse.saleModelConfigName["WHEEL"] ?? "",
                        saleWheelPrice: orderResponse.saleModelConfigPrice["WHEEL"] ?? 0,
                        saleInteriorName: orderResponse.saleModelConfigName["INTERIOR"] ?? "",
                        saleInteriorPrice: orderResponse.saleModelConfigPrice["INTERIOR"] ?? 0,
                        saleAdasName: orderResponse.saleModelConfigName["ADAS"] ?? "",
                        saleAdasPrice: orderResponse.saleModelConfigPrice["ADAS"] ?? 0,
                        totalPrice: orderResponse.totalPrice
                    )
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNum,
                        orderTime: orderResponse.orderTime
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
            ServiceContainer.marketingService.getOrder(orderNum: orderNum) { (result: Result<TspResponse<Order>, Error>) in
                switch result {
                case .success(let res):
                    guard let orderResponse = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: orderResponse.saleModelImages)
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: orderResponse.saleModelConfigName["MODEL"] ?? "",
                        saleModelDesc: orderResponse.saleModelDesc
                    )
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: orderResponse.saleModelConfigName["MODEL"] ?? "",
                        saleModelPrice: orderResponse.saleModelConfigPrice["MODEL"] ?? 0,
                        saleSpareTireName: orderResponse.saleModelConfigName["SPARE_TIRE"] ?? "",
                        saleSpareTirePrice: orderResponse.saleModelConfigPrice["SPARE_TIRE"] ?? 0,
                        saleExteriorName: orderResponse.saleModelConfigName["EXTERIOR"] ?? "",
                        saleExteriorPrice: orderResponse.saleModelConfigPrice["EXTERIOR"] ?? 0,
                        saleWheelName: orderResponse.saleModelConfigName["WHEEL"] ?? "",
                        saleWheelPrice: orderResponse.saleModelConfigPrice["WHEEL"] ?? 0,
                        saleInteriorName: orderResponse.saleModelConfigName["INTERIOR"] ?? "",
                        saleInteriorPrice: orderResponse.saleModelConfigPrice["INTERIOR"] ?? 0,
                        saleAdasName: orderResponse.saleModelConfigName["ADAS"] ?? "",
                        saleAdasPrice: orderResponse.saleModelConfigPrice["ADAS"] ?? 0,
                        totalPrice: orderResponse.totalPrice
                    )
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNum,
                        orderTime: orderResponse.orderTime
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
            ServiceContainer.marketingService.getOrder(orderNum: orderNum) { (result: Result<TspResponse<Order>, Error>) in
                switch result {
                case .success(let res):
                    guard let orderResponse = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: orderResponse.saleModelImages)
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: orderResponse.saleModelConfigName["MODEL"] ?? "",
                        saleModelDesc: orderResponse.saleModelDesc
                    )
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: orderResponse.saleModelConfigName["MODEL"] ?? "",
                        saleModelPrice: orderResponse.saleModelConfigPrice["MODEL"] ?? 0,
                        saleSpareTireName: orderResponse.saleModelConfigName["SPARE_TIRE"] ?? "",
                        saleSpareTirePrice: orderResponse.saleModelConfigPrice["SPARE_TIRE"] ?? 0,
                        saleExteriorName: orderResponse.saleModelConfigName["EXTERIOR"] ?? "",
                        saleExteriorPrice: orderResponse.saleModelConfigPrice["EXTERIOR"] ?? 0,
                        saleWheelName: orderResponse.saleModelConfigName["WHEEL"] ?? "",
                        saleWheelPrice: orderResponse.saleModelConfigPrice["WHEEL"] ?? 0,
                        saleInteriorName: orderResponse.saleModelConfigName["INTERIOR"] ?? "",
                        saleInteriorPrice: orderResponse.saleModelConfigPrice["INTERIOR"] ?? 0,
                        saleAdasName: orderResponse.saleModelConfigName["ADAS"] ?? "",
                        saleAdasPrice: orderResponse.saleModelConfigPrice["ADAS"] ?? 0,
                        totalPrice: orderResponse.totalPrice
                    )
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNum,
                        orderTime: orderResponse.orderTime
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
            ServiceContainer.marketingService.getOrder(orderNum: orderNum) { (result: Result<TspResponse<Order>, Error>) in
                switch result {
                case .success(let res):
                    guard let orderResponse = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: orderResponse.saleModelImages)
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: orderResponse.saleModelConfigName["MODEL"] ?? "",
                        saleModelDesc: orderResponse.saleModelDesc
                    )
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: orderResponse.saleModelConfigName["MODEL"] ?? "",
                        saleModelPrice: orderResponse.saleModelConfigPrice["MODEL"] ?? 0,
                        saleSpareTireName: orderResponse.saleModelConfigName["SPARE_TIRE"] ?? "",
                        saleSpareTirePrice: orderResponse.saleModelConfigPrice["SPARE_TIRE"] ?? 0,
                        saleExteriorName: orderResponse.saleModelConfigName["EXTERIOR"] ?? "",
                        saleExteriorPrice: orderResponse.saleModelConfigPrice["EXTERIOR"] ?? 0,
                        saleWheelName: orderResponse.saleModelConfigName["WHEEL"] ?? "",
                        saleWheelPrice: orderResponse.saleModelConfigPrice["WHEEL"] ?? 0,
                        saleInteriorName: orderResponse.saleModelConfigName["INTERIOR"] ?? "",
                        saleInteriorPrice: orderResponse.saleModelConfigPrice["INTERIOR"] ?? 0,
                        saleAdasName: orderResponse.saleModelConfigName["ADAS"] ?? "",
                        saleAdasPrice: orderResponse.saleModelConfigPrice["ADAS"] ?? 0,
                        totalPrice: orderResponse.totalPrice
                    )
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNum,
                        orderTime: orderResponse.orderTime
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
            ServiceContainer.marketingService.getOrder(orderNum: orderNum) { (result: Result<TspResponse<Order>, Error>) in
                switch result {
                case .success(let res):
                    guard let orderResponse = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: orderResponse.saleModelImages)
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: orderResponse.saleModelConfigName["MODEL"] ?? "",
                        saleModelDesc: orderResponse.saleModelDesc
                    )
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: orderResponse.saleModelConfigName["MODEL"] ?? "",
                        saleModelPrice: orderResponse.saleModelConfigPrice["MODEL"] ?? 0,
                        saleSpareTireName: orderResponse.saleModelConfigName["SPARE_TIRE"] ?? "",
                        saleSpareTirePrice: orderResponse.saleModelConfigPrice["SPARE_TIRE"] ?? 0,
                        saleExteriorName: orderResponse.saleModelConfigName["EXTERIOR"] ?? "",
                        saleExteriorPrice: orderResponse.saleModelConfigPrice["EXTERIOR"] ?? 0,
                        saleWheelName: orderResponse.saleModelConfigName["WHEEL"] ?? "",
                        saleWheelPrice: orderResponse.saleModelConfigPrice["WHEEL"] ?? 0,
                        saleInteriorName: orderResponse.saleModelConfigName["INTERIOR"] ?? "",
                        saleInteriorPrice: orderResponse.saleModelConfigPrice["INTERIOR"] ?? 0,
                        saleAdasName: orderResponse.saleModelConfigName["ADAS"] ?? "",
                        saleAdasPrice: orderResponse.saleModelConfigPrice["ADAS"] ?? 0,
                        totalPrice: orderResponse.totalPrice
                    )
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNum,
                        orderTime: orderResponse.orderTime
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
            ServiceContainer.marketingService.getOrder(orderNum: orderNum) { (result: Result<TspResponse<Order>, Error>) in
                switch result {
                case .success(let res):
                    guard let orderResponse = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    self.modelAction?.updateSaleModelImages(saleModelImages: orderResponse.saleModelImages)
                    self.modelAction?.updateSaleModelIntro(
                        saleModelName: orderResponse.saleModelConfigName["MODEL"] ?? "",
                        saleModelDesc: orderResponse.saleModelDesc
                    )
                    self.modelAction?.updateSaleModelPrice(
                        saleModelName: orderResponse.saleModelConfigName["MODEL"] ?? "",
                        saleModelPrice: orderResponse.saleModelConfigPrice["MODEL"] ?? 0,
                        saleSpareTireName: orderResponse.saleModelConfigName["SPARE_TIRE"] ?? "",
                        saleSpareTirePrice: orderResponse.saleModelConfigPrice["SPARE_TIRE"] ?? 0,
                        saleExteriorName: orderResponse.saleModelConfigName["EXTERIOR"] ?? "",
                        saleExteriorPrice: orderResponse.saleModelConfigPrice["EXTERIOR"] ?? 0,
                        saleWheelName: orderResponse.saleModelConfigName["WHEEL"] ?? "",
                        saleWheelPrice: orderResponse.saleModelConfigPrice["WHEEL"] ?? 0,
                        saleInteriorName: orderResponse.saleModelConfigName["INTERIOR"] ?? "",
                        saleInteriorPrice: orderResponse.saleModelConfigPrice["INTERIOR"] ?? 0,
                        saleAdasName: orderResponse.saleModelConfigName["ADAS"] ?? "",
                        saleAdasPrice: orderResponse.saleModelConfigPrice["ADAS"] ?? 0,
                        totalPrice: orderResponse.totalPrice
                    )
                    self.modelAction?.updateOrder(
                        orderNum: orderResponse.orderNum,
                        orderTime: orderResponse.orderTime
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
                ServiceContainer.marketingService.deleteWishlist(orderNum: vehiclePo.id) { (result: Result<TspResponse<NoReply>, Error>) in
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
        self.modelRouter?.routeToModelConfig()
    }
    func onTapOrder() {
        if let vehiclePo = VehicleManager.shared.getCurrentVehicle() {
            modelAction?.displayLoading()
            ServiceContainer.marketingService.getWishlist(orderNum: vehiclePo.id) { (result: Result<TspResponse<Wishlist>, Error>) in
                switch result {
                case .success(let res):
                    guard let wishlist = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    AppGlobalState.shared.parameters["saleCode"] = wishlist.saleCode
                    AppGlobalState.shared.parameters["modelCode"] = wishlist.saleModelConfigType["MODEL"]
                    AppGlobalState.shared.parameters["exteriorCode"] = wishlist.saleModelConfigType["EXTERIOR"]
                    AppGlobalState.shared.parameters["interiorCode"] = wishlist.saleModelConfigType["INTERIOR"]
                    AppGlobalState.shared.parameters["wheelCode"] = wishlist.saleModelConfigType["WHEEL"]
                    AppGlobalState.shared.parameters["spareTireCode"] = wishlist.saleModelConfigType["SPARE_TIRE"]
                    AppGlobalState.shared.parameters["adasCode"] = wishlist.saleModelConfigType["ADAS"]
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
        var orderNum: String? = nil
        if let id = VehicleManager.shared.getCurrentVehicleId() {
            orderNum = id
        }
        ServiceContainer.marketingService.earnestMoneyOrder(
            saleCode: AppGlobalState.shared.parameters["saleCode"] as? String ?? "",
            orderNum: orderNum,
            modelCode: AppGlobalState.shared.parameters["modelCode"] as? String ?? "",
            exteriorCode: AppGlobalState.shared.parameters["exteriorCode"] as? String ?? "",
            interiorCode: AppGlobalState.shared.parameters["interiorCode"] as? String ?? "",
            wheelCode: AppGlobalState.shared.parameters["wheelCode"] as? String ?? "",
            spareTireCode: AppGlobalState.shared.parameters["spareTireCode"] as? String ?? "",
            adasCode: AppGlobalState.shared.parameters["adasCode"] as? String ?? "",
            licenseCityCode: licenseCityCode
        ) { (result: Result<TspResponse<String>, Error>) in
            switch result {
            case .success(let res):
                guard let resData = res.data else {
                    self.modelAction?.displayError(text: "请求异常")
                    return
                }
                if let orderNum = orderNum {
                    // 心愿单转换的意向金订单
                    VehicleManager.shared.delete(orderNum: orderNum)
                }
                VehicleManager.shared.add(orderNum: resData, type: .ORDER, displayName: saleModelName)
                VehicleManager.shared.setCurrentVehicleId(id: resData)
                AppGlobalState.shared.needRefresh = true
                let lastView = AppGlobalState.shared.parameters["lastView"] as? String ?? ""
                if lastView == "MODEL_CONFIG" {
                    AppGlobalState.shared.parameters["backCount"] = 1
                }
                AppGlobalState.shared.parameters["licenseCityCode"] = nil
                AppGlobalState.shared.parameters["licenseCityName"] = nil
                self.modelRouter?.closeScreen()
            case .failure(_):
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    func onTapDownPaymentOrder(orderPersonType: Int, purchasePlan: Int, orderPersonName: String, orderPersonIdType: Int, orderPersonIdNum: String, saleModelName: String, licenseCityCode: String, dealership: String, deliveryCenter: String) {
        modelAction?.displayLoading()
        var orderNum: String = ""
        if let id = VehicleManager.shared.getCurrentVehicleId() {
            orderNum = id
        }
        ServiceContainer.marketingService.downPaymentOrder(
            saleCode: AppGlobalState.shared.parameters["saleCode"] as? String ?? "",
            orderNum: orderNum,
            modelCode: AppGlobalState.shared.parameters["modelCode"] as? String ?? "",
            exteriorCode: AppGlobalState.shared.parameters["exteriorCode"] as? String ?? "",
            interiorCode: AppGlobalState.shared.parameters["interiorCode"] as? String ?? "",
            wheelCode: AppGlobalState.shared.parameters["wheelCode"] as? String ?? "",
            spareTireCode: AppGlobalState.shared.parameters["spareTireCode"] as? String ?? "",
            adasCode: AppGlobalState.shared.parameters["adasCode"] as? String ?? "",
            orderPersonType: orderPersonType,
            purchasePlan: purchasePlan,
            orderPersonName: orderPersonName,
            orderPersonIdType: orderPersonIdType,
            orderPersonIdNum: orderPersonIdNum,
            licenseCityCode: licenseCityCode,
            dealership: dealership,
            deliveryCenter: deliveryCenter
        ) { (result: Result<TspResponse<String>, Error>) in
            switch result {
            case .success(let res):
                if res.isSuccess {
                    guard let resData = res.data else {
                        self.modelAction?.displayError(text: "请求异常")
                        return
                    }
                    if !orderNum.isEmpty {
                        // 心愿单转换的定金订单
                        VehicleManager.shared.delete(orderNum: orderNum)
                    }
                    VehicleManager.shared.add(orderNum: resData, type: .ORDER, displayName: saleModelName)
                    VehicleManager.shared.setCurrentVehicleId(id: resData)
                    AppGlobalState.shared.needRefresh = true
                    let lastView = AppGlobalState.shared.parameters["lastView"] as? String ?? ""
                    if lastView == "MODEL_CONFIG" {                        AppGlobalState.shared.parameters["backCount"] = 1
                    }
                    AppGlobalState.shared.parameters["licenseCityCode"] = nil
                    AppGlobalState.shared.parameters["licenseCityName"] = nil
                    AppGlobalState.shared.parameters["dealershipCode"] = nil
                    AppGlobalState.shared.parameters["dealershipName"] = nil
                    AppGlobalState.shared.parameters["deliveryCenterCode"] = nil
                    AppGlobalState.shared.parameters["deliveryCenterName"] = nil
                    self.modelRouter?.closeScreen()
                } else {
                    self.modelAction?.displayError(text: res.message ?? "请求异常")
                }
            case .failure(_):
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    func onUpdateOrderPersonName(name: String) {
        modelAction?.updateOrderPersonName(name: name)
    }
    func onUpdateOrderPersonIdNum(idNum: String) {
        modelAction?.updateOrderPersonIdNum(idNum: idNum)
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
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            modelAction?.displayLoading()
            ServiceContainer.marketingService.cancelOrder(orderNum: orderNum) { (result: Result<TspResponse<NoReply>, Error>) in
                switch result {
                case .success(_):
                    VehicleManager.shared.delete(orderNum: orderNum)
                    self.modelRouter?.closeScreen()
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    func onTapPayOrder(orderPaymentPhase: Int, paymentAmount: Decimal, paymentChannel: String) {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            modelAction?.displayLoading()
            ServiceContainer.marketingService.payOrder(orderNum: orderNum, orderPaymentPhase: orderPaymentPhase, paymentAmount: paymentAmount, paymentChannel: paymentChannel) { [weak self] (result: Result<TspResponse<OrderPaymentResponse>, Error>) in
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
                        VehicleManager.shared.updateSubState(id: orderNum, subState: nextSubState)
                        
                        // 如果原来是心愿单，支付后应变为订单类型
                        if let vehicle = VehicleManager.shared.getCurrentVehicle(), vehicle.type == .WISHLIST {
                            VehicleManager.shared.add(orderNum: orderNum, type: .ORDER, subState: nextSubState, displayName: vehicle.displayName)
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
    func onTapEarnestMoneyToDownPayment() {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            modelAction?.displayLoading()
            ServiceContainer.marketingService.earnestMoneyToDownPayment(orderNum: orderNum) { [weak self] (result: Result<TspResponse<NoReply>, Error>) in
                switch result {
                case .success(_):
                    // 更新为定金待支付状态
                    VehicleManager.shared.updateSubState(id: orderNum, subState: 300)
                    AppGlobalState.shared.needRefresh = true
                    self?.viewOnAppear()
                case .failure(_):
                    self?.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    func onTapLockOrder() {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            modelAction?.displayLoading()
            ServiceContainer.marketingService.lockOrder(orderNum: orderNum) { [weak self] (result: Result<TspResponse<NoReply>, Error>) in
                switch result {
                case .success(let res):
                    if res.isSuccess {
                        // 更新本地状态为：安排生产
                        VehicleManager.shared.updateSubState(id: orderNum, subState: 400)
                        AppGlobalState.shared.needRefresh = true
                        // 原地刷新视图
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
}

