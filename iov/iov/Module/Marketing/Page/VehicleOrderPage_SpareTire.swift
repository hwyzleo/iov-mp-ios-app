//
//  VehicleOrderPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

import SwiftUI
import Kingfisher

/// 车辆订购页 - 备胎
extension VehicleOrderPage {
    struct SpareTire: View {
        @StateObject var container: MviContainer<VehicleOrderIntentProtocol, VehicleOrderModelStateProtocol>
        private var intent: VehicleOrderIntentProtocol { container.intent }
        private var state: VehicleOrderModelStateProtocol { container.model }
        @State var spareTires: [SaleModel] = []
        
        var body: some View {
            VStack {
                ForEach(Array(spareTires.enumerated()), id:\.offset) { index, spareTire in
                    Button(action: {
                        intent.onTapSpareTire(code: spareTire.saleModelTypeCode, price: spareTire.salePrice)
                    }) {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(state.selectSpareTire == spareTire.saleModelTypeCode ? Color.orange : Color.gray, lineWidth: 1)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                            .frame(height: 220)
                            .background(Color(hex: 0xfbfbfb))
                            .overlay(
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(spareTire.saleName)
                                            .bold()
                                        Spacer()
                                    }
                                    HStack {
                                        VStack {
                                            if spareTire.salePrice == 0 {
                                                Text("价格已包含")
                                            } else {
                                                Text("￥\(String(describing: spareTire.salePrice))")
                                            }
                                            Spacer()
                                        }
                                        Spacer()
                                        KFImage(URL(string: spareTire.saleImage[0])!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    }
                                    Text(spareTire.saleDesc)
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
                            intent.onTapSpareTire(code: firstSpareTire.saleModelTypeCode, price: firstSpareTire.salePrice)
                        }
                    }
                }
            }
        }
    }
}

struct VehicleOrderPage_SpareTire_Previews: PreviewProvider {
    static var previews: some View {
        VehicleOrderPage.SpareTire(container: VehicleOrderPage.buildContainer(), spareTires: [
            SaleModel.init(saleCode: "H01", saleModelType: "SPIRE_TIRE", saleModelTypeCode: "X05", saleName: "外挂式全尺寸备胎", salePrice: 6000, saleImage: ["https://pic.imgdb.cn/item/67065c4fd29ded1a8c9a3714.png"], saleDesc: "含备胎车长5295毫米", saleParam: ""),
            SaleModel.init(saleCode: "H01", saleModelType: "SPIRE_TIRE", saleModelTypeCode: "X00", saleName: "无备胎", salePrice: 0, saleImage: ["https://pic.imgdb.cn/item/670674cfd29ded1a8cac9cb3.png"], saleDesc: "车长5050毫米", saleParam: "")
        ])
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
