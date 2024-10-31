//
//  VehicleWishlistPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/13.
//

import SwiftUI
import Kingfisher

/// 交付门店页
struct DeliveryCenterPage: View {
    @StateObject var container: MviContainer<DeliveryCenterIntentProtocol, DeliveryCenterModelStateProtocol>
    private var intent: DeliveryCenterIntentProtocol { container.intent }
    private var state: DeliveryCenterModelStateProtocol { container.model }

    var body: some View {
        ZStack {
            switch state.contentState {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(2)
            case let .error(text):
                ErrorTip(text: text)
            case .content:
                VStack {
                    TopBackTitleBar(titleLocal: LocalizedStringKey("dealership"))
                    ScrollView {
                        ForEach(Array(state.deliveryCenterList.enumerated()), id:\.offset) { index, deliveryCenter in
                            VStack {
                                Spacer().frame(height: 20)
                                HStack {
                                    Text(deliveryCenter.name)
                                        .bold()
                                    Spacer()
                                }
                                HStack {
                                    Text(deliveryCenter.address)
                                    Spacer()
                                }
                                Spacer().frame(height: 20)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                intent.onTapDeliveryCenter(code: deliveryCenter.code, name: deliveryCenter.name)
                            }
                            Divider()
                        }
                    }
                    .scrollIndicators(.hidden)
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
            }
        }
        .onAppear {
            intent.viewOnAppear()
        }
        .modifier(MarketingRouter(subjects: state.routerSubject))
    }
}

struct DeliveryCenterPage_Previews: PreviewProvider {
    static var previews: some View {
        DeliveryCenterPage(
            container: DeliveryCenterPage.buildContainer()
        )
        .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
