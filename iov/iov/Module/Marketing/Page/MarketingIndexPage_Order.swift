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
        
        var body: some View {
            VStack {
                if let vehiclePo = VehicleManager.shared.getCurrentVehicle() {
                    HStack {
                        Text(vehiclePo.displayName)
                        Image("icon_arrow_double")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Spacer()
                    }
                }
                ScrollView {
                    VStack {
                        Button(action: {
                            if currentVehicleType == .ORDER {
                                intent.onTapOrderDetail(orderState: orderState)
                            } else {
                                intent.onTapWishlistDetail()
                            }
                        }) {
                            VStack {
                                Spacer().frame(height: 20)
                                HStack {
                                    if currentVehicleType == .ORDER {
                                        switch orderState {
                                        case .EARNEST_MONEY_UNPAID:
                                            Text(LocalizedStringKey("earnest_money_to_be_paid"))
                                                .bold()
                                                .font(.system(size: 20))
                                        case .EARNEST_MONEY_PAID:
                                            Text(LocalizedStringKey("earnest_money_paid"))
                                                .bold()
                                                .font(.system(size: 20))
                                        case .DOWN_PAYMENT_PAID:
                                            Text(LocalizedStringKey("down_payment_paid"))
                                                .bold()
                                                .font(.system(size: 20))
                                        case .ARRANGE_PRODUCTION:
                                            Text(LocalizedStringKey("arrange_production"))
                                                .bold()
                                                .font(.system(size: 20))
                                        default:
                                            Text(LocalizedStringKey("my_order"))
                                                .bold()
                                                .font(.system(size: 20))
                                        }
                                    } else {
                                        Text(LocalizedStringKey("my_wishlist"))
                                            .bold()
                                            .font(.system(size: 20))
                                    }
                                    Spacer()
                                }
                                TabView {
                                    ForEach(saleModelImages, id: \.self) { image in
                                        ZStack {
                                            if !image.isEmpty {
                                                KFImage(URL(string: image)!)
                                                    .resizable()
                                                    .scaledToFit()
                                            }
                                        }
                                    }
                                }
                                .tabViewStyle(.page)
                                .frame(height: 200)
                                .clipped()
                                Spacer().frame(height: 10)
                                HStack {
                                    Text(LocalizedStringKey("selected_config"))
                                        .bold()
                                    Spacer()
                                    Text("￥\(totalPrice.formatted())")
                                }
                                Spacer().frame(height: 10)
                                HStack {
                                    Text(saleModelDesc)
                                        .font(.system(size: 13))
                                        .foregroundStyle(AppTheme.colors.fontSecondary)
                                }
                                Spacer().frame(height: 20)
                            }
                        }
                        .buttonStyle(.plain)
                        if currentVehicleType == .ORDER {
                            switch orderState {
                            case .EARNEST_MONEY_UNPAID:
                                HStack {
                                    RoundedCornerButton(
                                        nameLocal: LocalizedStringKey("cancel_order")
                                    ) {
                                        intent.onTapCancelOrder()
                                    }
                                    .frame(width: 100)
                                    Spacer().frame(width: 20)
                                    RoundedCornerButton(
                                        nameLocal: LocalizedStringKey("pay_earnest_money"),
                                        color: Color.white,
                                        bgColor: Color.black
                                    ) {
                                        intent.onTapPayOrder(orderPaymentPhase: 1, paymentAmount: 5000, paymentChannel: "ALIPAY")
                                    }
                                }
                            case .EARNEST_MONEY_PAID:
                                HStack {
                                    RoundedCornerButton(
                                        nameLocal: LocalizedStringKey("request_refund")
                                    ) {
                                        intent.onTapCancelOrder()
                                    }
                                    .frame(width: 100)
                                    Spacer().frame(width: 20)
                                    RoundedCornerButton(
                                        nameLocal: LocalizedStringKey("earnest_money_to_down_payment"),
                                        color: Color.white,
                                        bgColor: Color.black
                                    ) {
                                        intent.onTapEarnestMoneyToDownPayment()
                                    }
                                }
                            case .DOWN_PAYMENT_PAID:
                                HStack {
                                    RoundedCornerButton(
                                        nameLocal: LocalizedStringKey("lock_order"),
                                        color: Color.white,
                                        bgColor: Color.black
                                    ) {
                                        intent.onTapLockOrder()
                                    }
                                }
                            case .ARRANGE_PRODUCTION:
                                HStack {
                                    RoundedCornerButton(
                                        nameLocal: LocalizedStringKey("sign_contract")
                                    ) {
                                        
                                    }
                                    Spacer().frame(width: 20)
                                    RoundedCornerButton(
                                        nameLocal: LocalizedStringKey("pay_final_payment"),
                                        color: Color.white,
                                        bgColor: Color.black
                                    ) {
                                        intent.onTapPayOrder(orderPaymentPhase: 3, paymentAmount: 183888, paymentChannel: "ALIPAY")
                                    }
                                }
                            default:
                                Text(LocalizedStringKey("my_order"))
                                    .bold()
                                    .font(.system(size: 20))
                            }
                        } else {
                            RoundedCornerButton(
                                nameLocal: LocalizedStringKey("order_now"),
                                color: Color.white,
                                bgColor: Color.black
                            ) {
                                intent.onTapOrder()
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
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
