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
        TspApi.getValidVehicleSaleOrderList() { (result: Result<TspResponse<[VehicleSaleOrder]>, Error>) in
            switch result {
            case .success(let res):
                if res.code == 0 {
                    VehicleManager.shared.update(vehicleSaleOrderList: res.data!)
                    if VehicleManager.shared.hasOrder() {
                        if let vehiclePo = VehicleManager.shared.getCurrentVehicle() {
                            switch vehiclePo.type {
                            case .WISHLIST:
                                TspApi.getWishlist(orderNum: VehicleManager.shared.getCurrentVehicleId()!) { (result: Result<TspResponse<Wishlist>, Error>) in
                                    switch result {
                                    case .success(let res):
                                        self.modelAction?.displayWishlist(wishlist: res.data!)
                                    case .failure(_):
                                        self.modelAction?.displayError(text: "请求异常")
                                    }
                                }
                            case .ORDER:
                                TspApi.getOrder(orderNum: VehicleManager.shared.getCurrentVehicleId()!) { (result: Result<TspResponse<OrderResponse>, Error>) in
                                    switch result {
                                    case .success(let res):
                                        self.modelAction?.displayOrder(order: res.data!)
                                    case .failure(_):
                                        self.modelAction?.displayError(text: "请求异常")
                                    }
                                }
                            case .ACTIVATED:
                                self.modelAction?.displayVehicle()
                            }
                        }
                    } else {
                        self.modelAction?.displayNoOrder()
                    }
                } else {
                    self.modelAction?.displayError(text: res.message ?? "请求异常")
                }
            case .failure(_):
                self.modelAction?.displayError(text: "请求异常")
            }
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
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            TspApi.getWishlist(orderNum: orderNum) { (result: Result<TspResponse<Wishlist>, Error>) in
                switch result {
                case .success(let res):
                    let wishlist = res.data!
                    AppGlobalState.shared.parameters["saleCode"] = wishlist.saleCode
                    AppGlobalState.shared.parameters["modelCode"] = wishlist.saleModelConfigType["MODEL"]
                    AppGlobalState.shared.parameters["exteriorCode"] = wishlist.saleModelConfigType["EXTERIOR"]
                    AppGlobalState.shared.parameters["interiorCode"] = wishlist.saleModelConfigType["INTERIOR"]
                    AppGlobalState.shared.parameters["wheelCode"] = wishlist.saleModelConfigType["WHEEL"]
                    AppGlobalState.shared.parameters["spareTireCode"] = wishlist.saleModelConfigType["SPARE_TIRE"]
                    AppGlobalState.shared.parameters["adasCode"] = wishlist.saleModelConfigType["ADAS"]
                    AppGlobalState.shared.parameters["orderDetailView"] = "ORDER"
                    AppGlobalState.shared.parameters["lastView"] = "MARKETING_INDEX"
                    self.modelRouter?.routeToOrderDetail()
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
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
        case .PREPARE_TRANSPORT:
            AppGlobalState.shared.parameters["orderDetailView"] = "PREPARE_TRANSPORT"
        case .PREPARE_DELIVER:
            AppGlobalState.shared.parameters["orderDetailView"] = "PREPARE_DELIVER"
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
            TspApi.payOrder(orderNum: orderNum, orderPaymentPhase: orderPaymentPhase, paymentAmount: paymentAmount, paymentChannel: paymentChannel) { (result: Result<TspResponse<OrderPaymentResponse>, Error>) in
                switch result {
                case .success(_):
                    if orderPaymentPhase == 3 {
                        AppGlobalState.shared.needRefresh = true
                    }
                    self.viewOnAppear()
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    func onTapCancelOrder() {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            modelAction?.displayLoading()
            TspApi.cancelOrder(orderNum: orderNum) { (result: Result<TspResponse<NoReply>, Error>) in
                switch result {
                case .success(let res):
                    if res.code == 0 {
                        VehicleManager.shared.delete(orderNum: orderNum)
                        self.viewOnAppear()
                    } else {
                        self.modelAction?.displayError(text: res.message ?? "请求异常")
                    }
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    func onTapEarnestMoneyToDownPayment() {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            modelAction?.displayLoading()
            TspApi.earnestMoneyToDownPayment(orderNum: orderNum) { (result: Result<TspResponse<NoReply>, Error>) in
                switch result {
                case .success(_):
                    self.viewOnAppear()
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    func onTapLockOrder() {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            modelAction?.displayLoading()
            TspApi.lockOrder(orderNum: orderNum) { (result: Result<TspResponse<NoReply>, Error>) in
                switch result {
                case .success(_):
                    self.viewOnAppear()
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
}
