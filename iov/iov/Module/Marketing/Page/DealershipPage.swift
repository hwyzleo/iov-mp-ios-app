//
//  VehicleWishlistPage.swift
//  iov
//
//  Created by hwyz_leo on 2024/10/13.
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
                VStack(spacing: 0) {
                    TopBackTitleBar(titleLocal: LocalizedStringKey("dealership"))
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(Array(state.dealershipList.enumerated()), id:\.offset) { index, dealership in
                                Button(action: {
                                    intent.onTapDealership(code: dealership.code, name: dealership.name)
                                }) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(dealership.name)
                                            .font(AppTheme.fonts.body)
                                            .bold()
                                            .foregroundColor(AppTheme.colors.fontPrimary)
                                        Text(dealership.address)
                                            .font(AppTheme.fonts.subtext)
                                            .foregroundColor(AppTheme.colors.fontSecondary)
                                            .multilineTextAlignment(.leading)
                                    }
                                    .padding(.vertical, 20)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                
                                if index < state.dealershipList.count - 1 {
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

struct DealershipPage_Previews: PreviewProvider {
    static var previews: some View {
        DealershipPage(
            container: DealershipPage.buildContainer()
        )
        .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
