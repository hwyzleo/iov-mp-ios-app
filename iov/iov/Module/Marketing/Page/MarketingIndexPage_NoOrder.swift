//
//  VehicleIndexPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

import SwiftUI

/// 购车首页 - 无订单订购页
extension MarketingIndexPage {
    struct NoOrder: View {
        @StateObject var container: MviContainer<MarketingIndexIntentProtocol, MarketingIndexModelStateProtocol>
        private var intent: MarketingIndexIntentProtocol { container.intent }
        private var state: MarketingIndexModelStateProtocol { container.model }
        
        var body: some View {
            ScrollView {
                ZStack(alignment: .top) {
                    Image("vehicle_banner")
                        .resizable()
                        .scaledToFill()
                    VStack {
                        Spacer().frame(height: 650)
                        RoundedCornerButton(nameLocal: LocalizedStringKey("order_now")) {
                            intent.onTapModelConfig()
                        }
                        .frame(width: 300)
                    }
                }
            }
            .edgesIgnoringSafeArea(.top)
            .scrollIndicators(.hidden)
        }
    }
}

struct MarketingIndexPage_NoOrder_Previews: PreviewProvider {
    static var previews: some View {
        MarketingIndexPage.NoOrder(container: MarketingIndexPage.buildContainer())
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
