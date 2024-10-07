//
//  VehicleOrderPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

import SwiftUI

/// 车辆订购页 - 外饰
extension VehicleOrderPage {
    struct Exterior: View {
        @StateObject var container: MviContainer<VehicleOrderIntentProtocol, VehicleOrderModelStateProtocol>
        private var intent: VehicleOrderIntentProtocol { container.intent }
        private var state: VehicleOrderModelStateProtocol { container.model }
        @State private var selectedTab = 0
        
        var body: some View {
            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    Image("vehicle_exterior_1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 300)
                        .tag(0)
                    Image("vehicle_exterior_2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 300)
                        .tag(1)
                    Image("vehicle_exterior_3")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 300)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
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
                    .foregroundColor(Color(hex: 0x39485d))
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
                    .foregroundColor(Color(hex: 0x5a5e53))
                    .frame(maxWidth: .infinity)
                    Button(action: {
                        withAnimation {
                            selectedTab = 2
                        }
                    }) {
                        VStack {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                    }
                    .foregroundColor(Color(hex: 0x494947))
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                Spacer().frame(height: 100)
            }
        }
    }
}

struct VehicleOrderPage_Exterior_Previews: PreviewProvider {
    static var previews: some View {
        VehicleOrderPage.Exterior(container: VehicleOrderPage.buildContainer())
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
