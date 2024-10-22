//
//  VehicleOrderPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

import SwiftUI
import Kingfisher

/// 车辆车型配置页 - 轮胎
extension VehicleModelConfigPage {
    struct Wheel: View {
        @StateObject var container: MviContainer<VehicleModelConfigIntentProtocol, VehicleModelConfigModelStateProtocol>
        private var intent: VehicleModelConfigIntentProtocol { container.intent }
        private var state: VehicleModelConfigModelStateProtocol { container.model }
        @State var wheels: [SaleModelConfig] = []
        @State private var selectedTab = 0
        
        var body: some View {
            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    ForEach(Array(wheels.enumerated()), id:\.offset) { index, wheel in
                        KFImage(URL(string: wheel.typeImage[0])!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                Spacer().frame(height: 20)
                HStack {
                    ForEach(Array(wheels.enumerated()), id:\.offset) { index, wheel in
                        Button(action: {
                            selectedTab = index
                            intent.onTapWheel(code: wheel.typeCode, price: wheel.typePrice)
                        }) {
                            VStack {
                                Text(wheel.typeName)
                            }
                        }
                        .foregroundColor(selectedTab == index ? AppTheme.colors.fontPrimary : AppTheme.colors.fontSecondary)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                Spacer()
            }
            .onAppear() {
                if wheels.isEmpty {
                    wheels = state.wheels
                }
                if !wheels.isEmpty {
                    if state.selectWheel == "" {
                        if let firstWheel = wheels.first {
                            intent.onTapWheel(code: firstWheel.typeCode, price: firstWheel.typePrice)
                        }
                    }
                }
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
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
