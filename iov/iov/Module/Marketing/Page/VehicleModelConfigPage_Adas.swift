//
//  VehicleOrderPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

import SwiftUI
import Kingfisher

/// 车辆车型配置页 - 智驾
extension VehicleModelConfigPage {
    struct Adas: View {
        @StateObject var container: MviContainer<VehicleModelConfigIntentProtocol, VehicleModelConfigModelStateProtocol>
        private var intent: VehicleModelConfigIntentProtocol { container.intent }
        private var state: VehicleModelConfigModelStateProtocol { container.model }
        @State var adases: [SaleModelConfig] = []
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
                        ForEach(Array(adases.enumerated()), id:\.offset) { index, adas in
                            KFImage(URL(string: adas.typeImage[0])!)
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
                if !adases.isEmpty && selectedTab < adases.count {
                    VStack(spacing: 8) {
                        Text(adases[selectedTab].typeName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.colors.fontPrimary)
                        
                        Text(adases[selectedTab].typePrice == 0 ? LocalizedStringKey("included") : "￥\(adases[selectedTab].typePrice.formatted())")
                            .font(AppTheme.fonts.body)
                            .foregroundColor(AppTheme.colors.brandMain)
                        
                        Text(adases[selectedTab].typeDesc ?? "")
                            .font(AppTheme.fonts.subtext)
                            .foregroundColor(AppTheme.colors.fontSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 4)
                    }
                    .padding(.top, 24)
                }
                
                // 智驾选择器
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(Array(adases.enumerated()), id:\.offset) { index, adas in
                            Button(action: {
                                withAnimation(.spring()) {
                                    selectedTab = index
                                    intent.onTapAdas(code: adas.typeCode, price: adas.typePrice)
                                }
                            }) {
                                Text(adas.typeName)
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
                if adases.isEmpty {
                    adases = state.adases
                }
                syncSelectedIndex()
                if !adases.isEmpty && state.selectAdas == "" {
                    if let firstAdas = adases.first {
                        intent.onTapAdas(code: firstAdas.typeCode, price: firstAdas.typePrice)
                    }
                }
            }
            .onChange(of: state.selectAdas) { _ in
                syncSelectedIndex()
            }
        }
        
        private func syncSelectedIndex() {
            if let index = adases.firstIndex(where: { $0.typeCode == state.selectAdas }) {
                selectedTab = index
            }
        }
    }
}

struct VehicleModelConfigPage_Adas_Previews: PreviewProvider {
    static var previews: some View {
        VehicleModelConfigPage.Adas(container: VehicleModelConfigPage.buildContainer(), adases: [
            SaleModelConfig.init(saleCode: "H01", type: "ADAS", typeCode: "X02", typeName: "高阶智驾", typePrice: 20000, typeImage: ["https://pic.imgdb.cn/item/67065c4fd29ded1a8c9a3714.png"], typeDesc: "全场景智能驾驶辅助", typeParam: ""),
            SaleModelConfig.init(saleCode: "H01", type: "ADAS", typeCode: "X00", typeName: "标准智驾", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/670674cfd29ded1a8cac9cb3.png"], typeDesc: "基础安全驾驶辅助", typeParam: "")
        ])
            .appBackground()
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
