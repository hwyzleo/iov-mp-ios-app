//
//  VehicleOrderDetailPage_Order.swift
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
            ZStack(alignment: .top) {
                AppTheme.colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 顶部导航 (显式设置文字颜色为白色)
                    TopBackTitleBar(titleLocal: LocalizedStringKey("book_vehicle"), color: .white)
                        .frame(height: 54)
                    
                    ScrollView {
                        VStack(spacing: AppTheme.layout.spacing) {
                            // 1. 车型简介卡片
                            VehicleOrderDetailPage.Intro(
                                saleModelImages: saleModelImages,
                                saleModelName: saleModelName,
                                saleModelDesc: saleModelDesc
                            )
                            .appCardStyle()
                            .padding(.top, 10)
                            
                            // 2. 预定方式
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
                                            tagColor: AppTheme.colors.fontTertiary,
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
                                // 3. 购车方案
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
                                    }
                                }
                                
                                // 4. 车主信息
                                FormSection(title: "车主（车辆所有人）信息") {
                                    VStack(spacing: 0) {
                                        InputField(label: orderPersonType == 2 ? "企业名称" : "车主姓名", placeholder: "请输入", text: $orderPersonName, hasError: showNameError)
                                        Divider().background(Color.white.opacity(0.05)).padding(.vertical, 16)
                                        InputField(label: orderPersonType == 2 ? "企业代码" : "证件号码", placeholder: "请输入", text: $orderPersonIdNum, hasError: showIdNumError)
                                    }
                                }
                            }
                            
                            // 5. 交付信息
                            FormSection(title: "交付信息") {
                                VStack(spacing: 0) {
                                    SelectField(label: "上牌城市", placeholder: "请选择", value: selectLicenseCityName, hasError: showLicenseCityError) {
                                        intent.onTapLicenseCity()
                                    }
                                    
                                    if state.selectBookMethod == "downPayment" {
                                        Divider().background(Color.white.opacity(0.05)).padding(.vertical, 16)
                                        SelectField(label: "销售门店", placeholder: "请选择", value: selectDealershipName, hasError: showDealershipError) {
                                            intent.onTapDealership()
                                        }
                                        Divider().background(Color.white.opacity(0.05)).padding(.vertical, 16)
                                        SelectField(label: "交付中心", placeholder: "请选择", value: selectDeliveryCenterName, hasError: showDeliveryCenterError) {
                                            intent.onTapDeliveryCenter()
                                        }
                                    }
                                }
                            }
                            
                            // 6. 价格明细 (将标题拉出来与其他对齐)
                            VStack(alignment: .leading, spacing: 12) {
                                Text("价格明细")
                                    .font(AppTheme.fonts.title1)
                                    .foregroundColor(AppTheme.colors.fontPrimary)
                                
                                VStack(spacing: 12) {
                                    PriceDetailRow(label: "官方指导价", price: saleModelPrice)
                                    PriceDetailRow(label: saleSpareTireName, price: saleSpareTirePrice)
                                    PriceDetailRow(label: saleExteriorName, price: saleExteriorPrice)
                                    PriceDetailRow(label: saleWheelName, price: saleWheelPrice)
                                    PriceDetailRow(label: saleInteriorName, price: saleInteriorPrice)
                                    PriceDetailRow(label: saleAdasName, price: saleAdasPrice)
                                    Divider().background(Color.white.opacity(0.1)).padding(.vertical, 4)
                                    HStack {
                                        Text("总价")
                                            .font(AppTheme.fonts.body)
                                            .foregroundColor(AppTheme.colors.fontPrimary)
                                        Spacer()
                                        Text("￥\(totalPrice.formatted())")
                                            .font(AppTheme.fonts.title1)
                                            .foregroundColor(AppTheme.colors.brandMain)
                                    }
                                }
                                .appCardStyle()
                            }
                            
                            Spacer().frame(height: 120)
                        }
                        .padding(.horizontal, AppTheme.layout.margin)
                    }
                }
                
                // 底部操作区
                VStack(spacing: 0) {
                    Spacer()
                    VStack(spacing: 16) {
                        HStack(spacing: 8) {
                            Button(action: {
                                withAnimation(.spring()) { intent.onTapAgreement() }
                            }) {
                                Image(systemName: state.agreementIsChecked ? "checkmark.circle.fill" : "circle")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .foregroundColor(state.agreementIsChecked ? AppTheme.colors.brandMain : AppTheme.colors.fontTertiary)
                            }
                            .buttonStyle(.plain)
                            
                            Text("我已阅读并同意")
                                .font(AppTheme.fonts.subtext)
                                .foregroundColor(AppTheme.colors.fontSecondary)
                            Text("《订购协议》")
                                .font(AppTheme.fonts.subtext)
                                .foregroundColor(AppTheme.colors.brandMain)
                        }
                        
                        RoundedCornerButton(
                            nameLocal: state.selectBookMethod == "downPayment" ? LocalizedStringKey("pay_down_payment") : LocalizedStringKey("pay_earnest_money"),
                            color: .black,
                            bgColor: (state.agreementIsChecked && (state.selectBookMethod != "earnestMoney" || !selectLicenseCityName.isEmpty)) ? AppTheme.colors.brandMain : AppTheme.colors.brandMain.opacity(0.3)
                        ) {
                            if state.selectBookMethod == "downPayment" {
                                validateAndSubmit()
                            } else {
                                intent.onTapEarnestMoneyOrder(saleModelName: saleModelName, licenseCityCode: selectLicenseCityCode)
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.layout.margin)
                    .padding(.top, 20)
                    .padding(.bottom, 34) // 适配安全区域
                    .background(AppTheme.colors.cardBackground.shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: -5))
                }
                .ignoresSafeArea()
            }
            .preferredColorScheme(.dark)
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
        
        private func validateAndSubmit() {
            showIdNumError = orderPersonIdNum.isEmpty
            showNameError = orderPersonName.isEmpty
            showLicenseCityError = selectLicenseCityName.isEmpty
            showDealershipError = selectDealershipName.isEmpty
            showDeliveryCenterError = selectDeliveryCenterName.isEmpty
            
            if showIdNumError || showNameError || showLicenseCityError || (state.selectBookMethod == "downPayment" && (showDealershipError || showDeliveryCenterError)) {
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

// MARK: - 辅助组件
private struct PriceDetailRow: View {
    let label: String
    let price: Decimal
    var body: some View {
        HStack {
            Text(label)
                .font(AppTheme.fonts.subtext)
                .foregroundColor(AppTheme.colors.fontSecondary)
            Spacer()
            if price == 0 {
                Text("包含")
                    .font(AppTheme.fonts.subtext)
                    .foregroundColor(AppTheme.colors.fontPrimary)
            } else {
                Text("￥\(price.formatted())")
                    .font(AppTheme.fonts.subtext)
                    .foregroundColor(AppTheme.colors.fontPrimary)
            }
        }
    }
}

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
                .font(AppTheme.fonts.title1)
                .foregroundColor(AppTheme.colors.fontPrimary)
            VStack { content }
            .appCardStyle()
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
                .font(AppTheme.fonts.body)
                .foregroundColor(AppTheme.colors.fontPrimary)
            Spacer()
            HStack(spacing: 0) {
                ForEach(0..<options.count, id: \.self) { index in
                    Text(options[index])
                        .font(.system(size: 13, weight: selectedIndex == index ? .bold : .regular))
                        .foregroundColor(selectedIndex == index ? .black : AppTheme.colors.fontSecondary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(selectedIndex == index ? AppTheme.colors.brandMain : Color.clear)
                        .cornerRadius(20)
                        .onTapGesture { onSelect(index) }
                }
            }
            .background(Color.white.opacity(0.05))
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
                .font(AppTheme.fonts.body)
                .foregroundColor(AppTheme.colors.fontPrimary)
                .frame(width: 100, alignment: .leading)
            TextField("", text: $text)
                .font(AppTheme.fonts.body)
                .foregroundColor(AppTheme.colors.fontPrimary)
                .placeholder(when: text.isEmpty) {
                    Text(placeholder).foregroundColor(AppTheme.colors.fontTertiary)
                }
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
        Button(action: action) {
            HStack {
                Text(label)
                    .font(AppTheme.fonts.body)
                    .foregroundColor(AppTheme.colors.fontPrimary)
                    .frame(width: 100, alignment: .leading)
                Text(value.isEmpty ? placeholder : value)
                    .font(AppTheme.fonts.body)
                    .foregroundColor(value.isEmpty ? AppTheme.colors.fontTertiary : AppTheme.colors.fontPrimary)
                Spacer()
                if hasError {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                        .padding(.trailing, 4)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.colors.fontTertiary)
            }
        }
        .buttonStyle(.plain)
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
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
