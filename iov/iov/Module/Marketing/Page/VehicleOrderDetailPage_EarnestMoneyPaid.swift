//
//  VehicleOrderDetailPage_EarnestMoneyPaid.swift
//  iov
//
//  Created by hwyz_leo on 2024/10/13.
//

import SwiftUI
import Kingfisher

/// 车辆订单详情 - 意向金已支付页
extension VehicleOrderDetailPage {
    struct EarnestMoneyPaid: View {
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
        @State var selectLicenseCityName: String
        @State var selectLicenseCityCode: String
        
        var body: some View {
            ZStack(alignment: .top) {
                AppTheme.colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 顶部导航
                    ZStack {
                        TopBackTitleBar(titleLocal: L10n.order_detail, color: .white)
                        HStack {
                            Spacer()
                            Button(action: {
                                intent.onTapDelete()
                            }) {
                                Image(systemName: "trash")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, AppTheme.layout.margin)
                    }
                    .frame(height: 54)
                    
                    ScrollView {
                        VStack(spacing: AppTheme.layout.spacing) {
                            // 1. 状态展示
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(L10n.earnest_money_paid)
                                        .font(AppTheme.fonts.bigTitle)
                                        .foregroundColor(AppTheme.colors.fontPrimary)
                                }
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
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
                            
                            // 3. 交付信息
                            FormSection(title: L10n.delivery_info) {
                                SelectField(label: L10n.license_city, placeholder: "请选择", value: selectLicenseCityName) {
                                    intent.onTapLicenseCity()
                                }
                            }
                            
                            // 4. 价格明细
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
                            
                            // 5. 订单信息
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
                            nameLocal: L10n.request_refund,
                            color: .white,
                            bgColor: Color.white.opacity(0.1)
                        ) {
                            // 退款逻辑由 Intent 处理或提示
                        }
                        
                        RoundedCornerButton(
                            nameLocal: L10n.earnest_money_to_down_payment,
                            color: .black,
                            bgColor: AppTheme.colors.brandMain
                        ) {
                            intent.onTapEarnestMoneyToDownPayment()
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
            .onChange(of: globalState.backRefresh) { _ in
                if globalState.backRefresh {
                    globalState.backRefresh = false
                    if let cityName = AppGlobalState.shared.parameters["licenseCityName"] as? String {
                        selectLicenseCityName = cityName
                        selectLicenseCityCode = AppGlobalState.shared.parameters["licenseCityCode"] as? String ?? ""
                    }
                }
            }
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

struct VehicleOrderDetailPage_EarnestMoneyPaid_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState.shared
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
        .environmentObject(appGlobalState)
        .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
