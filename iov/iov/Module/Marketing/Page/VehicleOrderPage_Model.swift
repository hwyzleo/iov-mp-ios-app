//
//  VehicleOrderPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

import SwiftUI

/// 车辆订购页 - 车型
extension VehicleOrderPage {
    struct Model: View {
        @StateObject var container: MviContainer<VehicleOrderIntentProtocol, VehicleOrderModelStateProtocol>
        private var intent: VehicleOrderIntentProtocol { container.intent }
        private var state: VehicleOrderModelStateProtocol { container.model }
        
        var body: some View {
            VStack {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.orange, lineWidth: 1)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .frame(height: 200)
                    .background(Color(hex: 0xfbfbfb))
                    .overlay(
                        VStack(alignment: .leading) {
                            HStack {
                                Text(LocalizedStringKey("vehicle_standard"))
                                    .bold()
                                Spacer()
                            }
                            HStack {
                                VStack {
                                    Text("￥8888")
                                    Spacer()
                                }
                                Spacer()
                                Image("vehicle_model_1")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 220)
                            }
                            Spacer()
                        }
                        .padding(10)
                    )
                Spacer().frame(height: 40)
                Spacer()
            }
        }
    }
}

struct VehicleOrderPage_Model_Previews: PreviewProvider {
    static var previews: some View {
        VehicleOrderPage.Model(container: VehicleOrderPage.buildContainer())
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
