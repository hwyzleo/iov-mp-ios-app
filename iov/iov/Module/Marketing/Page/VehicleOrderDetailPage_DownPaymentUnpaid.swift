//
//  VehicleWishlistPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/13.
//

import SwiftUI
import Kingfisher

/// 车辆订单详情 - 定金待支付页
extension VehicleOrderDetailPage {
    struct DownPaymentUnpaid: View {
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
        var orderPersonType: Int
        var purchasePlan: Int
        var orderPersonName: String
        var orderPersonIdType: Int
        var orderPersonIdNum: String
        var licenseCity: String
        var dealershipName: String
        var deliveryCenterName: String
        
        var body: some View {
            VStack {
                TopBackTitleBar(titleLocal: LocalizedStringKey("order_detail"))
                ScrollView {
                    VStack {
                        HStack {
                            Text(LocalizedStringKey("down_payment_to_be_paid"))
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
                            Text("购车类型")
                                .bold()
                            Spacer()
                        }
                        Spacer().frame(height: 10)
                        HStack {
                            HStack {
                                if orderPersonType == 1 {
                                    Image("icon_circle_check")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                } else {
                                    Image("icon_circle")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                }
                                Text("个人")
                            }
                            .onTapGesture {
                                intent.onTapOrderPersonTypePerson()
                            }
                            Spacer().frame(width: 100)
                            HStack {
                                if orderPersonType == 2 {
                                    Image("icon_circle_check")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                } else {
                                    Image("icon_circle")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                }
                                Text("企业")
                            }
                            .onTapGesture {
                                intent.onTapOrderPersonTypeOrg()
                            }
                            Spacer()
                        }
                        Spacer().frame(height: 20)
                        HStack {
                            Text("购车方案")
                                .bold()
                            Spacer()
                        }
                        Spacer().frame(height: 10)
                        HStack {
                            HStack {
                                if purchasePlan == 1 {
                                    Image("icon_circle_check")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                } else {
                                    Image("icon_circle")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                }
                                Text("全款")
                            }
                            .onTapGesture {
                                intent.onTapPurchasePlanFullPayment()
                            }
                            Spacer().frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                            HStack {
                                if purchasePlan == 2 {
                                    Image("icon_circle_check")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                } else {
                                    Image("icon_circle")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                }
                                Text("分期")
                            }
                            .onTapGesture {
                                intent.onTapPurchasePlanStaging()
                            }
                            Spacer()
                        }
                        if purchasePlan == 2 {
                            Spacer().frame(height: 20)
                            HStack {
                                Text("金融方案")
                                Spacer()
                                Image("icon_arrow_right")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                        }
                        Spacer().frame(height: 20)
                        HStack {
                            Text("车主（车辆所有人）信息")
                                .bold()
                            Spacer()
                        }
                        Spacer().frame(height: 10)
                        HStack {
                            if orderPersonType == 2 {
                                Text("企业名称")
                            } else {
                                Text("车主姓名")
                            }
                            Text(orderPersonName)
                            Spacer()
                        }
                        if orderPersonType != 2 {
                            Divider()
                            HStack {
                                Text("证件类型")
                                Text(orderPersonIdType.numberString)
                                Spacer()
                            }
                        }
                        Divider()
                        HStack {
                            if orderPersonType == 2 {
                                Text("企业代码")
                            } else {
                                Text("证件号码")
                            }
                            Text(orderPersonIdNum)
                            Spacer()
                        }
                        Spacer().frame(height: 20)
                        HStack {
                            Text("上牌及门店信息")
                                .bold()
                            Spacer()
                        }
                        Spacer().frame(height: 10)
                        HStack {
                            Text("上牌城市")
                            Text(licenseCity)
                            Spacer()
                            Image("icon_arrow_right")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        Divider()
                        HStack {
                            Text("销售门店")
                            Text(dealershipName)
                            Spacer()
                            Image("icon_arrow_right")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        .onTapGesture {
                            intent.onTapDealership()
                        }
                        Divider()
                        HStack {
                            Text("交付中心")
                            Text(deliveryCenterName)
                            Spacer()
                            Image("icon_arrow_right")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        .onTapGesture {
                            intent.onTapDeliveryCenter()
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
                        nameLocal: LocalizedStringKey("cancel_order")
                    ) {
                        intent.onTapCancelOrder()
                    }
                    .frame(width: 100)
                    Spacer().frame(width: 20)
                    RoundedCornerButton(
                        nameLocal: LocalizedStringKey("pay_down_payment"),
                        color: Color.white,
                        bgColor: Color.black
                    ) {
                        intent.onTapPayOrder(orderPaymentPhase: 2, paymentAmount: 5000, paymentChannel: "ALIPAY")
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

struct VehicleOrderDetailPage_DownPaymentUnpaid_Previews: PreviewProvider {
    static var previews: some View {
        VehicleOrderDetailPage.DownPaymentUnpaid(
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
            orderPersonType: 1,
            purchasePlan: 1,
            orderPersonName: "hwyz_leo",
            orderPersonIdType: 1,
            orderPersonIdNum: "310105199910100010",
            licenseCity: "上海",
            dealershipName: "上海服务中心",
            deliveryCenterName: "上海交付中心"
        )
        .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
