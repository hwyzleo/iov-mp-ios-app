//
//  VehicleOrderDetailPage_Invalid.swift
//  iov
//
//  IOS-APP-DSN-CR-004
//  终态订单详情（已失效 / 已取消 / 已关闭）：只读展示，不展示支付按钮；
//  失效订单可重新发起支付（云端 OTD-VSO-DSN-CR-005 reopen）。
//

import SwiftUI

extension VehicleOrderDetailPage {
    struct Invalid: View {
        @EnvironmentObject var globalState: AppGlobalState
        @StateObject var container: MviContainer<VehicleOrderDetailIntentProtocol, VehicleOrderDetailModelStateProtocol>
        private var intent: VehicleOrderDetailIntentProtocol { container.intent }
        private var state: VehicleOrderDetailModelStateProtocol { container.model }
        var saleModelImages: [String]
        var saleModelName: String
        var saleModelDesc: String
        var totalPrice: Decimal

        var body: some View {
            ZStack(alignment: .top) {
                AppTheme.colors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    TopBackTitleBar(titleLocal: L10n.order_detail, color: .white)
                        .frame(height: 54)

                    ScrollView {
                        VStack(spacing: AppTheme.layout.spacing) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(state.invalidTitle)
                                    .font(AppTheme.fonts.title1)
                                    .bold()
                                    .foregroundColor(AppTheme.colors.fontPrimary)
                                Text(state.canReopenPayment
                                     ? LocalizedStringKey("order_expired_desc")
                                     : LocalizedStringKey("order_terminal_desc"))
                                    .font(AppTheme.fonts.body)
                                    .foregroundColor(AppTheme.colors.fontSecondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .appCardStyle()

                            VStack(alignment: .leading, spacing: 12) {
                                Text(saleModelName)
                                    .font(AppTheme.fonts.title1)
                                    .foregroundColor(AppTheme.colors.fontPrimary)
                                Text(saleModelDesc)
                                    .font(AppTheme.fonts.body)
                                    .foregroundColor(AppTheme.colors.fontSecondary)
                                HStack {
                                    Text(LocalizedStringKey("total_price"))
                                        .font(AppTheme.fonts.body)
                                        .foregroundColor(AppTheme.colors.fontSecondary)
                                    Spacer()
                                    Text("¥\(NSDecimalNumber(decimal: totalPrice).stringValue)")
                                        .font(AppTheme.fonts.title1)
                                        .foregroundColor(AppTheme.colors.brandMain)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .appCardStyle()

                            if state.canReopenPayment {
                                RoundedCornerButton(nameLocal: LocalizedStringKey("reopen_payment"),
                                                   color: .black,
                                                   bgColor: AppTheme.colors.brandMain) {
                                    intent.onTapReopenPayment()
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.layout.margin)
                        .padding(.top, AppTheme.layout.spacing)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
