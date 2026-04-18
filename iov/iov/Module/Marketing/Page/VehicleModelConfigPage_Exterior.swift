//
//  VehicleOrderPage.swift
//  iov
//
//  Created by hwyz_leo on 2024/10/6.
//

import SwiftUI
import Kingfisher

/// 车辆车型配置页 - 外饰
extension VehicleModelConfigPage {
    struct Exterior: View {
        @StateObject var container: MviContainer<VehicleModelConfigIntentProtocol, VehicleModelConfigModelStateProtocol>
        private var intent: VehicleModelConfigIntentProtocol { container.intent }
        private var state: VehicleModelConfigModelStateProtocol { container.model }
        @State var exteriors: [SaleModelConfig] = []
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
                        ForEach(Array(exteriors.enumerated()), id:\.offset) { index, exterior in
                            KFImage(URL(string: exterior.typeImage[0])!)
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
                if !exteriors.isEmpty && selectedTab < exteriors.count {
                    VStack(spacing: 6) {
                        Text(exteriors[selectedTab].typeName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.colors.fontPrimary)
                        
                        Text(exteriors[selectedTab].typePrice == 0 ? LocalizedStringKey("included") : "￥\(exteriors[selectedTab].typePrice.formatted())")
                            .font(AppTheme.fonts.body)
                            .foregroundColor(AppTheme.colors.brandMain)
                    }
                    .padding(.top, 24)
                }
                
                // 色块选择器
                HStack(spacing: 18) {
                    ForEach(Array(exteriors.enumerated()), id:\.offset) { index, exterior in
                        Button(action: {
                            withAnimation(.spring()) {
                                selectedTab = index
                                intent.onTapExterior(code: exterior.typeCode, price: exterior.typePrice)
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(hexStr: exterior.typeParam ?? ""))
                                    .frame(width: 36, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: selectedTab == index ? 2 : 0)
                                            .padding(-4)
                                    )
                                    .shadow(color: Color(hexStr: exterior.typeParam ?? "").opacity(selectedTab == index ? 0.6 : 0), radius: 8)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 32)
                
                Spacer()
            }
            .onAppear() {
                if exteriors.isEmpty {
                    exteriors = state.exteriors
                }
                syncSelectedIndex()
                if !exteriors.isEmpty && state.selectExterior == "" {
                    if let firstExterior = exteriors.first {
                        intent.onTapExterior(code: firstExterior.typeCode, price: firstExterior.typePrice)
                    }
                }
            }
            .onChange(of: state.selectExterior) { _ in
                syncSelectedIndex()
            }
        }
        
        private func syncSelectedIndex() {
            if let index = exteriors.firstIndex(where: { $0.typeCode == state.selectExterior }) {
                selectedTab = index
            }
        }
    }
}
