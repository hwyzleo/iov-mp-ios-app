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
                VStack(spacing: 0) {
                    TopBackTitleBar(titleLocal: LocalizedStringKey("dealership"))
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(Array(state.deliveryCenterList.enumerated()), id:\.offset) { index, deliveryCenter in
                                Button(action: {
                                    intent.onTapDeliveryCenter(code: deliveryCenter.code, name: deliveryCenter.name)
                                }) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(deliveryCenter.name)
                                            .font(AppTheme.fonts.body)
                                            .bold()
                                            .foregroundColor(AppTheme.colors.fontPrimary)
                                        Text(deliveryCenter.address)
                                            .font(AppTheme.fonts.subtext)
                                            .foregroundColor(AppTheme.colors.fontSecondary)
                                            .multilineTextAlignment(.leading)
                                    }
                                    .padding(.vertical, 20)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                
                                if index < state.deliveryCenterList.count - 1 {
                                    Divider().background(Color.white.opacity(0.05))
                                }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
                .padding(.horizontal, AppTheme.layout.margin)
            }
        }
        .background(AppTheme.colors.background.ignoresSafeArea())
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
