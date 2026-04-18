//
//  VehicleOrderDetailPage_Intro.swift
//  iov
//
//  Created by hwyz_leo on 2024/10/13.
//

import SwiftUI
import Kingfisher

/// 车辆订单详情 - 车型简介部分
extension VehicleOrderDetailPage {
    struct Intro: View {
        var saleModelImages: [String]
        var saleModelName: String
        var saleModelDesc: String
        
        @State private var currentIndex = 0
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                // 车辆轮播图 (采用探索页走马灯样式)
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
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(saleModelName)
                        .font(AppTheme.fonts.bigTitle)
                        .foregroundColor(AppTheme.colors.fontPrimary)
                    
                    Text(saleModelDesc)
                        .font(AppTheme.fonts.subtext)
                        .foregroundColor(AppTheme.colors.fontSecondary)
                        .lineSpacing(4)
                }
                .padding(.top, 20)
            }
        }
    }
}

struct VehicleOrderDetailPage_Intro_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppTheme.colors.background.ignoresSafeArea()
            VehicleOrderDetailPage.Intro(
                saleModelImages: [
                    "https://pic.imgdb.cn/item/67065b68d29ded1a8c999b62.png",
                    "https://pic.imgdb.cn/item/670685e4d29ded1a8cb9c55f.png"
                ],
                saleModelName: "寒01七座版",
                saleModelDesc: "寒01七座版 | 有备胎 | 翡翠绿车漆 | 21寸轮毂(四季胎)高亮黑 | 乌木黑内饰 | 高阶智驾"
            )
            .appCardStyle()
            .padding()
        }
        .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
