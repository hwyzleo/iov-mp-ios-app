//
//  VehicleOrderPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
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
        
        var body: some View {
            VStack {
                ForEach(Array(spareTires.enumerated()), id:\.offset) { index, spareTire in
                    Button(action: {
                        intent.onTapSpareTire(code: spareTire.typeCode, price: spareTire.typePrice)
                    }) {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(state.selectSpareTire == spareTire.typeCode ? Color.orange : Color.gray, lineWidth: 1)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                            .frame(height: 220)
                            .background(Color(hex: 0xfbfbfb))
                            .overlay(
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(spareTire.typeName)
                                            .bold()
                                        Spacer()
                                    }
                                    HStack {
                                        VStack {
                                            if spareTire.typePrice == 0 {
                                                Text(LocalizedStringKey("price_included"))
                                            } else {
                                                Text("￥\(spareTire.typePrice.formatted())")
                                            }
                                            Spacer()
                                        }
                                        Spacer()
                                        KFImage(URL(string: spareTire.typeImage[0])!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    }
                                    Text(spareTire.typeDesc)
                                        .foregroundStyle(AppTheme.colors.fontSecondary)
                                        .font(.system(size: 12))
                                    Spacer()
                                }
                                .padding(10)
                            )
                    }
                    .buttonStyle(.plain)
                    Spacer().frame(height: 20)
                }
                Spacer()
            }
            .onAppear() {
                if spareTires.isEmpty {
                    spareTires = state.spareTires
                }
                if !spareTires.isEmpty {
                    if state.selectSpareTire == "" {
                        if let firstSpareTire = spareTires.first {
                            intent.onTapSpareTire(code: firstSpareTire.typeCode, price: firstSpareTire.typePrice)
                        }
                    }
                }
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
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
