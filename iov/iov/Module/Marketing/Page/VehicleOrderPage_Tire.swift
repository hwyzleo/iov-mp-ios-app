//
//  VehicleOrderPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

import SwiftUI

/// 车辆订购页 - 轮胎
extension VehicleOrderPage {
    struct Tire: View {
        @StateObject var container: MviContainer<VehicleOrderIntentProtocol, VehicleOrderModelStateProtocol>
        private var intent: VehicleOrderIntentProtocol { container.intent }
        private var state: VehicleOrderModelStateProtocol { container.model }
        @State private var selectedTab = 0
        
        var body: some View {
            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    Image("vehicle_tire_1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 250)
                        .tag(0)
                    Image("vehicle_tire_2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 250)
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
                            Text("渐变五花轮毂")
                        }
                    }
                    .foregroundColor(selectedTab == 0 ? AppTheme.colors.fontPrimary : AppTheme.colors.fontSecondary)
                    .frame(maxWidth: .infinity)
                    Button(action: {
                        withAnimation {
                            selectedTab = 1
                        }
                    }) {
                        VStack {
                            Text("深黑八爪轮毂")
                        }
                    }
                    .foregroundColor(selectedTab == 1 ? AppTheme.colors.fontPrimary : AppTheme.colors.fontSecondary)
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                Spacer()
            }
        }
    }
}

struct VehicleTireTab {
    let icon: String
    let color: Color
    let content: AnyView
}

struct VehicleOrderPage_Tire_Previews: PreviewProvider {
    static var previews: some View {
        VehicleOrderPage.Tire(container: VehicleOrderPage.buildContainer())
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
