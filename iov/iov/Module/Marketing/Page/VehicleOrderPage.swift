//
//  VehicleOrderPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

import SwiftUI

/// 车辆订购页
struct VehicleOrderPage: View {
    @StateObject var container: MviContainer<VehicleOrderIntentProtocol, VehicleOrderModelStateProtocol>
    private var intent: VehicleOrderIntentProtocol { container.intent }
    private var state: VehicleOrderModelStateProtocol { container.model }

    var body: some View {
        ZStack {
            switch state.contentState {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(2)
            case .content:
                Content(container: container)
            case let .error(text):
                ErrorTip(text: text)
            }
        }
        .onAppear {
            intent.viewOnAppear()
        }
        .modifier(MarketingRouter(subjects: state.routerSubject))
    }
}

extension VehicleOrderPage {
    struct Content: View {
        @StateObject var container: MviContainer<VehicleOrderIntentProtocol, VehicleOrderModelStateProtocol>
        private var intent: VehicleOrderIntentProtocol { container.intent }
        private var state: VehicleOrderModelStateProtocol { container.model }
        @State private var selectedTab = 0
        
        var body: some View {
            VStack {
                TopBackTitleBar(titleLocal: LocalizedStringKey("choose_vehicle"))
                Spacer().frame(height: 20)
                TabView(selection: $selectedTab) {
                    VehicleOrderPage.Model(container: container)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .tag(0)
                    VehicleOrderPage.SpareTire(container: container)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .tag(1)
                    VehicleOrderPage.Exterior(container: container)
                        .tag(2)
                    VehicleOrderPage.Wheel(container: container)
                        .tag(3)
                    VehicleOrderPage.Interior(container: container)
                        .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                HStack {
                    Button(action: {
                        withAnimation {
                            selectedTab = 0
                        }
                    }) {
                        VStack {
                            Text("车型")
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
                            Text("备胎")
                        }
                    }
                    .foregroundColor(selectedTab == 1 ? AppTheme.colors.fontPrimary : AppTheme.colors.fontSecondary)
                    .frame(maxWidth: .infinity)
                    Button(action: {
                        withAnimation {
                            selectedTab = 2
                        }
                    }) {
                        VStack {
                            Text("外观")
                        }
                    }
                    .foregroundColor(selectedTab == 2 ? AppTheme.colors.fontPrimary : AppTheme.colors.fontSecondary)
                    .frame(maxWidth: .infinity)
                    Button(action: {
                        withAnimation {
                            selectedTab = 3
                        }
                    }) {
                        VStack {
                            Text("车轮")
                        }
                    }
                    .foregroundColor(selectedTab == 3 ? AppTheme.colors.fontPrimary : AppTheme.colors.fontSecondary)
                    .frame(maxWidth: .infinity)
                    Button(action: {
                        withAnimation {
                            selectedTab = 4
                        }
                    }) {
                        VStack {
                            Text("内饰")
                        }
                    }
                    .foregroundColor(selectedTab == 4 ? AppTheme.colors.fontPrimary : AppTheme.colors.fontSecondary)
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                Spacer().frame(height: 40)
                HStack {
                    Text("￥\(String(describing: state.totalPrice))")
                    Spacer().frame(width: 20)
                    RoundedCornerButton(
                        nameLocal: LocalizedStringKey("order_now"),
                        color: Color.white,
                        bgColor: Color.black
                    ) {
                        intent.onTapOrder()
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                Spacer()
            }
        }
    }
}

struct VehicleOrderPage_Previews: PreviewProvider {
    static var previews: some View {
        VehicleOrderPage.build()
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
