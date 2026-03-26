//
//  VehicleOrderDetailPage_Invoiced.swift
//  iov
//
//  Created by Gemini on 2026/3/26.
//

import SwiftUI
import Kingfisher

/// 车辆订单详情 - 已开票页
extension VehicleOrderDetailPage {
    struct Invoiced: View {
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
                                    Text(L10n.invoiced)
                                        .font(AppTheme.fonts.bigTitle)
                                        .foregroundColor(AppTheme.colors.fontPrimary)
                                }
                                Spacer()
                                Image(systemName: "doc.text.fill")
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
                            
                            // 3. 价格明细
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
                            
                            // 4. 订单信息
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
                    VStack(spacing: 0) {
                        Text("车辆发票已开具，请等待提车通知")
                            .font(AppTheme.fonts.subtext)
                            .foregroundColor(AppTheme.colors.fontSecondary)
                            .padding(.vertical, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.colors.cardBackground.shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: -5))
                }
                .ignoresSafeArea()
            }
            .preferredColorScheme(.dark)
        }
    }
}

struct VehicleOrderDetailPage_Invoiced_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState.shared
    static var previews: some View {
        VehicleOrderDetailPage.Invoiced(
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
            orderTime: 1729403155
        )
        .environmentObject(appGlobalState)
        .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
