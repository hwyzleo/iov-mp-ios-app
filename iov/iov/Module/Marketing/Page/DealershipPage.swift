//
//  VehicleWishlistPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/13.
//

import SwiftUI
import Kingfisher

/// 销售门店页
struct DealershipPage: View {
    @StateObject var container: MviContainer<DealershipIntentProtocol, DealershipModelStateProtocol>
    private var intent: DealershipIntentProtocol { container.intent }
    private var state: DealershipModelStateProtocol { container.model }

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
                        ForEach(Array(state.dealershipList.enumerated()), id:\.offset) { index, dealership in
                            VStack {
                                Spacer().frame(height: 20)
                                HStack {
                                    Text(dealership.name)
                                        .bold()
                                    Spacer()
                                }
                                HStack {
                                    Text(dealership.address)
                                    Spacer()
                                }
                                Spacer().frame(height: 20)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                intent.onTapDealership(code: dealership.code, name: dealership.name)
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

struct DealershipPage_Previews: PreviewProvider {
    static var previews: some View {
        DealershipPage(
            container: DealershipPage.buildContainer()
        )
        .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
