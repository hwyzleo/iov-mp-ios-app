//
//  VehicleOrderPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

import SwiftUI

/// 车辆订购页 - 内饰
extension VehicleOrderPage {
    struct Interior: View {
        @StateObject var container: MviContainer<VehicleOrderIntentProtocol, VehicleOrderModelStateProtocol>
        private var intent: VehicleOrderIntentProtocol { container.intent }
        private var state: VehicleOrderModelStateProtocol { container.model }
        @State private var selectedTab = 0
        
        var body: some View {
            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    Image("vehicle_interior_1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 300)
                        .tag(0)
                    Image("vehicle_interior_2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 300)
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                Spacer().frame(height: 50)
                HStack {
                    Button(action: {
                        withAnimation {
                            selectedTab = 0
                        }
                    }) {
                        VStack {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                    }
                    .foregroundColor(Color(hex: 0xb05163))
                    .frame(maxWidth: .infinity)
                    Button(action: {
                        withAnimation {
                            selectedTab = 1
                        }
                    }) {
                        VStack {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                    }
                    .foregroundColor(Color(hex: 0x6d6d71))
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                Spacer()
            }
        }
    }
}

struct VehicleOrderPage_Interior_Previews: PreviewProvider {
    static var previews: some View {
        VehicleOrderPage.Interior(container: VehicleOrderPage.buildContainer())
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
