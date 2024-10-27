//
//  VehicleWishlistIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/13.
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
        if let view = AppGlobalState.shared.parameters["orderDetailView"] as? String {
            AppGlobalState.shared.parameters["orderDetailView"] = nil
            modelAction?.displayLoading()
            switch view {
            case "WISHLIST":
                handleWishlist()
            case "ORDER":
                handleOrder()
            case "EARNEST_MONEY_UNPAID":
                handleEarnestMoneyUnpaid()
            case "EARNEST_MONEY_PAID":
                handleEarnestMoneyPaid()
            case "DOWN_PAYMENT_UNPAID":
                handleDownPaymentUnpaid()
            case "DOWN_PAYMENT_PAID":
                handleDownPaymentPaid()
            case "ARRANGE_PRODUCTION":
                handleArrangeProduction()
            default:
                break
            }
        }
    }
    
    private func handleWishlist() {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            TspApi.getWishlist(orderNum: orderNum) { (result: Result<TspResponse<Wishlist>, Error>) in
                switch result {
                case .success(let res):
                    let wishlist = res.data!
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
        TspApi.getSelectedSaleModel(
            saleCode: AppGlobalState.shared.parameters["saleCode"] as! String,
            modelCode: AppGlobalState.shared.parameters["modelCode"] as! String,
            exteriorCode: AppGlobalState.shared.parameters["exteriorCode"] as! String,
            interiorCode: AppGlobalState.shared.parameters["interiorCode"] as! String,
            wheelCode: AppGlobalState.shared.parameters["wheelCode"] as! String,
            spareTireCode: AppGlobalState.shared.parameters["spareTireCode"] as! String,
            adasCode: AppGlobalState.shared.parameters["adasCode"] as! String
        ) { (result: Result<TspResponse<SelectedSaleModel>, Error>) in
            switch result {
            case .success(let res):
                if res.code == 0 {
                    let selectedSaleModel = res.data!
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
            TspApi.getOrder(orderNum: orderNum) { (result: Result<TspResponse<OrderResponse>, Error>) in
                switch result {
                case .success(let res):
                    let orderResponse = res.data!
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
            TspApi.getOrder(orderNum: orderNum) { (result: Result<TspResponse<OrderResponse>, Error>) in
                switch result {
                case .success(let res):
                    let orderResponse = res.data!
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
            TspApi.getOrder(orderNum: orderNum) { (result: Result<TspResponse<OrderResponse>, Error>) in
                switch result {
                case .success(let res):
                    let orderResponse = res.data!
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
                    self.modelAction?.displayDownPaymentUnpaid()
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    private func handleDownPaymentPaid() {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            TspApi.getOrder(orderNum: orderNum) { (result: Result<TspResponse<OrderResponse>, Error>) in
                switch result {
                case .success(let res):
                    let orderResponse = res.data!
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
            TspApi.getOrder(orderNum: orderNum) { (result: Result<TspResponse<OrderResponse>, Error>) in
                switch result {
                case .success(let res):
                    let orderResponse = res.data!
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
}

extension VehicleOrderDetailIntent: VehicleOrderDetailIntentProtocol {
    func onTapDelete() {
        if let vehiclePo = VehicleManager.shared.getCurrentVehicle() {
            if vehiclePo.type == .WISHLIST {
                TspApi.deleteWishlist(orderNum: vehiclePo.id) { (result: Result<TspResponse<NoReply>, Error>) in
                    switch result {
                    case .success(let res):
                        if res.code == 0 {
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
            TspApi.getWishlist(orderNum: vehiclePo.id) { (result: Result<TspResponse<Wishlist>, Error>) in
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
    func onTapAgreement() {
        self.modelAction?.toggleAgreement()
    }
    func onTapEarnestMoneyOrder(saleModelName: String, licenseCity: String) {
        modelAction?.displayLoading()
        var orderNum: String? = nil
        if let id = VehicleManager.shared.getCurrentVehicleId() {
            orderNum = id
        }
        TspApi.earnestMoneyOrder(
            saleCode: AppGlobalState.shared.parameters["saleCode"] as! String,
            orderNum: orderNum,
            modelCode: AppGlobalState.shared.parameters["modelCode"] as! String,
            exteriorCode: AppGlobalState.shared.parameters["exteriorCode"] as! String,
            interiorCode: AppGlobalState.shared.parameters["interiorCode"] as! String,
            wheelCode: AppGlobalState.shared.parameters["wheelCode"] as! String,
            spareTireCode: AppGlobalState.shared.parameters["spareTireCode"] as! String,
            adasCode: AppGlobalState.shared.parameters["adasCode"] as! String,
            licenseCity: licenseCity
        ) { (result: Result<TspResponse<String>, Error>) in
            switch result {
            case .success(let res):
                if orderNum != nil {
                    // 心愿单转换的意向金订单
                    VehicleManager.shared.delete(orderNum: orderNum!)
                }
                VehicleManager.shared.add(orderNum: res.data!, type: .ORDER, displayName: saleModelName)
                VehicleManager.shared.setCurrentVehicleId(id: res.data!)
                let lastView = AppGlobalState.shared.parameters["lastView"] as! String
                if lastView == "MODEL_CONFIG" {
                    AppGlobalState.shared.parameters["backCount"] = 1
                }
                self.modelRouter?.closeScreen()
            case .failure(_):
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    func onTapDownPaymentOrder(orderType: Int, purchasePlan: Int, orderPersonName: String, orderPersonIdType: Int, orderPersonIdNum: String, saleModelName: String, licenseCity: String, dealership: String, deliveryCenter: String) {
        modelAction?.displayLoading()
        var orderNum: String = ""
        if let id = VehicleManager.shared.getCurrentVehicleId() {
            orderNum = id
        }
        TspApi.downPaymentOrder(
            saleCode: AppGlobalState.shared.parameters["saleCode"] as! String,
            orderNum: orderNum,
            modelCode: AppGlobalState.shared.parameters["modelCode"] as! String,
            exteriorCode: AppGlobalState.shared.parameters["exteriorCode"] as! String,
            interiorCode: AppGlobalState.shared.parameters["interiorCode"] as! String,
            wheelCode: AppGlobalState.shared.parameters["wheelCode"] as! String,
            spareTireCode: AppGlobalState.shared.parameters["spareTireCode"] as! String,
            adasCode: AppGlobalState.shared.parameters["adasCode"] as! String,
            orderType: orderType,
            purchasePlan: purchasePlan,
            orderPersonName: orderPersonName,
            orderPersonIdType: orderPersonIdType,
            orderPersonIdNum: orderPersonIdNum,
            licenseCity: licenseCity,
            dealership: dealership,
            deliveryCenter: deliveryCenter
        ) { (result: Result<TspResponse<String>, Error>) in
            switch result {
            case .success(let res):
                if !orderNum.isEmpty {
                    // 心愿单转换的定金订单
                    VehicleManager.shared.delete(orderNum: orderNum)
                }
                VehicleManager.shared.add(orderNum: res.data!, type: .ORDER, displayName: saleModelName)
                VehicleManager.shared.setCurrentVehicleId(id: res.data!)
                let lastView = AppGlobalState.shared.parameters["lastView"] as! String
                if lastView == "MODEL_CONFIG" {
                    AppGlobalState.shared.parameters["backCount"] = 1
                }
                self.modelRouter?.closeScreen()
            case .failure(_):
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    func onTapLicenseCity() {
        modelRouter?.routeToLicenseArea()
    }
    func onTapCancelOrder() {
        if let orderNum = VehicleManager.shared.getCurrentVehicleId() {
            modelAction?.displayLoading()
            TspApi.cancelOrder(orderNum: orderNum) { (result: Result<TspResponse<NoReply>, Error>) in
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
            TspApi.payOrder(orderNum: orderNum, orderPaymentPhase: orderPaymentPhase, paymentAmount: paymentAmount, paymentChannel: paymentChannel) { (result: Result<TspResponse<OrderPaymentResponse>, Error>) in
                switch result {
                case .success(_):
                    self.modelRouter?.closeScreen()
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
                    self.modelRouter?.closeScreen()
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
                    self.modelRouter?.closeScreen()
                case .failure(_):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
}

