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
        @State private var showError = false
        @State private var showIdNumError = false
        @State private var showNameError = false
        @State private var showLicenseCityError = false
        @State private var showDealershipError = false
        @State private var showDeliveryCenterError = false
        @State var selectLicenseCityName: String
        @State var selectLicenseCityCode: String
        @State var selectDealershipName: String
        @State var selectDealershipCode: String
        @State var selectDeliveryCenterName: String
        @State var selectDeliveryCenterCode: String

        var body: some View {
            VStack(spacing: 0) {
                TopBackTitleBar(titleLocal: LocalizedStringKey("book_vehicle"))
                ScrollView {
                    VStack(spacing: 16) {
                        VehicleOrderDetailPage.Intro(
                            saleModelImages: saleModelImages,
                            saleModelName: saleModelName,
                            saleModelDesc: saleModelDesc
                        )
                        .padding(.top, 10)
                        
                        // 预定方式
                        FormSection(title: "预定方式") {
                            VStack(spacing: 12) {
                                if downPayment {
                                    BookMethodCard(
                                        isSelected: state.selectBookMethod == "downPayment",
                                        tagText: "锁定限时权益",
                                        tagColor: .orange,
                                        title: "down_payment",
                                        price: downPaymentPrice,
                                        benefits: purchaseBenefitsIntro
                                    ) {
                                        intent.onTapDownPaymentBookMethod()
                                    }
                                }
                                if earnestMoney {
                                    BookMethodCard(
                                        isSelected: state.selectBookMethod == "earnestMoney",
                                        tagText: "意向金随时可退",
                                        tagColor: .gray,
                                        title: "earnest_money",
                                        price: earnestMoneyPrice,
                                        benefits: purchaseBenefitsIntro
                                    ) {
                                        intent.onTapEarnestMoneyBookMethod()
                                    }
                                }
                            }
                        }
                        
                        if state.selectBookMethod == "downPayment" {
                            // 购车信息卡片
                            FormSection(title: "购车方案") {
                                VStack(spacing: 20) {
                                    OptionSelector(title: "购车类型", options: ["个人", "企业"], selectedIndex: orderPersonType - 1) { index in
                                        if index == 0 { intent.onTapOrderPersonTypePerson() }
                                        else { intent.onTapOrderPersonTypeOrg() }
                                    }
                                    
                                    OptionSelector(title: "支付方式", options: ["全款", "分期"], selectedIndex: purchasePlan - 1) { index in
                                        if index == 0 { intent.onTapPurchasePlanFullPayment() }
                                        else { intent.onTapPurchasePlanStaging() }
                                    }
                                    
                                    if purchasePlan == 2 {
                                        NavigationLink(destination: EmptyView()) {
                                            HStack {
                                                Text("金融方案")
                                                    .font(.system(size: 15))
                                                    .foregroundColor(AppTheme.colors.fontPrimary)
                                                Spacer()
                                                Text("查看详情")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.gray)
                                                Image("icon_arrow_right")
                                                    .resizable()
                                                    .frame(width: 16, height: 16)
                                            }
                                            .padding(.vertical, 4)
                                        }
                                    }
                                }
                            }
                            
                            // 车主信息卡片
                            FormSection(title: "车主（车辆所有人）信息") {
                                VStack(spacing: 0) {
                                    InputField(label: orderPersonType == 2 ? "企业名称" : "车主姓名", placeholder: "请输入", text: $orderPersonName, hasError: showNameError)
                                    
                                    if orderPersonType != 2 {
                                        Divider().padding(.vertical, 12)
                                        HStack {
                                            Text("证件类型")
                                                .font(.system(size: 15))
                                                .frame(width: 80, alignment: .leading)
                                            TextField("请选择", text: $orderPersonIdType)
                                                .font(.system(size: 15))
                                                .disabled(true)
                                            Spacer()
                                            Image("icon_arrow_right")
                                                .resizable()
                                                .frame(width: 16, height: 16)
                                        }
                                    }
                                    
                                    Divider().padding(.vertical, 12)
                                    InputField(label: orderPersonType == 2 ? "企业代码" : "证件号码", placeholder: "请输入", text: $orderPersonIdNum, hasError: showIdNumError)
                                }
                            }
                        }
                        
                        // 上牌及门店
                        FormSection(title: "交付信息") {
                            VStack(spacing: 0) {
                                SelectField(label: "上牌城市", placeholder: "请选择", value: selectLicenseCityName, hasError: showLicenseCityError) {
                                    intent.onTapLicenseCity()
                                }
                                
                                if state.selectBookMethod == "downPayment" {
                                    Divider().padding(.vertical, 12)
                                    SelectField(label: "销售门店", placeholder: "请选择", value: selectDealershipName, hasError: showDealershipError) {
                                        intent.onTapDealership()
                                    }
                                    Divider().padding(.vertical, 12)
                                    SelectField(label: "交付中心", placeholder: "请选择", value: selectDeliveryCenterName, hasError: showDeliveryCenterError) {
                                        intent.onTapDeliveryCenter()
                                    }
                                }
                            }
                        }
                        
                        // 价格明细
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
                        .padding(.top, 10)
                        
                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal, 16)
                }
                .background(Color(white: 0.97)) // 轻微灰色背景衬托卡片
                .scrollIndicators(.hidden)
                
                // 底部操作区
                VStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Button(action: { intent.onTapAgreement() }) {
                            Image(state.agreementIsChecked ? "icon_circle_check" : "icon_circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                        }
                        .buttonStyle(.plain)
                        
                        Text("我已阅读并同意")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Text("《订购协议》")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black)
                    }
                    .padding(.top, 8)
                    
                    if state.selectBookMethod == "downPayment" {
                        RoundedCornerButton(
                            nameLocal: LocalizedStringKey("pay_down_payment"),
                            color: Color.white,
                            bgColor: state.agreementIsChecked ? Color.black : Color.gray.opacity(0.5)
                        ) {
                            validateAndSubmit()
                        }
                    } else {
                        RoundedCornerButton(
                            nameLocal: LocalizedStringKey("pay_earnest_money"),
                            color: Color.white,
                            bgColor: state.agreementIsChecked && !selectLicenseCityName.isEmpty ? Color.black : Color.gray.opacity(0.5)
                        ) {
                            intent.onTapEarnestMoneyOrder(
                                saleModelName: saleModelName,
                                licenseCityCode: selectLicenseCityCode
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .background(Color.white.shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -5))
            }
            .onAppear {
                if state.selectBookMethod == "" {
                    if state.downPayment {
                        intent.onTapDownPaymentBookMethod()
                    } else {
                        intent.onTapEarnestMoneyBookMethod()
                    }
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
        
        // MARK: - 辅助逻辑
        private func validateAndSubmit() {
            showError = false
            showIdNumError = orderPersonIdNum.isEmpty
            showNameError = orderPersonName.isEmpty
            showLicenseCityError = selectLicenseCityName.isEmpty
            showDealershipError = selectDealershipName.isEmpty
            showDeliveryCenterError = selectDeliveryCenterName.isEmpty
            
            if showIdNumError || showNameError || showLicenseCityError || showDealershipError || showDeliveryCenterError {
                showError = true
                return
            }
            
            intent.onTapDownPaymentOrder(
                orderPersonType: orderPersonType,
                purchasePlan: purchasePlan,
                orderPersonName: orderPersonName,
                orderPersonIdType: 1,
                orderPersonIdNum: orderPersonIdNum,
                saleModelName: saleModelName,
                licenseCityCode: selectLicenseCityCode,
                dealership: selectDealershipCode,
                deliveryCenter: selectDeliveryCenterCode
            )
        }
    }
}

// MARK: - 美化组件
private struct FormSection<Content: View>: View {
    var title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.colors.fontPrimary)
                .padding(.leading, 4)
            
            VStack {
                content
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)
        }
    }
}

