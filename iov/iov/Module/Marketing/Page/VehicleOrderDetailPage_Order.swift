//
//  VehicleOrderDetailPage_Order.swift
//  iov
//
//  Created by hwyz_leo on 2024/10/13.
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
                    TopBackTitleBar(titleLocal: L10n.book_vehicle, color: .white)
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
                            VStack(alignment: .leading, spacing: 12) {
                                Text(L10n.book_method)
                                    .font(AppTheme.fonts.title1)
                                    .foregroundColor(AppTheme.colors.fontPrimary)
                                
                                VStack(spacing: 12) {
                                    if downPayment {
                                        BookMethodCard(
                                            isSelected: state.selectBookMethod == "downPayment",
                                            tagText: "锁定限时权益",
                                            tagColor: .orange,
                                            title: L10n.down_payment,
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
                                            title: L10n.earnest_money,
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
                                FormSection(title: L10n.purchase_plan) {
                                    VStack(spacing: 20) {
                                        OptionSelector(title: L10n.purchase_type, options: ["个人", "企业"], selectedIndex: orderPersonType - 1) { index in
                                            if index == 0 { intent.onTapOrderPersonTypePerson() }
                                            else { intent.onTapOrderPersonTypeOrg() }
                                        }
                                        
                                        OptionSelector(title: L10n.payment_method, options: ["全款", "分期"], selectedIndex: purchasePlan - 1) { index in
                                            if index == 0 { intent.onTapPurchasePlanFullPayment() }
                                            else { intent.onTapPurchasePlanStaging() }
                                        }
                                    }
                                }
                                
                                // 4. 车主信息
                                FormSection(title: L10n.owner_info) {
                                    VStack(spacing: 0) {
                                        InputField(label: orderPersonType == 2 ? L10n.enterprise_name : L10n.owner_name, placeholder: "请输入", text: $orderPersonName, hasError: showNameError)
                                        Divider().background(Color.white.opacity(0.05)).padding(.vertical, 16)
                                        InputField(label: orderPersonType == 2 ? L10n.enterprise_code : L10n.certificate_number, placeholder: "请输入", text: $orderPersonIdNum, hasError: showIdNumError)
                                    }
                                }
                            }
                            
                            // 5. 交付信息
                            FormSection(title: L10n.delivery_info) {
                                VStack(spacing: 0) {
                                    SelectField(label: L10n.license_city, placeholder: "请选择", value: selectLicenseCityName, hasError: showLicenseCityError) {
                                        intent.onTapLicenseCity()
                                    }
                                    
                                    if state.selectBookMethod == "downPayment" {
                                        Divider().background(Color.white.opacity(0.05)).padding(.vertical, 16)
                                        SelectField(label: L10n.dealership, placeholder: "请选择", value: selectDealershipName, hasError: showDealershipError) {
                                            intent.onTapDealership()
                                        }
                                        Divider().background(Color.white.opacity(0.05)).padding(.vertical, 16)
                                        SelectField(label: L10n.delivery_center, placeholder: "请选择", value: selectDeliveryCenterName, hasError: showDeliveryCenterError) {
                                            intent.onTapDeliveryCenter()
                                        }
                                    }
                                }
                            }
                            
                            // 6. 价格明细
                            VStack(alignment: .leading, spacing: 12) {
                                Text(L10n.price_detail)
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
                                        Text(L10n.total_price_label)
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
                            
                            Text(L10n.i_have_read_and_agree)
                                .font(AppTheme.fonts.subtext)
                                .foregroundColor(AppTheme.colors.fontSecondary)
                            Text(L10n.order_agreement)
                                .font(AppTheme.fonts.subtext)
                                .foregroundColor(AppTheme.colors.brandMain)
                        }
                        
                        RoundedCornerButton(
                            nameLocal: state.selectBookMethod == "downPayment" ? L10n.pay_down_payment : L10n.pay_earnest_money,
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
                Text(L10n.price_included_text)
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
    var title: LocalizedStringKey
    let content: Content
    init(title: LocalizedStringKey, @ViewBuilder content: () -> Content) {
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
    var title: LocalizedStringKey
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
    var label: LocalizedStringKey
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
    var label: LocalizedStringKey
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

// MARK: - 价格明细行
