//
//  VehicleOrderPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

import SwiftUI

/// 车辆车型配置页
struct VehicleModelConfigPage: View {
    @StateObject var container: MviContainer<VehicleModelConfigIntentProtocol, VehicleModelConfigModelStateProtocol>
    private var intent: VehicleModelConfigIntentProtocol { container.intent }
    private var state: VehicleModelConfigModelStateProtocol { container.model }

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
                Content(container: container)
                ErrorTip(text: text)
            }
        }
        .onAppear {
            intent.viewOnAppear()
        }
        .modifier(MarketingRouter(subjects: state.routerSubject))
    }
}

extension VehicleModelConfigPage {
    struct Content: View {
        @StateObject var container: MviContainer<VehicleModelConfigIntentProtocol, VehicleModelConfigModelStateProtocol>
        private var intent: VehicleModelConfigIntentProtocol { container.intent }
        private var state: VehicleModelConfigModelStateProtocol { container.model }
        private let tabNames: [String] = ["vehicle_model", "spare_tire", "exterior", "wheel", "interior", "adas"]
        @State private var selectedTab = 0
        
        var body: some View {
            VStack {
                TopBackTitleBar(titleLocal: LocalizedStringKey("choose_vehicle"))
                Spacer().frame(height: 20)
                TabView(selection: $selectedTab) {
                    VehicleModelConfigPage.Model(container: container)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .tag(0)
                    VehicleModelConfigPage.SpareTire(container: container)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .tag(1)
                    VehicleModelConfigPage.Exterior(container: container)
                        .tag(2)
                    VehicleModelConfigPage.Wheel(container: container)
                        .tag(3)
                    VehicleModelConfigPage.Interior(container: container)
                        .tag(4)
                    VehicleModelConfigPage.Adas(container: container)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .tag(5)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                HStack {
                    ForEach(Array(tabNames.enumerated()), id: \.offset) { index, tabName in
                        Button(action: {
                            withAnimation {
                                selectedTab = index
                            }
                        }) {
                            VStack {
                                Text(LocalizedStringKey(tabName))
                            }
                        }
                        .foregroundColor(selectedTab == index ? AppTheme.colors.fontPrimary : AppTheme.colors.fontSecondary)
                        .frame(maxWidth: .infinity)
                    }
                }
                Spacer().frame(height: 40)
                HStack {
                    Text("￥\(state.totalPrice.formatted())")
                    Spacer().frame(width: 20)
                    RoundedCornerButton(
                        nameLocal: LocalizedStringKey("save_wishlist")
                    ) {
                        intent.onTapSaveWishlist(saleCode: state.saleCode, modelCode: state.selectModel, modelName: state.selectModelName, spareTireCode: state.selectSpareTire, exteriorCode: state.selectExterior, wheelCode: state.selectWheel, interiorCode: state.selectInterior, adasCode: state.selectAdas)
                    }
                    Spacer().frame(width: 20)
                    RoundedCornerButton(
                        nameLocal: LocalizedStringKey("order_now"),
                        color: Color.white,
                        bgColor: Color.black
                    ) {
                        intent.onTapOrder(saleCode: state.saleCode, modelCode: state.selectModel, modelName: state.selectModelName, spareTireCode: state.selectSpareTire, exteriorCode: state.selectExterior, wheelCode: state.selectWheel, interiorCode: state.selectInterior, adasCode: state.selectAdas)
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                Spacer()
            }
        }
    }
}

struct VehicleModelConfigPage_Previews: PreviewProvider {
    static var previews: some View {
        VehicleModelConfigPage.build()
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
