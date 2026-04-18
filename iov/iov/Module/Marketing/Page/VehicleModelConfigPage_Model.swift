//
//  VehicleOrderPage.swift
//  iov
//
//  Created by hwyz_leo on 2024/10/6.
//

import SwiftUI
import Kingfisher

/// 车辆车型配置页 - 车型
extension VehicleModelConfigPage {
    struct Model: View {
        @StateObject var container: MviContainer<VehicleModelConfigIntentProtocol, VehicleModelConfigModelStateProtocol>
        private var intent: VehicleModelConfigIntentProtocol { container.intent }
        private var state: VehicleModelConfigModelStateProtocol { container.model }
        @State var models: [SaleModelConfig] = []
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
                        ForEach(Array(models.enumerated()), id:\.offset) { index, model in
                            KFImage(URL(string: model.typeImage[0])!)
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
                if !models.isEmpty && selectedTab < models.count {
                    VStack(spacing: 8) {
                        Text(models[selectedTab].typeName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.colors.fontPrimary)
                        
                        Text("￥\(models[selectedTab].typePrice.formatted())")
                            .font(AppTheme.fonts.body)
                            .foregroundColor(AppTheme.colors.brandMain)
                        
                        Text(models[selectedTab].typeDesc ?? "")
                            .font(AppTheme.fonts.subtext)
                            .foregroundColor(AppTheme.colors.fontSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 4)
                    }
                    .padding(.top, 24)
                }
                
                // 车型选择器
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(Array(models.enumerated()), id:\.offset) { index, model in
                            Button(action: {
                                withAnimation(.spring()) {
                                    selectedTab = index
                                    intent.onTapModel(code: model.typeCode, name: model.typeName, price: model.typePrice)
                                }
                            }) {
                                Text(model.typeName)
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
                if models.isEmpty {
                    models = state.models
                }
                syncSelectedIndex()
                if !models.isEmpty && state.selectModel == "" {
                    if let firstModel = models.first {
                        intent.onTapModel(code: firstModel.typeCode, name: firstModel.typeName, price: firstModel.typePrice)
                    }
                }
            }
            .onChange(of: state.selectModel) { _ in
                syncSelectedIndex()
            }
        }
        
        private func syncSelectedIndex() {
            if let index = models.firstIndex(where: { $0.typeCode == state.selectModel }) {
                selectedTab = index
            }
        }
    }
}

struct VehicleModelConfigPage_Model_Previews: PreviewProvider {
    static var previews: some View {
        VehicleModelConfigPage.Model(container: VehicleModelConfigPage.buildContainer(), models: [
            SaleModelConfig.init(saleCode: "H01", type: "MODEL", typeCode: "H0106", typeName: "寒01 6座版", typePrice: 88888, typeImage: ["https://pic.imgdb.cn/item/67065c4fd29ded1a8c9a3714.png"], typeDesc: "2-2-2六座，双侧零重力航空座椅，行政奢华", typeParam: ""),
            SaleModelConfig.init(saleCode: "H01", type: "MODEL", typeCode: "H0107", typeName: "寒01 7座版", typePrice: 88888, typeImage: ["https://pic.imgdb.cn/item/67065c4fd29ded1a8c9a3714.png"], typeDesc: "2-2-3七座，二排超宽通道，二三排可放平", typeParam: "")
        ])
            .appBackground()
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
