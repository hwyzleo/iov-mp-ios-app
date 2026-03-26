//
//  VehicleOrderDetailPage_DownPaymentUnpaid.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/13.
//

import SwiftUI
import Kingfisher

/// 车辆订单详情 - 定金待支付页
extension VehicleOrderDetailPage {
    struct DownPaymentUnpaid: View {
        @EnvironmentObject var globalState: AppGlobalState
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
            ZStack(alignment: .top) {
                AppTheme.colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 顶部导航
                    TopBackTitleBar(titleLocal: L10n.order_detail, color: .white)
                        .frame(height: 54)
                    
                    ScrollView {
                        VStack(spacing: AppTheme.layout.spacing) {
                            // 1. 状态展示
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(L10n.down_payment_to_be_paid)
                                        .font(AppTheme.fonts.bigTitle)
                                        .foregroundColor(AppTheme.colors.fontPrimary)
                                }
                                Spacer()
                                Image(systemName: "creditcard.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppTheme.colors.brandMain)
                            }
                            .padding(.vertical, 10)
                            
                            // 2. 车型简介卡片
                            VehicleOrderDetailPage.Intro(
                                saleModelImages: saleModelImages,
                                saleModelName: saleModelName,
                                saleModelDesc: saleModelDesc
                            )
                            .appCardStyle()
                            
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
                                    InputField(
                                        label: orderPersonType == 2 ? L10n.enterprise_name : L10n.owner_name,
                                        placeholder: "请输入",
                                        text: Binding(get: { orderPersonName }, set: { intent.onUpdateOrderPersonName(name: $0) })
                                    )
                                    Divider().background(Color.white.opacity(0.05)).padding(.vertical, 12)
                                    InputField(
                                        label: orderPersonType == 2 ? L10n.enterprise_code : L10n.certificate_number,
                                        placeholder: "请输入",
                                        text: Binding(get: { orderPersonIdNum }, set: { intent.onUpdateOrderPersonIdNum(idNum: $0) })
                                    )
                                }
                            }
                            
                            // 5. 交付信息
                            FormSection(title: L10n.delivery_info) {
                                VStack(spacing: 16) {
                                    SelectField(label: L10n.license_city, placeholder: "请选择", value: licenseCity) {
                                        intent.onTapLicenseCity()
                                    }
                                    Divider().background(Color.white.opacity(0.05))
                                    SelectField(label: L10n.dealership, placeholder: "请选择", value: dealershipName) {
                                        intent.onTapDealership()
                                    }
                                    Divider().background(Color.white.opacity(0.05))
                                    SelectField(label: L10n.delivery_center, placeholder: "请选择", value: deliveryCenterName) {
                                        intent.onTapDeliveryCenter()
                                    }
                                }
                            }
                            
                            // 6. 价格明细
                            VStack(alignment: .leading, spacing: 12) {
                                Text(L10n.price_detail)
                                    .font(AppTheme.fonts.title1)
                                    .foregroundColor(AppTheme.colors.fontPrimary)
                                
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
                                .appCardStyle()
                            }
                            
                            // 7. 订单信息
                            VStack(alignment: .leading, spacing: 12) {
                                Text(L10n.order_info)
                                    .font(AppTheme.fonts.title1)
                                    .foregroundColor(AppTheme.colors.fontPrimary)
                                
                                VehicleOrderDetailPage.OrderInfo(
                                    orderNum: orderNum,
                                    orderTime: orderTime
                                )
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
                    HStack(spacing: 16) {
                        RoundedCornerButton(
                            nameLocal: L10n.cancel_order,
                            color: .white,
                            bgColor: Color.white.opacity(0.1)
                        ) {
                            intent.onTapCancelOrder()
                        }
                        
                        RoundedCornerButton(
                            nameLocal: L10n.pay_down_payment,
                            color: .black,
                            bgColor: AppTheme.colors.brandMain
                        ) {
                            intent.onTapPayOrder(orderPaymentPhase: 2, paymentAmount: 5000, paymentChannel: "ALIPAY")
                        }
                    }
                    .padding(.horizontal, AppTheme.layout.margin)
                    .padding(.top, 20)
                    .padding(.bottom, 34)
                    .background(AppTheme.colors.cardBackground.shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: -5))
                }
                .ignoresSafeArea()
            }
            .preferredColorScheme(.dark)
        }
    }
}

// MARK: - 私有辅助组件

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

private struct InputField: View {
    var label: LocalizedStringKey
    var placeholder: String
    @Binding var text: String
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
                .multilineTextAlignment(.trailing)
                .disableAutocorrection(true)
                .autocapitalization(.none)
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

private struct SelectField: View {
    var label: LocalizedStringKey
    var placeholder: String
    var value: String
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
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.colors.fontTertiary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct VehicleOrderDetailPage_DownPaymentUnpaid_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState.shared
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
        .environmentObject(appGlobalState)
        .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
