//
//  VehicleWishlistPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/13.
//

import SwiftUI
import Kingfisher

/// 车辆订单详情页
struct VehicleOrderDetailPage: View {
    @StateObject var container: MviContainer<VehicleOrderDetailIntentProtocol, VehicleOrderDetailModelStateProtocol>
    private var intent: VehicleOrderDetailIntentProtocol { container.intent }
    private var state: VehicleOrderDetailModelStateProtocol { container.model }

    var body: some View {
        ZStack {
            switch state.contentState {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(2)
            case .wishlist:
                Wishlist(
                    container: container,
                    saleModelImages: state.saleModelImages,
                    saleModelName: state.saleModelName,
                    saleModelPrice: state.saleModelPrice,
                    saleSpareTireName: state.saleSpareTireName,
                    saleSpareTirePrice: state.saleSpareTirePrice,
                    saleExteriorName: state.saleExteriorName,
                    saleExteriorPrice: state.saleExteriorPrice,
                    saleWheelName: state.saleWheelName,
                    saleWheelPrice: state.saleWheelPrice,
                    saleInteriorName: state.saleInteriorName,
                    saleInteriorPrice: state.saleInteriorPrice,
                    saleAdasName: state.saleAdasName,
                    saleAdasPrice: state.saleAdasPrice,
                    totalPrice: state.totalPrice
                )
            case .order:
                Order(
                    container: container,
                    saleModelImages: state.saleModelImages,
                    saleModelName: state.saleModelName,
                    saleModelDesc: state.saleModelDesc,
                    downPayment: state.downPayment,
                    downPaymentPrice: state.downPaymentPrice,
                    earnestMoney: state.earnestMoney,
                    earnestMoneyPrice: state.earnestMoneyPrice,
                    purchaseBenefitsIntro: state.purchaseBenefitsIntro,
                    saleModelPrice: state.saleModelPrice,
                    saleSpareTireName: state.saleSpareTireName,
                    saleSpareTirePrice: state.saleSpareTirePrice,
                    saleExteriorName: state.saleExteriorName,
                    saleExteriorPrice: state.saleExteriorPrice,
                    saleWheelName: state.saleWheelName,
                    saleWheelPrice: state.saleWheelPrice,
                    saleInteriorName: state.saleInteriorName,
                    saleInteriorPrice: state.saleInteriorPrice,
                    saleAdasName: state.saleAdasName,
                    saleAdasPrice: state.saleAdasPrice,
                    totalPrice: state.totalPrice
                )
            case .earnestMoneyUnpaid:
                EarnestMoneyUnpaid(
                    container: container,
                    saleModelImages: state.saleModelImages,
                    saleModelName: state.saleModelName,
                    saleModelDesc: state.saleModelDesc,
                    saleModelPrice: state.saleModelPrice, 
                    saleSpareTireName: state.saleSpareTireName,
                    saleSpareTirePrice: state.saleSpareTirePrice,
                    saleExteriorName: state.saleExteriorName,
                    saleExteriorPrice: state.saleExteriorPrice,
                    saleWheelName: state.saleWheelName,
                    saleWheelPrice: state.saleWheelPrice,
                    saleInteriorName: state.saleInteriorName,
                    saleInteriorPrice: state.saleInteriorPrice,
                    saleAdasName: state.saleAdasName,
                    saleAdasPrice: state.saleAdasPrice,
                    totalPrice: state.totalPrice,
                    orderNum: state.orderNum,
                    orderTime: state.orderTime
                )
            case .earnestMoneyPaid:
                EarnestMoneyPaid(
                    container: container,
                    saleModelImages: state.saleModelImages,
                    saleModelName: state.saleModelName,
                    saleModelDesc: state.saleModelDesc,
                    saleModelPrice: state.saleModelPrice,
                    saleSpareTireName: state.saleSpareTireName,
                    saleSpareTirePrice: state.saleSpareTirePrice,
                    saleExteriorName: state.saleExteriorName,
                    saleExteriorPrice: state.saleExteriorPrice,
                    saleWheelName: state.saleWheelName,
                    saleWheelPrice: state.saleWheelPrice,
                    saleInteriorName: state.saleInteriorName,
                    saleInteriorPrice: state.saleInteriorPrice,
                    saleAdasName: state.saleAdasName,
                    saleAdasPrice: state.saleAdasPrice,
                    totalPrice: state.totalPrice,
                    orderNum: state.orderNum,
                    orderTime: state.orderTime
                )
            case .downPaymentPaid:
                DownPaymentPaid(
                    container: container,
                    saleModelImages: state.saleModelImages,
                    saleModelName: state.saleModelName,
                    saleModelDesc: state.saleModelDesc,
                    saleModelPrice: state.saleModelPrice,
                    saleSpareTireName: state.saleSpareTireName,
                    saleSpareTirePrice: state.saleSpareTirePrice,
                    saleExteriorName: state.saleExteriorName,
                    saleExteriorPrice: state.saleExteriorPrice,
                    saleWheelName: state.saleWheelName,
                    saleWheelPrice: state.saleWheelPrice,
                    saleInteriorName: state.saleInteriorName,
                    saleInteriorPrice: state.saleInteriorPrice,
                    saleAdasName: state.saleAdasName,
                    saleAdasPrice: state.saleAdasPrice,
                    totalPrice: state.totalPrice,
                    orderNum: state.orderNum,
                    orderTime: state.orderTime
                )
            case let .error(text):
                ErrorTip(text: text)
            }
        }
        .onAppear {
            intent.viewOnAppear()
        }
        .modifier(MarketingRouter(subjects: state.routerSubject))
    }
}
