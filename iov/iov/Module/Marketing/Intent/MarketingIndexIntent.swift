//
//  VehicleIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

class MarketingIndexIntent: MviIntentProtocol {
    private weak var modelAction: MarketingIndexModelActionProtocol?
    private weak var modelRouter: MarketingIndexModelRouterProtocol?
    
    init(model: MarketingIndexModelActionProtocol & MarketingIndexModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    func viewOnAppear() {
        modelAction?.displayLoading()
        if UserManager.isLogin() {
            ServiceContainer.marketingService.getValidVehicleSaleOrderList { [weak self] (result: Result<TspResponse<[VehicleSaleOrder]>, Error>) in
                switch result {
                case .success(let res):
                    if res.isSuccess {
                        guard let resData = res.data else {
                            self?.modelAction?.displayNoOrder()
                            return
                        }
                        VehicleManager.shared.update(vehicleSaleOrderList: resData)
                        if VehicleManager.shared.hasOrder() {
                            if let vehiclePo = VehicleManager.shared.getCurrentVehicle(), let vehicleId = VehicleManager.shared.getCurrentVehicleId() {
                                switch vehiclePo.type {
                                case .WISHLIST:
                                    ServiceContainer.marketingService.getWishlist(orderNum: vehicleId) { (result: Result<TspResponse<Wishlist>, Error>) in
                                        switch result {
                                        case .success(let res):
                                            guard let wishlist = res.data else {
                                                self?.modelAction?.displayError(text: "数据异常")
                                                return
                                            }
                                            self?.modelAction?.displayWishlist(wishlist: wishlist)
                                        case .failure(_):
                                            self?.modelAction?.displayError(text: "请求异常")
                                        }
                                    }
                                case .ORDER:
                                    ServiceContainer.marketingService.getOrder(orderNum: vehicleId) { (result: Result<TspResponse<Order>, Error>) in
                                        switch result {
                                        case .success(let res):
                                            guard let order = res.data else {
                                                self?.modelAction?.displayError(text: "数据异常")
                                                return
                                            }
                                            self?.modelAction?.displayOrder(order: order)
                                        case .failure(_):
                                            self?.modelAction?.displayError(text: "请求异常")
                                        }
                                    }
                                case .ACTIVATED:
                                    self?.modelAction?.displayVehicle()
                                }
                            }
                        } else {
                            self?.modelAction?.displayNoOrder()
                        }
                    } else {
                        self?.modelAction?.displayError(text: res.message ?? "请求异常")
                    }
                case .failure(_):
                    self?.modelAction?.displayError(text: "请求异常")
                }
            }
        } else {
            self.modelAction?.displayNoOrder()
        }
    }
}

extension MarketingIndexIntent: MarketingIndexIntentProtocol {
    func onTapModelConfig() {
        if UserManager.isLogin() {
            self.modelRouter?.routeToModelConfig()
        } else {
            self.modelRouter?.routeToLogin()
        }
    }
    func onTapOrder() {
        guard let orderNum = VehicleManager.shared.getCurrentVehicleId() else { return }
        ServiceContainer.marketingService.getWishlist(orderNum: orderNum) { [weak self] (result: Result<TspResponse<Wishlist>, Error>) in
            switch result {
            case .success(let res):
                guard let wishlist = res.data else {
                    self?.modelAction?.displayError(text: res.message ?? "请求异常")
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
                AppGlobalState.shared.parameters["lastView"] = "MARKETING_INDEX"
                self?.modelRouter?.routeToOrderDetail()
            case .failure(_):
                self?.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    func onTapWishlistDetail() {
        AppGlobalState.shared.parameters["orderDetailView"] = "WISHLIST"
        self.modelRouter?.routeToOrderDetail()
    }
    func onTapOrderDetail(orderState: OrderState) {
        switch orderState {
        case .WISHLIST:
            break
        case .EARNEST_MONEY_UNPAID:
            AppGlobalState.shared.parameters["orderDetailView"] = "EARNEST_MONEY_UNPAID"
        case .EARNEST_MONEY_PAID:
            AppGlobalState.shared.parameters["orderDetailView"] = "EARNEST_MONEY_PAID"
        case .DOWN_PAYMENT_UNPAID:
            AppGlobalState.shared.parameters["orderDetailView"] = "DOWN_PAYMENT_UNPAID"
        case .DOWN_PAYMENT_PAID:
            AppGlobalState.shared.parameters["orderDetailView"] = "DOWN_PAYMENT_PAID"
        case .ARRANGE_PRODUCTION:
            AppGlobalState.shared.parameters["orderDetailView"] = "ARRANGE_PRODUCTION"
        case .ALLOCATION_VEHICLE, .SHIPPING_APPLY:
            AppGlobalState.shared.parameters["orderDetailView"] = "ALLOCATION_VEHICLE"
        case .PREPARE_TRANSPORT, .TRANSPORTING:
            AppGlobalState.shared.parameters["orderDetailView"] = "PREPARE_TRANSPORT"
        case .PREPARE_DELIVER:
            AppGlobalState.shared.parameters["orderDetailView"] = "PREPARE_DELIVER"
        case .FINAL_PAYMENT_PAID:
            AppGlobalState.shared.parameters["orderDetailView"] = "FINAL_PAYMENT_PAID"
        case .INVOICED:
            AppGlobalState.shared.parameters["orderDetailView"] = "INVOICED"
        case .DELIVERED:
            AppGlobalState.shared.parameters["orderDetailView"] = "DELIVERED"
        case .ACTIVATED:
            break
        }
        self.modelRouter?.routeToOrderDetail()
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
                        
                        if orderPaymentPhase == 3 {
                            AppGlobalState.shared.needRefresh = true
                        }
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
    func onTapCancelOrder() {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            modelAction?.displayLoading()
            ServiceContainer.marketingService.cancelOrder(orderNum: orderNum) { [weak self] (result: Result<TspResponse<NoReply>, Error>) in
                switch result {
                case .success(let res):
                    if res.isSuccess {
                        VehicleManager.shared.delete(orderNum: orderNum)
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
