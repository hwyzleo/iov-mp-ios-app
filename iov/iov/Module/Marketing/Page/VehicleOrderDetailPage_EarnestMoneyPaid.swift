//
//  VehicleOrderDetailPage_EarnestMoneyPaid.swift
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
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    AppTheme.colors.background.ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // 顶部导航
                        ZStack {
                            TopBackTitleBar(titleLocal: LocalizedStringKey("order_detail"))
                            HStack {
                                Spacer()
                                Button(action: {
                                    intent.onTapDelete()
                                }) {
                                    Image("icon_setting")
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundColor(AppTheme.colors.fontPrimary)
                                        .frame(width: 24, height: 24)
                                }
                            }
                        }
                        .frame(height: 54)
                        .padding(.horizontal, AppTheme.layout.margin)
                        
                        ScrollView {
                            VStack(spacing: AppTheme.layout.spacing) {
                                // 1. 状态标题
                                HStack {
                                    Text(LocalizedStringKey("earnest_money_paid"))
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
                                
                                // 3. 上牌及门店信息
                                FormSection(title: "上牌及门店信息") {
                                    Button(action: { intent.onTapLicenseCity() }) {
                                        HStack {
                                            Text("上牌城市")
                                                .font(AppTheme.fonts.body)
                                                .foregroundColor(AppTheme.colors.fontPrimary)
                                            Spacer()
                                            Text(selectLicenseCityName.isEmpty ? "请选择" : selectLicenseCityName)
                                                .font(AppTheme.fonts.body)
                                                .foregroundColor(selectLicenseCityName.isEmpty ? AppTheme.colors.fontTertiary : AppTheme.colors.fontPrimary)
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 12))
                                                .foregroundColor(AppTheme.colors.fontTertiary)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                    .buttonStyle(.plain)
                                }
                                
                                // 4. 价格明细
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
                                
                                // 5. 订单信息
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
                                nameLocal: LocalizedStringKey("request_refund"),
                                color: AppTheme.colors.fontPrimary,
                                bgColor: AppTheme.colors.cardBackground
                            ) {
                                // 退款逻辑
                            }
                            
                            RoundedCornerButton(
                                nameLocal: LocalizedStringKey("earnest_money_to_down_payment"),
                                color: .black,
                                bgColor: AppTheme.colors.brandMain
                            ) {
                                intent.onTapEarnestMoneyToDownPayment()
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
