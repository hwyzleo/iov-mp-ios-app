//
//  VehicleWishlistModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/13.
//

import SwiftUI

final class VehicleOrderDetailModel: ObservableObject, VehicleOrderDetailModelStateProtocol {
    @Published var contentState: MarketingTypes.Model.VehicleOrderDetailContentState = .wishlist
    let routerSubject = MarketingRouter.Subjects()
    var saleModelImages: [String] = []
    @Published var saleModelName: String = ""
    @Published var saleModelPrice: Decimal = 0
    @Published var saleSpareTireName: String = ""
    @Published var saleSpareTirePrice: Decimal = 0
    @Published var saleExteriorName: String = ""
    @Published var saleExteriorPrice: Decimal = 0
    @Published var saleWheelName: String = ""
    @Published var saleWheelPrice: Decimal = 0
    @Published var saleInteriorName: String = ""
    @Published var saleInteriorPrice: Decimal = 0
    @Published var saleAdasName: String = ""
    @Published var saleAdasPrice: Decimal = 0
    @Published var totalPrice: Decimal = 0
    var saleModelDesc: String = ""
    var purchaseBenefitsIntro: String = ""
    var downPayment: Bool = false
    var downPaymentPrice: Decimal = 0
    var earnestMoney: Bool = false
    var earnestMoneyPrice: Decimal = 0
    var orderNum: String = ""
    var orderTime: Int64 = 0
    @Published var selectBookMethod: String = ""
    @Published var agreementIsChecked: Bool = false
    @Published var selectLicenseCityName: String = ""
    @Published var selectLicenseCityCode: String = ""
    @Published var orderType: Int = 0
    @Published var purchasePlan: Int = 0
}

// MARK: - Action Protocol

extension VehicleOrderDetailModel: VehicleOrderDetailModelActionProtocol {
    func updateSaleModelImages(saleModelImages: [String]) {
        self.saleModelImages = saleModelImages
    }
    func updateSaleModelIntro(saleModelName: String, saleModelDesc: String) {
        self.saleModelName = saleModelName
        self.saleModelDesc = saleModelDesc
    }
    func updateBookMethod(downPayment: Bool, downPaymentPrice: Decimal, earnestMoney: Bool, earnestMoneyPrice: Decimal, purchaseDenefitsIntro: String) {
        self.downPayment = downPayment
        self.downPaymentPrice = downPaymentPrice
        self.earnestMoney = earnestMoney
        self.earnestMoneyPrice = earnestMoneyPrice
        self.purchaseBenefitsIntro = purchaseDenefitsIntro
    }
    func updateSaleModelPrice(saleModelName: String, saleModelPrice: Decimal, saleSpareTireName: String, saleSpareTirePrice: Decimal, saleExteriorName: String, saleExteriorPrice: Decimal, saleWheelName: String, saleWheelPrice: Decimal, saleInteriorName: String, saleInteriorPrice: Decimal, saleAdasName: String, saleAdasPrice: Decimal, totalPrice: Decimal) {
        self.saleModelName = saleModelName
        self.saleModelPrice = saleModelPrice
        self.saleSpareTireName = saleSpareTireName
        self.saleSpareTirePrice = saleSpareTirePrice
        self.saleExteriorName = saleExteriorName
        self.saleExteriorPrice = saleExteriorPrice
        self.saleWheelName = saleWheelName
        self.saleWheelPrice = saleWheelPrice
        self.saleInteriorName = saleInteriorName
        self.saleInteriorPrice = saleInteriorPrice
        self.saleAdasName = saleAdasName
        self.saleAdasPrice = saleAdasPrice
        self.totalPrice = totalPrice
    }
    func updateOrder(orderNum: String, orderTime: Int64) {
        self.orderNum = orderNum
        self.orderTime = orderTime
    }
    func updateSelectBookMethod(bookMethod: String) {
        self.selectBookMethod = bookMethod
    }
    func updateSelectOrderType(orderType: Int) {
        self.orderType = orderType
    }
    func updateSelectPurchasePlan(purchasePlan: Int) {
        self.purchasePlan = purchasePlan
    }
    func toggleAgreement() {
        self.agreementIsChecked.toggle()
    }
    func displayWishlist() {
        contentState = .wishlist
    }
    func displayOrder() {
        contentState = .order
    }
    func displayEarnestMoneyUnpaid() {
        contentState = .earnestMoneyUnpaid
    }
    func displayEarnestMoneyPaid() {
        contentState = .earnestMoneyPaid
    }
    func displayDownPaymentUnpaid() {
        contentState = .downPaymentUnpaid
    }
    func displayDownPaymentPaid() {
        contentState = .downPaymentPaid
    }
    func displayArrangeProduction() {
        contentState = .arrangeProduction
    }
    func displayLoading() {
        contentState = .loading
    }
    func displayError(text: String) {
        contentState = .error(text: text)
    }
}

// MARK: - Route

extension VehicleOrderDetailModel: VehicleOrderDetailModelRouterProtocol {
    func closeScreen() {
        routerSubject.close.send()
    }
    func routeToMarketingIndex() {
        routerSubject.close.send()
    }
    func routeToModelConfig() {
        routerSubject.screen.send(.modelConfig)
    }
    func routeToLicenseArea() {
        routerSubject.screen.send(.licenseArea)
    }
}

extension MarketingTypes.Model {
    enum VehicleOrderDetailContentState {
        case loading
        case wishlist
        case order
        case earnestMoneyUnpaid
        case earnestMoneyPaid
        case downPaymentUnpaid
        case downPaymentPaid
        case arrangeProduction
        case error(text: String)
    }
}
