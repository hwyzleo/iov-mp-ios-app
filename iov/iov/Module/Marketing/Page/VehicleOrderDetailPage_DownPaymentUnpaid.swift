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
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    AppTheme.colors.background.ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // 顶部导航
                        TopBackTitleBar(titleLocal: LocalizedStringKey("order_detail"))
                            .frame(height: 54)
                            .padding(.horizontal, AppTheme.layout.margin)
                        
                        ScrollView {
                            VStack(spacing: AppTheme.layout.spacing) {
                                // 1. 状态标题
                                HStack {
                                    Text(LocalizedStringKey("down_payment_to_be_paid"))
                                        .font(AppTheme.fonts.bigTitle)
                                        .foregroundColor(AppTheme.colors.fontPrimary)
                                    Spacer()
                                }
                                .padding(.top, 10)
                                
                                // 2. 车型简介卡片
                                VehicleOrderDetailPage.Intro(
                                    saleModelImages: saleModelImages,
                                    saleModelName: saleModelName,
                                    saleModelDesc: saleModelDesc
                                )
                                .appCardStyle()
                                
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
                                        
                                        if purchasePlan == 2 {
                                            HStack {
                                                Text("金融方案")
                                                    .font(AppTheme.fonts.body)
                                                    .foregroundColor(AppTheme.colors.fontPrimary)
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(AppTheme.colors.fontTertiary)
                                            }
                                        }
                                    }
                                }
                                
                                // 4. 车主信息
                                FormSection(title: "车主（车辆所有人）信息") {
                                    VStack(spacing: 12) {
                                        InfoRow(label: orderPersonType == 2 ? "企业名称" : "车主姓名", value: orderPersonName)
                                        if orderPersonType != 2 {
                                            InfoRow(label: "证件类型", value: "身份证")
                                        }
                                        InfoRow(label: orderPersonType == 2 ? "企业代码" : "证件号码", value: orderPersonIdNum)
                                    }
                                }
                                
                                // 5. 交付信息
                                FormSection(title: "交付信息") {
                                    VStack(spacing: 16) {
                                        SelectField(label: "上牌城市", placeholder: "", value: licenseCity, hasError: false) {
                                            intent.onTapLicenseCity()
                                        }
                                        Divider().background(Color.white.opacity(0.05))
                                        SelectField(label: "销售门店", placeholder: "", value: dealershipName, hasError: false) {
                                            intent.onTapDealership()
                                        }
                                        Divider().background(Color.white.opacity(0.05))
                                        SelectField(label: "交付中心", placeholder: "", value: deliveryCenterName, hasError: false) {
                                            intent.onTapDeliveryCenter()
                                        }
                                    }
                                }
                                
                                // 6. 价格明细
                                FormSection(title: "价格明细") {
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
                                }
                                
                                // 7. 订单信息
                                FormSection(title: "订单信息") {
                                    VehicleOrderDetailPage.OrderInfo(
                                        orderNum: orderNum,
                                        orderTime: orderTime
                                    )
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
                                nameLocal: LocalizedStringKey("cancel_order"),
                                color: AppTheme.colors.fontPrimary,
                                bgColor: AppTheme.colors.cardBackground
                            ) {
                                intent.onTapCancelOrder()
                            }
                            
                            RoundedCornerButton(
                                nameLocal: LocalizedStringKey("pay_down_payment"),
                                color: .black,
                                bgColor: AppTheme.colors.brandMain
                            ) {
                                intent.onTapPayOrder(orderPaymentPhase: 2, paymentAmount: 5000, paymentChannel: "ALIPAY")
                            }
                        }
                        .padding(.horizontal, AppTheme.layout.margin)
                        .padding(.top, 20)
                        .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? geometry.safeAreaInsets.bottom : 20)
                        .background(AppTheme.colors.cardBackground.shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: -5))
                    }
                    .ignoresSafeArea()
                }
            }
            .preferredColorScheme(.dark)
            .onAppear {
                if state.selectBookMethod == "" {
                    intent.onTapDownPaymentBookMethod()
                }
            }
        }
    }
}

// MARK: - 辅助组件
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

private struct InfoRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label)
                .font(AppTheme.fonts.body)
                .foregroundColor(AppTheme.colors.fontSecondary)
            Spacer()
            Text(value)
                .font(AppTheme.fonts.body)
                .foregroundColor(AppTheme.colors.fontPrimary)
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
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.colors.fontTertiary)
            }
        }
        .buttonStyle(.plain)
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
