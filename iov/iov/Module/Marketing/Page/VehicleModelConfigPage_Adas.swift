//
//  VehicleOrderPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

import SwiftUI
import Kingfisher

/// 车辆车型配置页 - 智驾
extension VehicleModelConfigPage {
    struct Adas: View {
        @StateObject var container: MviContainer<VehicleModelConfigIntentProtocol, VehicleModelConfigModelStateProtocol>
        private var intent: VehicleModelConfigIntentProtocol { container.intent }
        private var state: VehicleModelConfigModelStateProtocol { container.model }
        @State var adases: [SaleModelConfig] = []
        
        var body: some View {
            VStack {
                ForEach(Array(adases.enumerated()), id:\.offset) { index, adas in
                    Button(action: {
                        intent.onTapAdas(code: adas.typeCode, price: adas.typePrice)
                    }) {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(state.selectAdas == adas.typeCode ? Color.orange : Color.gray, lineWidth: 1)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                            .frame(height: 220)
                            .background(Color(hex: 0xfbfbfb))
                            .overlay(
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(adas.typeName)
                                            .bold()
                                        Spacer()
                                    }
                                    HStack {
                                        VStack {
                                            if adas.typePrice == 0 {
                                                Text(LocalizedStringKey("price_included"))
                                            } else {
                                                Text("￥\(adas.typePrice.formatted())")
                                            }
                                            Spacer()
                                        }
                                        Spacer()
                                        KFImage(URL(string: adas.typeImage[0])!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    }
                                    Text(adas.typeDesc)
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
                if adases.isEmpty {
                    adases = state.adases
                }
                if !adases.isEmpty {
                    if state.selectAdas == "" {
                        if let firstAdas = adases.first {
                            intent.onTapAdas(code: firstAdas.typeCode, price: firstAdas.typePrice)
                        }
                    }
                }
            }
        }
    }
}

struct VehicleModelConfigPage_Adas_Previews: PreviewProvider {
    static var previews: some View {
        VehicleModelConfigPage.Adas(container: VehicleModelConfigPage.buildContainer(), adases: [
            SaleModelConfig.init(saleCode: "H01", type: "ADAS", typeCode: "X02", typeName: "高价智驾", typePrice: 20000, typeImage: ["https://pic.imgdb.cn/item/67065c4fd29ded1a8c9a3714.png"], typeDesc: "", typeParam: ""),
            SaleModelConfig.init(saleCode: "H01", type: "ADAS", typeCode: "X00", typeName: "标准智驾", typePrice: 0, typeImage: ["https://pic.imgdb.cn/item/670674cfd29ded1a8cac9cb3.png"], typeDesc: "", typeParam: "")
        ])
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
