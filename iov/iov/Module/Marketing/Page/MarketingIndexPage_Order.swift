//
//  VehicleIndexPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

import SwiftUI
import Kingfisher

/// 购车首页 - 有订单页
extension MarketingIndexPage {
    struct Order: View {
        @StateObject var container: MviContainer<MarketingIndexIntentProtocol, MarketingIndexModelStateProtocol>
        private var intent: MarketingIndexIntentProtocol { container.intent }
        var currentVehicleType: VehicleType
        var orderState: OrderState
        var saleModelImages: [String]
        var totalPrice: Decimal
        var saleModelDesc: String
        
        @State private var currentIndex = 0
        
        var body: some View {
            VStack(spacing: AppTheme.layout.spacing) {
                Spacer().frame(height: kStatusBarHeight)
                if let vehiclePo = VehicleManager.shared.getCurrentVehicle() {
                    HStack {
                        Text(vehiclePo.displayName)
                            .font(AppTheme.fonts.title1)
                            .foregroundColor(AppTheme.colors.fontPrimary)
                        Image("icon_arrow_up_down")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(AppTheme.colors.brandMain)
                            .frame(width: 20, height: 20)
                        Spacer()
                    }
                    .padding(.horizontal, AppTheme.layout.margin)
                }
                
                ScrollView {
                    VStack(spacing: AppTheme.layout.spacing) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                if currentVehicleType == .ORDER {
                                    Text(orderStateTitle)
                                        .font(AppTheme.fonts.title1)
                                        .bold()
                                        .foregroundColor(AppTheme.colors.fontPrimary)
                                } else {
                                    Text(LocalizedStringKey("my_wishlist"))
                                        .font(AppTheme.fonts.title1)
                                        .bold()
                                        .foregroundColor(AppTheme.colors.fontPrimary)
                                }
                                Spacer()
                            }
                            
                            // 车辆轮播图 (采用探索页走马灯样式)
                            ZStack(alignment: .bottom) {
                                TabView(selection: $currentIndex) {
                                    ForEach(0..<saleModelImages.count, id: \.self) { index in
                                        ZStack {
                                            if !saleModelImages[index].isEmpty {
                                                KFImage(URL(string: saleModelImages[index])!)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 200)
                                            }
                                        }
                                        .tag(index)
                                    }
                                }
                                .tabViewStyle(.page(indexDisplayMode: .never))
                                .frame(height: 200)
                                .cornerRadius(AppTheme.layout.radiusMedium)
                                
                                // 自定义指示器
                                HStack(spacing: 6) {
                                    ForEach(0..<saleModelImages.count, id: \.self) { index in
                                        Capsule()
                                            .fill(currentIndex == index ? AppTheme.colors.brandMain : Color.white.opacity(0.3))
                                            .frame(width: currentIndex == index ? 16 : 6, height: 4)
                                            .animation(.spring(), value: currentIndex)
                                    }
                                }
                                .padding(.bottom, 12)
                            }
                            
                            HStack {
                                Text(LocalizedStringKey("selected_config"))
                                    .font(AppTheme.fonts.body)
                                    .foregroundColor(AppTheme.colors.fontPrimary)
                                Spacer()
                                Text("￥\(totalPrice.formatted())")
                                    .font(AppTheme.fonts.body)
                                    .foregroundColor(AppTheme.colors.brandMain)
                            }
                            
                            Text(saleModelDesc)
                                .font(AppTheme.fonts.subtext)
                                .foregroundColor(AppTheme.colors.fontSecondary)
                                .lineLimit(2)
                            
                            // 操作按钮区
                            HStack(spacing: 16) {
                                if currentVehicleType == .ORDER {
                                    orderActionButtons
                                } else {
                                    RoundedCornerButton(
                                        nameLocal: LocalizedStringKey("order_now"),
                                        color: .black,
                                        bgColor: AppTheme.colors.brandMain
                                    ) {
                                        intent.onTapOrder()
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                        .appCardStyle()
                        .onTapGesture {
                            if currentVehicleType == .ORDER {
                                intent.onTapOrderDetail(orderState: orderState)
                            } else {
                                intent.onTapWishlistDetail()
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.layout.margin)
                }
                .scrollIndicators(.hidden)
            }
            .appBackground()
        }
        
        @ViewBuilder
        private var orderActionButtons: some View {
            switch orderState {
            case .EARNEST_MONEY_UNPAID:
                RoundedCornerButton(nameLocal: LocalizedStringKey("cancel_order"), bgColor: AppTheme.colors.fontTertiary) {
                    intent.onTapCancelOrder()
                }
                RoundedCornerButton(nameLocal: LocalizedStringKey("pay_earnest_money"), color: .black, bgColor: AppTheme.colors.brandMain) {
                    intent.onTapPayOrder(orderPaymentPhase: 1, paymentAmount: 5000, paymentChannel: "ALIPAY")
                }
            case .EARNEST_MONEY_PAID:
                RoundedCornerButton(nameLocal: LocalizedStringKey("request_refund"), bgColor: AppTheme.colors.fontTertiary) {
                    intent.onTapCancelOrder()
                }
                RoundedCornerButton(nameLocal: LocalizedStringKey("earnest_money_to_down_payment"), color: .black, bgColor: AppTheme.colors.brandMain) {
                    intent.onTapOrderDetail(orderState: orderState)
                }
            case .DOWN_PAYMENT_UNPAID:
                RoundedCornerButton(nameLocal: LocalizedStringKey("cancel_order"), bgColor: AppTheme.colors.fontTertiary) {
                    intent.onTapCancelOrder()
                }
                RoundedCornerButton(nameLocal: LocalizedStringKey("pay_down_payment"), color: .black, bgColor: AppTheme.colors.brandMain) {
                    intent.onTapPayOrder(orderPaymentPhase: 2, paymentAmount: 5000, paymentChannel: "ALIPAY")
                }
            case .DOWN_PAYMENT_PAID:
                RoundedCornerButton(nameLocal: LocalizedStringKey("lock_order"), color: .black, bgColor: AppTheme.colors.brandMain) {
                    intent.onTapLockOrder()
                }
            case .FINAL_PAYMENT_PAID:
                RoundedCornerButton(nameLocal: LocalizedStringKey("final_payment_paid"), color: .black, bgColor: AppTheme.colors.fontTertiary) {
                    // 已支付尾款，等待提车
                }
            case .INVOICED:
                RoundedCornerButton(nameLocal: LocalizedStringKey("invoiced"), color: .black, bgColor: AppTheme.colors.fontTertiary) {
                    // 已开票
                }
            case .DELIVERED:
                RoundedCornerButton(nameLocal: LocalizedStringKey("delivered"), color: .black, bgColor: AppTheme.colors.fontTertiary) {
                    // 已提车
                }
            default:
                RoundedCornerButton(nameLocal: LocalizedStringKey("pay_final_payment"), color: .black, bgColor: AppTheme.colors.brandMain) {
                    intent.onTapPayOrder(orderPaymentPhase: 3, paymentAmount: 183888, paymentChannel: "ALIPAY")
                }
            }
        }
        
        private var orderStateTitle: LocalizedStringKey {
            switch orderState {
            case .EARNEST_MONEY_UNPAID: return "earnest_money_to_be_paid"
            case .EARNEST_MONEY_PAID: return "earnest_money_paid"
            case .DOWN_PAYMENT_UNPAID: return "down_payment_to_be_paid"
            case .DOWN_PAYMENT_PAID: return "down_payment_paid"
            case .ARRANGE_PRODUCTION: return "arrange_production"
            case .ALLOCATION_VEHICLE, .SHIPPING_APPLY: return "allocation_vehicle"
            case .PREPARE_TRANSPORT, .TRANSPORTING: return "prepare_transport"
            case .PREPARE_DELIVER: return "prepare_deliver"
            case .FINAL_PAYMENT_PAID: return "final_payment_paid"
            case .INVOICED: return "invoiced"
            case .DELIVERED: return "delivered"
            default: return "my_order"
            }
        }
    }
}

struct MarketingIndexPage_Order_Previews: PreviewProvider {
    static var previews: some View {
        MarketingIndexPage.Order(
            container: MarketingIndexPage.buildContainer(),
            currentVehicleType: .WISHLIST,
            orderState: .WISHLIST,
            saleModelImages: [
                "https://pic.imgdb.cn/item/67065b68d29ded1a8c999b62.png",
                "https://pic.imgdb.cn/item/670685e4d29ded1a8cb9c55f.png"
            ],
            totalPrice: 188888,
            saleModelDesc: "寒01七座版 | 有备胎 | 翡翠绿车漆 | 21寸轮毂(四季胎)高亮黑 | 乌木黑内饰 | 高阶智驾"
        )
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
