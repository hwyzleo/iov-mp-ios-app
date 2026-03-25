//
//  VehicleWishlistPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/13.
//

import SwiftUI
import Kingfisher

/// 车辆订单详情 - 心愿单
extension VehicleOrderDetailPage {
    struct Wishlist: View {
        @EnvironmentObject var globalState: AppGlobalState
        @Environment(\.dismiss) private var dismiss
        @StateObject var container: MviContainer<VehicleOrderDetailIntentProtocol, VehicleOrderDetailModelStateProtocol>
        private var intent: VehicleOrderDetailIntentProtocol { container.intent }
        var saleModelImages: [String]
        var saleModelName: String
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
        
        @State private var currentIndex = 0
        @State private var showingDeleteConfirm = false
        
        var body: some View {
            ZStack(alignment: .top) {
                // 全屏纯背景色
                AppTheme.colors.background
                    .ignoresSafeArea()
                
                // 2. 主内容区 (向下偏移避开导航栏)
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 60) // 为悬浮导航栏留出空间
                        
                        // 轮播图
                        ZStack(alignment: .bottom) {
                            TabView(selection: $currentIndex) {
                                ForEach(0..<saleModelImages.count, id: \.self) { index in
                                    ZStack {
                                        if !saleModelImages[index].isEmpty {
                                            KFImage(URL(string: saleModelImages[index])!)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 200)
                                        }
                                    }
                                    .tag(index)
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                            .frame(height: 200)
                            .cornerRadius(AppTheme.layout.radiusMedium)
                            
                            // 自定义指示器
                            HStack(spacing: 6) {
                                ForEach(0..<saleModelImages.count, id: \.self) { index in
                                    Capsule()
                                        .fill(currentIndex == index ? AppTheme.colors.brandMain : Color.white.opacity(0.3))
                                        .frame(width: currentIndex == index ? 16 : 6, height: 4)
                                        .animation(.spring(), value: currentIndex)
                                }
                            }
                            .padding(.bottom, 12)
                        }
                        
                        // 详细参数列表
                        VStack(spacing: AppTheme.layout.spacing) {
                            HStack {
                                Text(saleModelName)
                                    .font(AppTheme.fonts.bigTitle)
                                    .foregroundColor(AppTheme.colors.fontPrimary)
                                Spacer()
                                Button(action: { intent.onTapModifySaleModel() }) {
                                    HStack(spacing: 4) {
                                        Image("icon_modify")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundColor(AppTheme.colors.brandMain)
                                            .frame(width: 14, height: 14)
                                        Text(LocalizedStringKey("modify_model_config"))
                                            .font(AppTheme.fonts.subtext)
                                            .foregroundColor(AppTheme.colors.brandMain)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            Group {
                                PriceRow(label: Text(LocalizedStringKey("retail_price")), price: saleModelPrice)
                                PriceRow(label: Text(saleSpareTireName), price: saleSpareTirePrice)
                                PriceRow(label: Text(saleExteriorName), price: saleExteriorPrice)
                                PriceRow(label: Text(saleWheelName), price: saleWheelPrice)
                                PriceRow(label: Text(saleInteriorName), price: saleInteriorPrice)
                                PriceRow(label: Text(saleAdasName), price: saleAdasPrice)
                            }
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            HStack {
                                Text(LocalizedStringKey("total_price"))
                                    .font(AppTheme.fonts.body)
                                    .foregroundColor(AppTheme.colors.fontPrimary)
                                Spacer()
                                Text("￥\(totalPrice.formatted())")
                                    .font(AppTheme.fonts.bigTitle)
                                    .foregroundColor(AppTheme.colors.brandMain)
                            }
                        }
                        .padding(AppTheme.layout.margin)
                        
                        // 底部占位，防止按钮遮挡内容
                        Spacer().frame(height: 100)
                    }
                }
                .scrollIndicators(.hidden)
                
                // 3. 底部操作区 (通过 ZStack 包裹按钮，避免透明 Spacer 拦截点击)
                VStack {
                    Spacer()
                    RoundedCornerButton(
                        nameLocal: LocalizedStringKey("order_now"),
                        color: .black,
                        bgColor: AppTheme.colors.brandMain
                    ) {
                        intent.onTapOrder()
                    }
                    .padding(.horizontal, AppTheme.layout.margin)
                    .padding(.bottom, 20)
                }
                .allowsHitTesting(true) // 仅允许子视图(按钮)拦截点击
                .ignoresSafeArea(.keyboard)
                
                // 1. 顶部自定义导航行 (放在最后以确保在最上层)
                HStack(spacing: 0) {
                    Button {
                        dismiss()
                    } label: {
                        Image("icon_arrow_left")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(AppTheme.colors.fontPrimary)
                            .frame(width: 24, height: 24)
                            .padding(12)
                            .contentShape(Rectangle())
                    }
                    
                    Spacer()
                    
                    Text(LocalizedStringKey("wishlist"))
                        .font(AppTheme.fonts.title1)
                        .foregroundColor(AppTheme.colors.fontPrimary)
                    
                    Spacer()
                    
                    Button {
                        showingDeleteConfirm = true
                    } label: {
                        Image(systemName: "trash")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundColor(AppTheme.colors.fontPrimary)
                            .padding(12)
                            .contentShape(Rectangle())
                    }
                }
                .frame(height: 54)
                .padding(.horizontal, AppTheme.layout.margin - 12)
                .background(AppTheme.colors.background.opacity(0.95))
                .contentShape(Rectangle())
                .zIndex(2)
            }
            .confirmationDialog(
                LocalizedStringKey("confirm_delete"),
                isPresented: $showingDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button(LocalizedStringKey("delete"), role: .destructive) {
                    intent.onTapDelete()
                }
                Button(LocalizedStringKey("cancel"), role: .cancel) {}
            } message: {
                Text(LocalizedStringKey("confirm_delete_wishlist_msg"))
            }
            .navigationBarHidden(true)
            .preferredColorScheme(.dark)
            .onChange(of: globalState.backRefresh) { _ in
                if globalState.backRefresh {
                    globalState.backRefresh = false
                    intent.viewOnAppear()
                }
            }
        }
    }
}

private struct PriceRow: View {
    let label: Text
    let price: Decimal
    var body: some View {
        HStack {
            label
                .font(AppTheme.fonts.body)
                .foregroundColor(AppTheme.colors.fontSecondary)
            Spacer()
            if price == 0 {
                Text(LocalizedStringKey("included"))
                    .font(AppTheme.fonts.body)
                    .foregroundColor(AppTheme.colors.fontPrimary)
            } else {
                Text("￥\(price.formatted())")
                    .font(AppTheme.fonts.body)
                    .foregroundColor(AppTheme.colors.fontPrimary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct VehicleOrderDetailPage_Wishlist_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState.shared
    static var previews: some View {
        VehicleOrderDetailPage.Wishlist(
            container: VehicleOrderDetailPage.buildContainer(),
            saleModelImages: [
                "https://pic.imgdb.cn/item/67065b68d29ded1a8c999b62.png",
                "https://pic.imgdb.cn/item/670685e4d29ded1a8cb9c55f.png"
            ],
            saleModelName: "寒01七座版",
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
            totalPrice: 205888
        )
        .environmentObject(appGlobalState)
        .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
