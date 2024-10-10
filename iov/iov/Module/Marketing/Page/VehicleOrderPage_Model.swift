//
//  VehicleOrderPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

import SwiftUI
import Kingfisher

/// 车辆订购页 - 车型
extension VehicleOrderPage {
    struct Model: View {
        @StateObject var container: MviContainer<VehicleOrderIntentProtocol, VehicleOrderModelStateProtocol>
        private var intent: VehicleOrderIntentProtocol { container.intent }
        private var state: VehicleOrderModelStateProtocol { container.model }
        @State var models: [SaleModel] = []
        
        var body: some View {
            VStack {
                ForEach(Array(models.enumerated()), id:\.offset) { index, model in
                    Button(action: {
                        intent.onTapModel(code: model.saleModelTypeCode, price: model.salePrice)
                    }) {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(state.selectModel == model.saleModelTypeCode ? Color.orange : Color.gray, lineWidth: 1)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                            .frame(height: 220)
                            .background(Color(hex: 0xfbfbfb))
                            .overlay(
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(model.saleName)
                                            .bold()
                                        Spacer()
                                    }
                                    HStack {
                                        VStack {
                                            Text("￥\(String(describing: model.salePrice))")
                                            Spacer()
                                        }
                                        Spacer()
                                        KFImage(URL(string: model.saleImage[0])!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    }
                                    Text(model.saleDesc)
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
                            intent.onTapModel(code: firstModel.saleModelTypeCode, price: firstModel.salePrice)
                        }
                    }
                }
            }
        }
    }
}

struct VehicleOrderPage_Model_Previews: PreviewProvider {
    static var previews: some View {
        VehicleOrderPage.Model(container: VehicleOrderPage.buildContainer(), models: [
            SaleModel.init(saleCode: "H01", saleModelType: "MODEL", saleModelTypeCode: "H0106", saleName: "寒01 6座版", salePrice: 88888, saleImage: ["https://pic.imgdb.cn/item/67065c4fd29ded1a8c9a3714.png"], saleDesc: "2-2-2六座，双侧零重力航空座椅，行政奢华", saleParam: ""),
            SaleModel.init(saleCode: "H01", saleModelType: "MODEL", saleModelTypeCode: "H0107", saleName: "寒01 7座版", salePrice: 88888, saleImage: ["https://pic.imgdb.cn/item/67065c4fd29ded1a8c9a3714.png"], saleDesc: "2-2-3七座，二排超宽通道，二三排可放平", saleParam: "")
        ])
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
