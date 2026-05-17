//
//  VehicleWishlistPage.swift
//  iov
//
//  Created by hwyz_leo on 2024/10/13.
//

import SwiftUI
import Kingfisher

/// 车辆订单详情页
struct VehicleOrderDetailPage: View {
    @EnvironmentObject var globalState: AppGlobalState
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
                    dynamicConfigs: state.dynamicConfigs,
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
                    orderPersonType: state.orderPersonType,
                    purchasePlan: state.purchasePlan,
                    saleModelPrice: state.saleModelPrice,
                    dynamicConfigs: state.dynamicConfigs,
                    totalPrice: state.totalPrice,
                    selectLicenseCityName: state.selectLicenseCityName,
                    selectLicenseCityCode: state.selectLicenseCityCode,
                    selectDealershipName: state.selectDealershipName,
                    selectDealershipCode: state.selectDealershipCode,
                    selectDeliveryCenterName: state.selectDeliveryCenterName,
                    selectDeliveryCenterCode: state.selectDeliveryCenterCode
                )
            case .earnestMoneyUnpaid:
                EarnestMoneyUnpaid(
                    container: container,
                    saleModelImages: state.saleModelImages,
                    saleModelName: state.saleModelName,
                    saleModelDesc: state.saleModelDesc,
                    saleModelPrice: state.saleModelPrice,
                    dynamicConfigs: state.dynamicConfigs,
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
                    dynamicConfigs: state.dynamicConfigs,
                    totalPrice: state.totalPrice,
                    orderNum: state.orderNum,
                    orderTime: state.orderTime,
                    selectLicenseCityName: state.selectLicenseCityName,
                    selectLicenseCityCode: state.selectLicenseCityCode
                )
            case .downPaymentUnpaid:
                DownPaymentUnpaid(
                    container: container,
                    saleModelImages: state.saleModelImages,
                    saleModelName: state.saleModelName,
                    saleModelDesc: state.saleModelDesc,
                    saleModelPrice: state.saleModelPrice,
                    dynamicConfigs: state.dynamicConfigs,
                    totalPrice: state.totalPrice,
                    orderNum: state.orderNum,
                    orderTime: state.orderTime,
                    orderPersonType: state.orderPersonType,
                    purchasePlan: state.purchasePlan,
                    orderPersonIdType: state.orderPersonIdType
                )
            case .downPaymentPaid:
                DownPaymentPaid(
                    container: container,
                    saleModelImages: state.saleModelImages,
                    saleModelName: state.saleModelName,
                    saleModelDesc: state.saleModelDesc,
                    saleModelPrice: state.saleModelPrice,
                    dynamicConfigs: state.dynamicConfigs,
                    totalPrice: state.totalPrice,
                    orderNum: state.orderNum,
                    orderTime: state.orderTime
                )
            case .arrangeProduction:
                ArrangeProduction(
                    container: container,
                    saleModelImages: state.saleModelImages,
                    saleModelName: state.saleModelName,
                    saleModelDesc: state.saleModelDesc,
                    saleModelPrice: state.saleModelPrice,
                    dynamicConfigs: state.dynamicConfigs,
                    totalPrice: state.totalPrice,
                    orderNum: state.orderNum,
                    orderTime: state.orderTime
                )
            case .allocationVehicle:
                AllocationVehicle(
                    container: container,
                    saleModelImages: state.saleModelImages,
                    saleModelName: state.saleModelName,
                    saleModelDesc: state.saleModelDesc,
                    saleModelPrice: state.saleModelPrice,
                    dynamicConfigs: state.dynamicConfigs,
                    totalPrice: state.totalPrice,
                    orderNum: state.orderNum,
                    orderTime: state.orderTime
                )
            case .prepareTransport:
                PrepareTransport(
                    container: container,
                    saleModelImages: state.saleModelImages,
                    saleModelName: state.saleModelName,
                    saleModelDesc: state.saleModelDesc,
                    saleModelPrice: state.saleModelPrice,
                    dynamicConfigs: state.dynamicConfigs,
                    totalPrice: state.totalPrice,
                    orderNum: state.orderNum,
                    orderTime: state.orderTime
                )
            case .prepareDeliver:
                PrepareDeliver(
                    container: container,
                    saleModelImages: state.saleModelImages,
                    saleModelName: state.saleModelName,
                    saleModelDesc: state.saleModelDesc,
                    saleModelPrice: state.saleModelPrice,
                    dynamicConfigs: state.dynamicConfigs,
                    totalPrice: state.totalPrice,
                    orderNum: state.orderNum,
                    orderTime: state.orderTime
                )
            case .finalPaymentPaid:
                FinalPaymentPaid(
                    container: container,
                    saleModelImages: state.saleModelImages,
                    saleModelName: state.saleModelName,
                    saleModelDesc: state.saleModelDesc,
                    saleModelPrice: state.saleModelPrice,
                    dynamicConfigs: state.dynamicConfigs,
                    totalPrice: state.totalPrice,
                    orderNum: state.orderNum,
                    orderTime: state.orderTime
                )
            case .invoiced:
                Invoiced(
                    container: container,
                    saleModelImages: state.saleModelImages,
                    saleModelName: state.saleModelName,
                    saleModelDesc: state.saleModelDesc,
                    saleModelPrice: state.saleModelPrice,
                    dynamicConfigs: state.dynamicConfigs,
                    totalPrice: state.totalPrice,
                    orderNum: state.orderNum,
                    orderTime: state.orderTime
                )
            case .delivered:
                Delivered(
                    container: container,
                    saleModelImages: state.saleModelImages,
                    saleModelName: state.saleModelName,
                    saleModelDesc: state.saleModelDesc,
                    saleModelPrice: state.saleModelPrice,
                    dynamicConfigs: state.dynamicConfigs,
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
        .onChange(of: globalState.needCloseOrderDetail) { _ in
            if globalState.needCloseOrderDetail {
                globalState.needCloseOrderDetail = false
                state.routerSubject.close.send()
            }
        }
        .modifier(MarketingRouter(subjects: state.routerSubject))
    }
}
