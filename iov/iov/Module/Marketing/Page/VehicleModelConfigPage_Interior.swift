//
//  VehicleOrderPage.swift
//  iov
//
//  Created by hwyz_leo on 2024/10/6.
//

import SwiftUI
import Kingfisher

/// 车辆车型配置页 - 内饰
extension VehicleModelConfigPage {
    struct Interior: View {
        @StateObject var container: MviContainer<VehicleModelConfigIntentProtocol, VehicleModelConfigModelStateProtocol>
        private var intent: VehicleModelConfigIntentProtocol { container.intent }
        private var state: VehicleModelConfigModelStateProtocol { container.model }
        @State var interiors: [SaleModelConfig] = []
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
                        ForEach(Array(interiors.enumerated()), id:\.offset) { index, interior in
                            KFImage(URL(string: interior.typeImage[0])!)
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
                if !interiors.isEmpty && selectedTab < interiors.count {
                    VStack(spacing: 8) {
                        Text(interiors[selectedTab].typeName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.colors.fontPrimary)
                        
                        Text(interiors[selectedTab].typePrice == 0 ? LocalizedStringKey("included") : "￥\(interiors[selectedTab].typePrice.formatted())")
                            .font(AppTheme.fonts.body)
                            .foregroundColor(AppTheme.colors.brandMain)
                        
                        Text(interiors[selectedTab].typeDesc ?? "")
                            .font(AppTheme.fonts.subtext)
                            .foregroundColor(AppTheme.colors.fontSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 4)
                    }
                    .padding(.top, 24)
                }
                
                // 内饰色块选择器
                HStack(spacing: 20) {
                    ForEach(Array(interiors.enumerated()), id:\.offset) { index, interior in
                        Button(action: {
                            withAnimation(.spring()) {
                                selectedTab = index
                                intent.onTapInterior(code: interior.typeCode, price: interior.typePrice)
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(hexStr: interior.typeParam ?? ""))
                                    .frame(width: 36, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: selectedTab == index ? 2 : 0)
                                            .padding(-4)
                                    )
                                    .shadow(color: Color(hexStr: interior.typeParam ?? "").opacity(selectedTab == index ? 0.6 : 0), radius: 8)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 32)
                
                Spacer()
            }
            .onAppear() {
                if interiors.isEmpty {
                    interiors = state.interiors
                }
                syncSelectedIndex()
                if !interiors.isEmpty && state.selectInterior == "" {
                    if let firstInterior = interiors.first {
                        intent.onTapInterior(code: firstInterior.typeCode, price: firstInterior.typePrice)
                    }
                }
            }
            .onChange(of: state.selectInterior) { _ in
                syncSelectedIndex()
            }
        }
        
        private func syncSelectedIndex() {
            if let index = interiors.firstIndex(where: { $0.typeCode == state.selectInterior }) {
                selectedTab = index
            }
        }
    }
}

struct VehicleModelConfigPage_Interior_Previews: PreviewProvider {
    static var previews: some View {
        VehicleModelConfigPage.Interior(container: VehicleModelConfigPage.buildContainer(), interiors: [
            SaleModelConfig.init(saleCode: "H01", type: "INTERIOR", typeCode: "NS03", typeName: "霜雪白内饰", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/670685e4d29ded1a8cb9c55f.png"], typeDesc: "", typeParam: "#dcdcd6"),
            SaleModelConfig.init(saleCode: "H01", type: "INTERIOR", typeCode: "NS02", typeName: "珊瑚橙内饰", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/670687ecd29ded1a8cbb5280.png"], typeDesc: "", typeParam: "#a35d31")
        ])
            .appBackground()
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
