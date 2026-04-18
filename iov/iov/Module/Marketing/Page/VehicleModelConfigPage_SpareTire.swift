//
//  VehicleOrderPage.swift
//  iov
//
//  Created by hwyz_leo on 2024/10/6.
//

import SwiftUI
import Kingfisher

/// 车辆车型配置页 - 备胎
extension VehicleModelConfigPage {
    struct SpareTire: View {
        @StateObject var container: MviContainer<VehicleModelConfigIntentProtocol, VehicleModelConfigModelStateProtocol>
        private var intent: VehicleModelConfigIntentProtocol { container.intent }
        private var state: VehicleModelConfigModelStateProtocol { container.model }
        @State var spareTires: [SaleModelConfig] = []
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
                        ForEach(Array(spareTires.enumerated()), id:\.offset) { index, spareTire in
                            KFImage(URL(string: spareTire.typeImage[0])!)
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
                if !spareTires.isEmpty && selectedTab < spareTires.count {
                    VStack(spacing: 8) {
                        Text(spareTires[selectedTab].typeName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.colors.fontPrimary)
                        
                        Text(spareTires[selectedTab].typePrice == 0 ? LocalizedStringKey("included") : "￥\(spareTires[selectedTab].typePrice.formatted())")
                            .font(AppTheme.fonts.body)
                            .foregroundColor(AppTheme.colors.brandMain)
                        
                        Text(spareTires[selectedTab].typeDesc ?? "")
                            .font(AppTheme.fonts.subtext)
                            .foregroundColor(AppTheme.colors.fontSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 4)
                    }
                    .padding(.top, 24)
                }
                
                // 备胎选择器
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(Array(spareTires.enumerated()), id:\.offset) { index, spareTire in
                            Button(action: {
                                withAnimation(.spring()) {
                                    selectedTab = index
                                    intent.onTapSpareTire(code: spareTire.typeCode, price: spareTire.typePrice)
                                }
                            }) {
                                Text(spareTire.typeName)
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
                if spareTires.isEmpty {
                    spareTires = state.spareTires
                }
                syncSelectedIndex()
                if !spareTires.isEmpty && state.selectSpareTire == "" {
                    if let firstSpareTire = spareTires.first {
                        intent.onTapSpareTire(code: firstSpareTire.typeCode, price: firstSpareTire.typePrice)
                    }
                }
            }
            .onChange(of: state.selectSpareTire) { _ in
                syncSelectedIndex()
            }
        }
        
        private func syncSelectedIndex() {
            if let index = spareTires.firstIndex(where: { $0.typeCode == state.selectSpareTire }) {
                selectedTab = index
            }
        }
    }
}

struct VehicleModelConfigPage_SpareTire_Previews: PreviewProvider {
    static var previews: some View {
        VehicleModelConfigPage.SpareTire(container: VehicleModelConfigPage.buildContainer(), spareTires: [
            SaleModelConfig.init(saleCode: "H01", type: "SPIRE_TIRE", typeCode: "X05", typeName: "外挂式全尺寸备胎", typePrice: 6000, typeImage: ["https://pic.imgdb.cn/item/67065c4fd29ded1a8c9a3714.png"], typeDesc: "含备胎车长5295毫米", typeParam: ""),
            SaleModelConfig.init(saleCode: "H01", type: "SPIRE_TIRE", typeCode: "X00", typeName: "无备胎", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/670674cfd29ded1a8cac9cb3.png"], typeDesc: "车长5050毫米", typeParam: "")
        ])
            .appBackground()
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