private struct OptionSelector: View {
    var title: String
    var options: [String]
    var selectedIndex: Int
    var onSelect: (Int) -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.colors.fontPrimary)
            Spacer()
            HStack(spacing: 0) {
                ForEach(0..<options.count, id: \.self) { index in
                    Text(options[index])
                        .font(.system(size: 13, weight: selectedIndex == index ? .medium : .regular))
                        .foregroundColor(selectedIndex == index ? .white : .black)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 16)
                        .background(selectedIndex == index ? Color.black : Color.clear)
                        .cornerRadius(20)
                        .onTapGesture { onSelect(index) }
                }
            }
            .background(Color(white: 0.95))
            .cornerRadius(20)
        }
    }
}

private struct InputField: View {
    var label: String
    var placeholder: String
    @Binding var text: String
    var hasError: Bool
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .frame(width: 80, alignment: .leading)
            TextField(placeholder, text: $text)
                .font(.system(size: 15))
            if hasError {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 14))
            }
        }
    }
}

private struct SelectField: View {
    var label: String
    var placeholder: String
    var value: String
    var hasError: Bool
    var action: () -> Void
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .frame(width: 80, alignment: .leading)
            Text(value.isEmpty ? placeholder : value)
                .font(.system(size: 15))
                .foregroundColor(value.isEmpty ? Color.gray.opacity(0.6) : AppTheme.colors.fontPrimary)
            Spacer()
            if hasError {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                    .padding(.trailing, 4)
            }
            Image("icon_arrow_right")
                .resizable()
                .frame(width: 16, height: 16)
        }
        .contentShape(Rectangle())
        .onTapGesture { action() }
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
