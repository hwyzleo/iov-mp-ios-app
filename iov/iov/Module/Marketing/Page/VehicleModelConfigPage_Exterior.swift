//
//  VehicleOrderPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
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
                TabView(selection: $selectedTab) {
                    ForEach(Array(exteriors.enumerated()), id:\.offset) { index, exterior in
                        KFImage(URL(string: exterior.typeImage[0])!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                ForEach(Array(exteriors.enumerated()), id:\.offset) { index, exterior in
                    VStack {
                        if selectedTab == index {
                            Text(exterior.typeName)
                                .foregroundStyle(AppTheme.colors.fontPrimary)
                                .font(.system(size: 22))
                            if exterior.typePrice == 0 {
                                Text(LocalizedStringKey("included"))
                                    .foregroundStyle(AppTheme.colors.fontSecondary)
                                    .font(.system(size: 15))
                            } else {
                                Text("￥\(exterior.typePrice.formatted())")
                                    .foregroundStyle(AppTheme.colors.fontSecondary)
                                    .font(.system(size: 15))
                            }
                        }
                    }
                }
                HStack {
                    ForEach(Array(exteriors.enumerated()), id:\.offset) { index, exterior in
                        Button(action: {
                            intent.onTapExterior(code: exterior.typeCode, price: exterior.typePrice)
                            selectedTab = index
                        }) {
                            ZStack {
                                Image(systemName: "circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                if selectedTab == index {
                                    Image(systemName: "circle")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                }
                            }
                        }
                        .foregroundColor(Color(hexStr: exterior.typeParam))
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                Spacer().frame(height: 100)
            }
            .onAppear() {
                if exteriors.isEmpty {
                    exteriors = state.exteriors
                }
                if !exteriors.isEmpty {
                    if state.selectExterior == "" {
                        if let firstExterior = exteriors.first {
                            intent.onTapExterior(code: firstExterior.typeCode, price: firstExterior.typePrice)
                        }
                    }
                }
            }
        }
    }
}

struct VehicleModelConfigPage_Exterior_Previews: PreviewProvider {
    static var previews: some View {
        VehicleModelConfigPage.Exterior(container: VehicleModelConfigPage.buildContainer(), exteriors: [
            SaleModelConfig.init(saleCode: "H01", type: "EXTERIOR", typeCode: "WS06", typeName: "冰川白车漆", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/67064442d29ded1a8c8801fa.png"], typeDesc: "", typeParam: "#e8e8e7"),
            SaleModelConfig.init(saleCode: "H01", type: "EXTERIOR", typeCode: "WS05", typeName: "银河灰车漆", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/6706473ad29ded1a8c8aa3a9.png"], typeDesc: "", typeParam: "#868888"),
            SaleModelConfig.init(saleCode: "H01", type: "EXTERIOR", typeCode: "WS04", typeName: "星尘银车漆", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/6706487dd29ded1a8c8bb358.png"], typeDesc: "", typeParam: "#cbcbce"),
            SaleModelConfig.init(saleCode: "H01", type: "EXTERIOR", typeCode: "WS03", typeName: "天际蓝车漆", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/67064bc8d29ded1a8c8e461b.png"], typeDesc: "", typeParam: "#4681ad"),
            SaleModelConfig.init(saleCode: "H01", type: "EXTERIOR", typeCode: "WS02", typeName: "翡翠绿车漆", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/67065b68d29ded1a8c999b62.png"], typeDesc: "", typeParam: "#3a5337"),
            SaleModelConfig.init(saleCode: "H01", type: "EXTERIOR", typeCode: "WS01", typeName: "墨玉黑车漆", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/67065c4fd29ded1a8c9a3714.png"], typeDesc: "", typeParam: "#0f0e11")
        ])
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
