//
//  VehicleOrderPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
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
                TabView(selection: $selectedTab) {
                    ForEach(Array(interiors.enumerated()), id:\.offset) { index, interior in
                        KFImage(URL(string: interior.typeImage[0])!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                ForEach(Array(interiors.enumerated()), id:\.offset) { index, interior in
                    if selectedTab == index {
                        VStack {
                            Text(interior.typeName)
                                .foregroundStyle(AppTheme.colors.fontPrimary)
                                .font(.system(size: 22))
                            if interior.typePrice == 0 {
                                Text(LocalizedStringKey("included"))
                                    .foregroundStyle(AppTheme.colors.fontSecondary)
                                    .font(.system(size: 15))
                            } else {
                                Text("￥\(interior.typePrice.formatted())")
                                    .foregroundStyle(AppTheme.colors.fontSecondary)
                                    .font(.system(size: 15))
                            }
                        }
                    }
                }
                HStack {
                    ForEach(Array(interiors.enumerated()), id:\.offset) { index, interior in
                        Button(action: {
                            selectedTab = index
                            intent.onTapInterior(code: interior.typeCode, price: interior.typePrice)
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
                        .foregroundColor(Color(hexStr: interior.typeParam))
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                Spacer()
            }
            .onAppear() {
                if interiors.isEmpty {
                    interiors = state.interiors
                }
                if !interiors.isEmpty {
                    if state.selectInterior == "" {
                        if let firstInterior = interiors.first {
                            intent.onTapInterior(code: firstInterior.typeCode, price: firstInterior.typePrice)
                        }
                    } else {
                        var i = 0
                        for interior in interiors {
                            if interior.typeCode == state.selectInterior {
                                selectedTab = i
                            }
                            i = i + 1
                        }
                    }
                }
            }
        }
    }
}

struct VehicleModelConfigPage_Interior_Previews: PreviewProvider {
    static var previews: some View {
        VehicleModelConfigPage.Interior(container: VehicleModelConfigPage.buildContainer(), interiors: [
            SaleModelConfig.init(saleCode: "H01", type: "INTERIOR", typeCode: "NS03", typeName: "霜雪白内饰", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/670685e4d29ded1a8cb9c55f.png"], typeDesc: "", typeParam: "#dcdcd6"),
            SaleModelConfig.init(saleCode: "H01", type: "INTERIOR", typeCode: "NS02", typeName: "珊瑚橙内饰", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/670687ecd29ded1a8cbb5280.png"], typeDesc: "", typeParam: "#a35d31"),
            SaleModelConfig.init(saleCode: "H01", type: "INTERIOR", typeCode: "NS01", typeName: "乌木黑内饰", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/670688dbd29ded1a8cbc1321.png"], typeDesc: "", typeParam: "#424141")
        ])
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
