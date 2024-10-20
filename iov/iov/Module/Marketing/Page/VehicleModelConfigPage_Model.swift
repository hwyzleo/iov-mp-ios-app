//
//  VehicleOrderPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
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
        
        var body: some View {
            VStack {
                ForEach(Array(models.enumerated()), id:\.offset) { index, model in
                    Button(action: {
                        intent.onTapModel(code: model.typeCode, name: model.typeName, price: model.typePrice)
                    }) {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(state.selectModel == model.typeCode ? Color.orange : Color.gray, lineWidth: 1)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                            .frame(height: 220)
                            .background(Color(hex: 0xfbfbfb))
                            .overlay(
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(model.typeName)
                                            .bold()
                                        Spacer()
                                    }
                                    HStack {
                                        VStack {
                                            Text("￥\(model.typePrice.formatted())")
                                            Spacer()
                                        }
                                        Spacer()
                                        KFImage(URL(string: model.typeImage[0])!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    }
                                    Text(model.typeDesc)
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
                if models.isEmpty {
                    models = state.models
                }
                if !models.isEmpty {
                    if state.selectModel == "" {
                        if let firstModel = models.first {
                            intent.onTapModel(code: firstModel.typeCode, name: firstModel.typeName, price: firstModel.typePrice)
                        }
                    }
                }
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
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
