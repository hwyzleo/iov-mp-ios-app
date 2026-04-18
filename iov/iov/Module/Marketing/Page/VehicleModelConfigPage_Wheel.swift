//
//  VehicleOrderPage.swift
//  iov
//
//  Created by hwyz_leo on 2024/10/6.
//

import SwiftUI
import Kingfisher

/// 车辆车型配置页 - 轮毂
extension VehicleModelConfigPage {
    struct Wheel: View {
        @StateObject var container: MviContainer<VehicleModelConfigIntentProtocol, VehicleModelConfigModelStateProtocol>
        private var intent: VehicleModelConfigIntentProtocol { container.intent }
        private var state: VehicleModelConfigModelStateProtocol { container.model }
        @State var wheels: [SaleModelConfig] = []
        @State private var selectedTab = 0
        
        var body: some View {
            VStack(spacing: 0) {
                // 展示舞台
                ZStack(alignment: .bottom) {
                    // 底部阴影/舞台光
                    Ellipse()
                        .fill(RadialGradient(colors: [Color.white.opacity(0.1), Color.clear], center: .center, startRadius: 0, endRadius: 150))
                        .frame(width: 300, height: 60)
                        .blur(radius: 20)
                        .offset(y: 20)
                    
                    TabView(selection: $selectedTab) {
                        ForEach(Array(wheels.enumerated()), id:\.offset) { index, wheel in
                            KFImage(URL(string: wheel.typeImage[0])!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .tag(index)
                        }
                    }
                    .frame(height: 240)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
                .padding(.top, 20)
                
                // 选中的文字描述
                if !wheels.isEmpty && selectedTab < wheels.count {
                    VStack(spacing: 8) {
                        Text(wheels[selectedTab].typeName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.colors.fontPrimary)
                        
                        Text(wheels[selectedTab].typePrice == 0 ? LocalizedStringKey("included") : "￥\(wheels[selectedTab].typePrice.formatted())")
                            .font(AppTheme.fonts.body)
                            .foregroundColor(AppTheme.colors.brandMain)
                        
                        Text(wheels[selectedTab].typeDesc ?? "")
                            .font(AppTheme.fonts.subtext)
                            .foregroundColor(AppTheme.colors.fontSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 4)
                    }
                    .padding(.top, 24)
                }
                
                // 轮毂选择器
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(Array(wheels.enumerated()), id:\.offset) { index, wheel in
                            Button(action: {
                                withAnimation(.spring()) {
                                    selectedTab = index
                                    intent.onTapWheel(code: wheel.typeCode, price: wheel.typePrice)
                                }
                            }) {
                                Text(wheel.typeName)
                                    .font(.system(size: 14, weight: selectedTab == index ? .bold : .regular))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(selectedTab == index ? AppTheme.colors.brandMain : AppTheme.colors.cardBackground)
                                    .foregroundColor(selectedTab == index ? .white : AppTheme.colors.fontPrimary)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(AppTheme.colors.brandMain.opacity(0.3), lineWidth: selectedTab == index ? 0 : 1)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 32)
                
                Spacer()
            }
            .onAppear() {
                if wheels.isEmpty {
                    wheels = state.wheels
                }
                syncSelectedIndex()
                if !wheels.isEmpty && state.selectWheel == "" {
                    if let firstWheel = wheels.first {
                        intent.onTapWheel(code: firstWheel.typeCode, price: firstWheel.typePrice)
                    }
                }
            }
            .onChange(of: state.selectWheel) { _ in
                syncSelectedIndex()
            }
        }
        
        private func syncSelectedIndex() {
            if let index = wheels.firstIndex(where: { $0.typeCode == state.selectWheel }) {
                selectedTab = index
            }
        }
    }
}

struct VehicleModelConfigPage_Wheel_Previews: PreviewProvider {
    static var previews: some View {
        VehicleModelConfigPage.Wheel(container: VehicleModelConfigPage.buildContainer(), wheels: [
            SaleModelConfig.init(saleCode: "H01", type: "WHEEL", typeCode: "CL04", typeName: "21寸轮毂(四季胎)枪灰色", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/67067e41d29ded1a8cb3ac99.png"], typeDesc: "标配倍耐力Scorpion轮胎", typeParam: ""),
            SaleModelConfig.init(saleCode: "H01", type: "WHEEL", typeCode: "CL03", typeName: "21寸轮毂(四季胎)高亮黑", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/67067e41d29ded1a8cb3ac99.png"], typeDesc: "标配倍耐力Scorpion轮胎", typeParam: ""),
        ])
            .appBackground()
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
