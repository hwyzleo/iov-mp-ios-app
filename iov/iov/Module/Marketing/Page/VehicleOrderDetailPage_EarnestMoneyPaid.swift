//
//  VehicleWishlistPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/13.
//

import SwiftUI
import Kingfisher

/// 车辆订单详情 - 意向金已支付页
extension VehicleOrderDetailPage {
    struct EarnestMoneyPaid: View {
        @StateObject var container: MviContainer<VehicleOrderDetailIntentProtocol, VehicleOrderDetailModelStateProtocol>
        private var intent: VehicleOrderDetailIntentProtocol { container.intent }
        private var state: VehicleOrderDetailModelStateProtocol { container.model }
        var saleModelImages: [String]
        var saleModelName: String
        var saleModelDesc: String
        var saleModelPrice: Decimal
        var saleSpareTireName: String
        var saleSpareTirePrice: Decimal
        var saleExteriorName: String
        var saleExteriorPrice: Decimal
        var saleWheelName: String
        var saleWheelPrice: Decimal
        var saleInteriorName: String
        var saleInteriorPrice: Decimal
        var saleAdasName: String
        var saleAdasPrice: Decimal
        var totalPrice: Decimal
        var orderNum: String
        var orderTime: Int64
        @State var selectLicenseCityName: String
        @State var selectLicenseCityCode: String
        
        var body: some View {
            VStack {
                ZStack {
                    TopBackTitleBar(titleLocal: LocalizedStringKey("order_detail"))
                    HStack {
                        Spacer()
                        Button(action: {
                            intent.onTapDelete()
                        }) {
                            Image("icon_setting")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                    }
                }
                .frame(height: 50)
                ScrollView {
                    VStack {
                        HStack {
                            Text(LocalizedStringKey("earnest_money_paid"))
                                .bold()
                                .font(.system(size: 20))
                            Spacer()
                        }
                        VehicleOrderDetailPage.Intro(
                            saleModelImages: saleModelImages,
                            saleModelName: saleModelName,
                            saleModelDesc: saleModelDesc
                        )
                        Spacer().frame(height: 20)
                        HStack {
                            Text("上牌及门店信息")
                                .bold()
                            Spacer()
                        }
                        Spacer().frame(height: 10)
                        HStack {
                            Text("上牌城市")
                            TextField("请选择上牌城市", text: $selectLicenseCityName)
                            Image("icon_arrow_right")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        .onTapGesture {
                            intent.onTapLicenseCity()
                        }
                        Spacer().frame(height: 20)
                        VehicleOrderDetailPage.Price(
                            saleModelPrice: saleModelPrice,
                            saleSpareTireName: saleSpareTireName,
                            saleSpareTirePrice: saleSpareTirePrice,
                            saleExteriorName: saleExteriorName,
                            saleExteriorPrice: saleExteriorPrice,
                            saleWheelName: saleWheelName,
                            saleWheelPrice: saleWheelPrice,
                            saleInteriorName: saleInteriorName,
                            saleInteriorPrice: saleInteriorPrice,
                            saleAdasName: saleAdasName,
                            saleAdasPrice: saleAdasPrice,
                            totalPrice: totalPrice
                        )
                        Spacer().frame(height: 20)
                        VehicleOrderDetailPage.OrderInfo(
                            orderNum: orderNum,
                            orderTime: orderTime
                        )
                    }
                }
                .scrollIndicators(.hidden)
                HStack {
                    RoundedCornerButton(
                        nameLocal: LocalizedStringKey("request_refund")
                    ) {
                        
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
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .onAppear {
                if state.selectBookMethod == "" {
                    intent.onTapDownPaymentBookMethod()
                }
            }
        }
    }
}

struct VehicleOrderDetailPage_EarnestMoneyPaid_Previews: PreviewProvider {
    static var previews: some View {
        VehicleOrderDetailPage.EarnestMoneyPaid(
            container: VehicleOrderDetailPage.buildContainer(),
            saleModelImages: [
                "https://pic.imgdb.cn/item/67065b68d29ded1a8c999b62.png",
                "https://pic.imgdb.cn/item/670685e4d29ded1a8cb9c55f.png"
            ],
            saleModelName: "寒01七座版",
            saleModelDesc: "寒01七座版 | 有备胎 | 翡翠绿车漆 | 21寸轮毂(四季胎)高亮黑 | 乌木黑内饰 | 高阶智驾",
            saleModelPrice: 188888,
            saleSpareTireName: "有备胎",
            saleSpareTirePrice: 6000,
            saleExteriorName: "翡翠绿车漆",
            saleExteriorPrice: 0,
            saleWheelName: "21寸轮毂（四季胎）高亮黑",
            saleWheelPrice: 0,
            saleInteriorName: "乌木黑内饰",
            saleInteriorPrice: 0,
            saleAdasName: "高价智驾",
            saleAdasPrice: 10000,
            totalPrice: 205888,
            orderNum: "ORDERNUM001",
            orderTime: 1729403155,
            selectLicenseCityName: "上海",
            selectLicenseCityCode: "3101"
        )
        .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
