//
//  VehicleOrderPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

import SwiftUI
import Kingfisher

/// 车辆订购页 - 内饰
extension VehicleOrderPage {
    struct Interior: View {
        @StateObject var container: MviContainer<VehicleOrderIntentProtocol, VehicleOrderModelStateProtocol>
        private var intent: VehicleOrderIntentProtocol { container.intent }
        private var state: VehicleOrderModelStateProtocol { container.model }
        @State var interiors: [SaleModel] = []
        @State private var selectedTab = 0
        
        var body: some View {
            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    ForEach(Array(interiors.enumerated()), id:\.offset) { index, interior in
                        KFImage(URL(string: interior.saleImage)!)
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
                            Text(interior.saleName)
                                .foregroundStyle(AppTheme.colors.fontPrimary)
                                .font(.system(size: 22))
                            Text("￥\(String(describing: interior.salePrice))")
                                .foregroundStyle(AppTheme.colors.fontSecondary)
                                .font(.system(size: 15))
                        }
                    }
                }
                HStack {
                    ForEach(Array(interiors.enumerated()), id:\.offset) { index, interior in
                        Button(action: {
                            selectedTab = index
                            intent.onTapExterior(code: interior.saleCode, price: interior.salePrice)
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
                        .foregroundColor(Color(hexStr: interior.saleParam))
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
                            intent.onTapInterior(code: firstInterior.saleCode, price: firstInterior.salePrice)
                        }
                    }
                }
            }
        }
    }
}

struct VehicleOrderPage_Interior_Previews: PreviewProvider {
    static var previews: some View {
        VehicleOrderPage.Interior(container: VehicleOrderPage.buildContainer(), interiors: [
            SaleModel.init(saleCode: "H01", saleModelType: "INTERIOR", saleModelTypeCode: "NS03", saleName: "霜雪白内饰", salePrice: 0, saleImage: "https://pic.imgdb.cn/item/670685e4d29ded1a8cb9c55f.png", saleDesc: "", saleParam: "#dcdcd6"),
            SaleModel.init(saleCode: "H01", saleModelType: "INTERIOR", saleModelTypeCode: "NS02", saleName: "珊瑚橙内饰", salePrice: 0, saleImage: "https://pic.imgdb.cn/item/670687ecd29ded1a8cbb5280.png", saleDesc: "", saleParam: "#a35d31"),
            SaleModel.init(saleCode: "H01", saleModelType: "INTERIOR", saleModelTypeCode: "NS01", saleName: "乌木黑内饰", salePrice: 0, saleImage: "https://pic.imgdb.cn/item/670688dbd29ded1a8cbc1321.png", saleDesc: "", saleParam: "#424141")
        ])
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
