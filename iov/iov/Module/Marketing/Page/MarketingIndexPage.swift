//
//  VehicleIndexPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

import SwiftUI

/// 购车首页
struct MarketingIndexPage: View {
    @StateObject var container: MviContainer<MarketingIndexIntentProtocol, MarketingIndexModelStateProtocol>
    private var intent: MarketingIndexIntentProtocol { container.intent }
    private var state: MarketingIndexModelStateProtocol { container.model }
    
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

extension MarketingIndexPage {
    struct Content: View {
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
                            intent.onTapOrder()
                        }
                        .frame(width: 300)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .edgesIgnoringSafeArea(.top)
        }
    }
}

struct MarketingIndexPage_Previews: PreviewProvider {
    static var previews: some View {
        MarketingIndexPage.build()
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
