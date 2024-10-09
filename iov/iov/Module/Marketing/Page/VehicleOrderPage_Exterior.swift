//
//  VehicleOrderPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

import SwiftUI
import Kingfisher

/// 车辆订购页 - 外饰
extension VehicleOrderPage {
    struct Exterior: View {
        @StateObject var container: MviContainer<VehicleOrderIntentProtocol, VehicleOrderModelStateProtocol>
        private var intent: VehicleOrderIntentProtocol { container.intent }
        private var state: VehicleOrderModelStateProtocol { container.model }
        @State var exteriors: [SaleModel] = []
        @State private var selectedTab = 0
        
        var body: some View {
            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    ForEach(Array(exteriors.enumerated()), id:\.offset) { index, exterior in
                        KFImage(URL(string: exterior.saleImage)!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                ForEach(Array(exteriors.enumerated()), id:\.offset) { index, exterior in
                    if selectedTab == index {
                        VStack {
                            Text(exterior.saleName)
                                .foregroundStyle(AppTheme.colors.fontPrimary)
                                .font(.system(size: 22))
                            if exterior.salePrice == 0 {
                                Text("价格已包含")
                                    .foregroundStyle(AppTheme.colors.fontSecondary)
                                    .font(.system(size: 15))
                            } else {
                                Text("￥\(String(describing: exterior.salePrice))")
                                    .foregroundStyle(AppTheme.colors.fontSecondary)
                                    .font(.system(size: 15))
                            }
                        }
                    }
                }
                HStack {
                    ForEach(Array(exteriors.enumerated()), id:\.offset) { index, exterior in
                        Button(action: {
                            intent.onTapExterior(code: exterior.saleCode, price: exterior.salePrice)
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
                        .foregroundColor(Color(hexStr: exterior.saleParam))
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
                            intent.onTapExterior(code: firstExterior.saleCode, price: firstExterior.salePrice)
                        }
                    }
                }
            }
        }
    }
}

struct VehicleOrderPage_Exterior_Previews: PreviewProvider {
    static var previews: some View {
        VehicleOrderPage.Exterior(container: VehicleOrderPage.buildContainer(), exteriors: [
            SaleModel.init(saleCode: "H01", saleModelType: "EXTERIOR", saleModelTypeCode: "WS06", saleName: "冰川白车漆", salePrice: 0, saleImage: "https://pic.imgdb.cn/item/67064442d29ded1a8c8801fa.png", saleDesc: "", saleParam: "#e8e8e7"),
            SaleModel.init(saleCode: "H01", saleModelType: "EXTERIOR", saleModelTypeCode: "WS05", saleName: "银河灰车漆", salePrice: 0, saleImage: "https://pic.imgdb.cn/item/6706473ad29ded1a8c8aa3a9.png", saleDesc: "", saleParam: "#868888"),
            SaleModel.init(saleCode: "H01", saleModelType: "EXTERIOR", saleModelTypeCode: "WS04", saleName: "星尘银车漆", salePrice: 0, saleImage: "https://pic.imgdb.cn/item/6706487dd29ded1a8c8bb358.png", saleDesc: "", saleParam: "#cbcbce"),
            SaleModel.init(saleCode: "H01", saleModelType: "EXTERIOR", saleModelTypeCode: "WS03", saleName: "天际蓝车漆", salePrice: 0, saleImage: "https://pic.imgdb.cn/item/67064bc8d29ded1a8c8e461b.png", saleDesc: "", saleParam: "#4681ad"),
            SaleModel.init(saleCode: "H01", saleModelType: "EXTERIOR", saleModelTypeCode: "WS02", saleName: "翡翠绿车漆", salePrice: 0, saleImage: "https://pic.imgdb.cn/item/67065b68d29ded1a8c999b62.png", saleDesc: "", saleParam: "#3a5337"),
            SaleModel.init(saleCode: "H01", saleModelType: "EXTERIOR", saleModelTypeCode: "WS01", saleName: "墨玉黑车漆", salePrice: 0, saleImage: "https://pic.imgdb.cn/item/67065c4fd29ded1a8c9a3714.png", saleDesc: "", saleParam: "#0f0e11")
        ])
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
