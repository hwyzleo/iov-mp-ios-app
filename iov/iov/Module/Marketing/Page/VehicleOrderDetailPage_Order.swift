//
//  VehicleWishlistPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/13.
//

import SwiftUI
import Kingfisher

/// 车辆订单详情 - 预定页
extension VehicleOrderDetailPage {
    struct Order: View {
        @EnvironmentObject var globalState: AppGlobalState
        @StateObject var container: MviContainer<VehicleOrderDetailIntentProtocol, VehicleOrderDetailModelStateProtocol>
        private var intent: VehicleOrderDetailIntentProtocol { container.intent }
        private var state: VehicleOrderDetailModelStateProtocol { container.model }
        var saleModelImages: [String]
        var saleModelName: String
        var saleModelDesc: String
        var downPayment: Bool
        var downPaymentPrice: Decimal
        var earnestMoney: Bool
        var earnestMoneyPrice: Decimal
        var purchaseBenefitsIntro: String
        var orderPersonType: Int
        var purchasePlan: Int
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
        @State private var orderPersonName = ""
        @State private var orderPersonIdType = ""
        @State private var orderPersonIdNum = ""
        @State var selectLicenseCityName: String
        @State var selectLicenseCityCode: String
        @State var selectDealershipName: String
        @State var selectDealershipCode: String
        @State var selectDeliveryCenterName: String
        @State var selectDeliveryCenterCode: String

        
        var body: some View {
            VStack {
                TopBackTitleBar(titleLocal: LocalizedStringKey("book_vehicle"))
                ScrollView {
                    VStack {
                        VehicleOrderDetailPage.Intro(
                            saleModelImages: saleModelImages,
                            saleModelName: saleModelName,
                            saleModelDesc: saleModelDesc
                        )
                        Spacer().frame(height: 20)
                        HStack {
                            Text(LocalizedStringKey("book_method"))
                                .bold()
                            Spacer()
                        }
                        if downPayment {
                            Spacer().frame(height: 10)
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(state.selectBookMethod == "downPayment" ? Color.orange : Color.gray, lineWidth: 1)
                                .frame(height: 130)
                                .overlay(
                                    VStack {
                                        HStack {
                                            RoundedCornerButton(name: "锁定限时权益", color: .white, bgColor: .orange, borderColor: .orange, height: 20, fontSize: 10) {}
                                                .frame(width: 80)
                                            Text(LocalizedStringKey("down_payment"))
                                            Text("￥\(downPaymentPrice.formatted())")
                                            Spacer()
                                            Text(LocalizedStringKey("view_benefits_detail"))
                                        }
                                        Spacer().frame(height: 10)
                                        HStack {
                                            Text(purchaseBenefitsIntro)
                                                .lineSpacing(10.0)
                                                .fixedSize(horizontal: false, vertical: true)
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                    .font(.system(size: 14))
                                    .padding()
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    intent.onTapDownPaymentBookMethod()
                                }
                        }
                        if earnestMoney {
                            Spacer().frame(height: 10)
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(state.selectBookMethod == "earnestMoney" ? Color.orange : Color.gray, lineWidth: 1)
                                .frame(height: 130)
                                .overlay(
                                    VStack {
                                        HStack {
                                            RoundedCornerButton(name: "意向金随时可退", color: .white, bgColor: .gray, height: 20, fontSize: 10) {}
                                                .frame(width: 80)
                                            Text(LocalizedStringKey("earnest_money"))
                                            Text("￥\(earnestMoneyPrice.formatted())")
                                            Spacer()
                                            Text(LocalizedStringKey("view_benefits_detail"))
                                        }
                                        Spacer().frame(height: 10)
                                        HStack {
                                            Text(purchaseBenefitsIntro)
                                                .lineSpacing(10.0)
                                                .fixedSize(horizontal: false, vertical: true)
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                    .font(.system(size: 14))
                                    .padding()
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    intent.onTapEarnestMoneyBookMethod()
                                }
                        }
                        if state.selectBookMethod == "downPayment" {
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
                                    TextField("请输入企业名称", text: $orderPersonName)
                                } else {
                                    Text("车主姓名")
                                    TextField("请输入车主姓名", text: $orderPersonName)
                                }
                            }
                            if orderPersonType != 2 {
                                Divider()
                                HStack {
                                    Text("证件类型")
                                    TextField("请输入证件类型", text: $orderPersonIdType)
                                }
                            }
                            Divider()
                            HStack {
                                if orderPersonType == 2 {
                                    Text("企业代码")
                                    TextField("请输入企业代码", text: $orderPersonIdNum)
                                } else {
                                    Text("证件号码")
                                    TextField("请输入证件号码", text: $orderPersonIdNum)
                                }
                            }
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
                            TextField("请选择上牌城市", text: $selectLicenseCityName)
                            Image("icon_arrow_right")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        .onTapGesture {
                            intent.onTapLicenseCity()
                        }
                        if state.selectBookMethod == "downPayment" {
                            Divider()
                            HStack {
                                Text("销售门店")
                                TextField("请选择销售门店", text: $selectDealershipName)
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
                                TextField("请选择交付中心", text: $selectDeliveryCenterName)
                                Image("icon_arrow_right")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                            .onTapGesture {
                                intent.onTapDeliveryCenter()
                            }
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
                        HStack {
                            Text("订购须知")
                                .bold()
                            Spacer()
                        }
                    }
                }
                .scrollIndicators(.hidden)
                HStack {
                    Spacer()
                    Button(action: { intent.onTapAgreement() }) {
                        Image(state.agreementIsChecked ? "icon_circle_check" : "icon_circle")
                            .resizable()
                            .frame(width: 15, height: 15)
                    }
                    .buttonStyle(.plain)
                    Text("我已约定并同意 《订购协议》")
                        .font(.system(size: 12))
                    Spacer()
                }
                if state.selectBookMethod == "downPayment" {
                    RoundedCornerButton(
                        nameLocal: LocalizedStringKey("pay_down_payment"),
                        color: Color.white,
                        bgColor: state.agreementIsChecked == true ? Color.black : Color.gray
                    ) {
                        intent.onTapDownPaymentOrder(
                            orderPersonType: orderPersonType,
                            purchasePlan: purchasePlan,
                            orderPersonName: orderPersonName,
                            orderPersonIdType: 1,
                            orderPersonIdNum: orderPersonIdNum,
                            saleModelName: saleModelName,
                            licenseCity: selectLicenseCityCode,
                            dealership: selectDealershipCode,
                            deliveryCenter: selectDeliveryCenterCode
                        )
                    }
                }
                if state.selectBookMethod == "earnestMoney" {
                    RoundedCornerButton(
                        nameLocal: LocalizedStringKey("pay_earnest_money"),
                        color: Color.white,
                        bgColor: state.agreementIsChecked && selectLicenseCityName != "" ? Color.black : Color.gray
                    ) {
                        intent.onTapEarnestMoneyOrder(
                            saleModelName: saleModelName,
                            licenseCityCode: selectLicenseCityCode
                        )
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
            .onChange(of: globalState.backRefresh) { _ in
                if globalState.backRefresh {
                    globalState.backRefresh = false
                    if let cityName = AppGlobalState.shared.parameters["licenseCityName"] {
                        selectLicenseCityName = cityName as! String
                        selectLicenseCityCode = AppGlobalState.shared.parameters["licenseCityCode"] as! String
                    }
                    if let dealershipName = AppGlobalState.shared.parameters["dealershipName"] {
                        selectDealershipName = dealershipName as! String
                        selectDealershipCode = AppGlobalState.shared.parameters["dealershipCode"] as! String
                    }
                    if let deliveryCenterName = AppGlobalState.shared.parameters["deliveryCenterName"] {
                        selectDeliveryCenterName = deliveryCenterName as! String
                        selectDeliveryCenterCode = AppGlobalState.shared.parameters["deliveryCenterCode"] as! String
                    }
                }
            }
        }
    }
}

struct VehicleOrderDetailPage_Order_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState.shared
    static var previews: some View {
        VehicleOrderDetailPage.Order(
            container: VehicleOrderDetailPage.buildContainer(),
            saleModelImages: [
                "https://pic.imgdb.cn/item/67065b68d29ded1a8c999b62.png",
                "https://pic.imgdb.cn/item/670685e4d29ded1a8cb9c55f.png"
            ],
            saleModelName: "寒01七座版",
            saleModelDesc: "寒01七座版 | 有备胎 | 翡翠绿车漆 | 21寸轮毂(四季胎)高亮黑 | 乌木黑内饰 | 高阶智驾",
            downPayment: true,
            downPaymentPrice: 5000,
            earnestMoney: true,
            earnestMoneyPrice: 5000,
            purchaseBenefitsIntro: "创始权益（价值6000元）\n首年用车服务包（价值999元）\n5000元选配基金（价值5000元）",
            orderPersonType: 1,
            purchasePlan: 1,
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
            selectLicenseCityName: "上海",
            selectLicenseCityCode: "3101",
            selectDealershipName: "上海中心店",
            selectDealershipCode: "SHSA01",
            selectDeliveryCenterName: "上海交付中心",
            selectDeliveryCenterCode: "SHDE01"
        )
        .environmentObject(appGlobalState)
        .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
