//
//  VehicleOrderPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

import SwiftUI
import Kingfisher

/// 车辆订购页 - 轮胎
extension VehicleOrderPage {
    struct Wheel: View {
        @StateObject var container: MviContainer<VehicleOrderIntentProtocol, VehicleOrderModelStateProtocol>
        private var intent: VehicleOrderIntentProtocol { container.intent }
        private var state: VehicleOrderModelStateProtocol { container.model }
        @State var wheels: [SaleModel] = []
        @State private var selectedTab = 0
        
        var body: some View {
            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    ForEach(Array(wheels.enumerated()), id:\.offset) { index, wheel in
                        KFImage(URL(string: wheel.saleImage[0])!)
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
                            intent.onTapWheel(code: wheel.saleCode, price: wheel.salePrice)
                        }) {
                            VStack {
                                Text(wheel.saleName)
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
                            intent.onTapWheel(code: firstWheel.saleCode, price: firstWheel.salePrice)
                        }
                    }
                }
            }
        }
    }
}

struct VehicleOrderPage_Wheel_Previews: PreviewProvider {
    static var previews: some View {
        VehicleOrderPage.Wheel(container: VehicleOrderPage.buildContainer(), wheels: [
            SaleModel.init(saleCode: "H01", saleModelType: "WHEEL", saleModelTypeCode: "CL04", saleName: "21寸轮毂(四季胎)枪灰色", salePrice: 0, saleImage: ["https://pic.imgdb.cn/item/67067e41d29ded1a8cb3ac99.png"], saleDesc: "标配倍耐力Scorpion轮胎", saleParam: ""),
            SaleModel.init(saleCode: "H01", saleModelType: "WHEEL", saleModelTypeCode: "CL03", saleName: "21寸轮毂(四季胎)高亮黑", salePrice: 0, saleImage: ["https://pic.imgdb.cn/item/67067e41d29ded1a8cb3ac99.png"], saleDesc: "标配倍耐力Scorpion轮胎", saleParam: ""),
        ])
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
