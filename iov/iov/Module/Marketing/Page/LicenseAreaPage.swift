//
//  VehicleWishlistPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/13.
//

import SwiftUI
import Kingfisher

/// 上牌区域页
struct LicenseAreaPage: View {
    @StateObject var container: MviContainer<LicenseAreaIntentProtocol, LicenseAreaModelStateProtocol>
    private var intent: LicenseAreaIntentProtocol { container.intent }
    private var state: LicenseAreaModelStateProtocol { container.model }

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
                    TopBackTitleBar(titleLocal: LocalizedStringKey("license_area"))
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(Array(state.displayLicenseAreaList.enumerated()), id:\.offset) { index, area in
                                Button(action: {
                                    intent.onTapLicenseArea(
                                        provinceCode: area.provinceCode,
                                        cityCode: area.cityCode ?? "",
                                        displayName: area.displayName
                                    )
                                }) {
                                    HStack {
                                        Text(area.displayName)
                                            .font(AppTheme.fonts.body)
                                            .foregroundColor(AppTheme.colors.fontPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12))
                                            .foregroundColor(AppTheme.colors.fontTertiary)
                                    }
                                    .padding(.vertical, 20)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                
                                if index < state.displayLicenseAreaList.count - 1 {
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

struct LicenseAreaPage_Previews: PreviewProvider {
    static var previews: some View {
        LicenseAreaPage(
            container: LicenseAreaPage.buildContainer()
        )
        .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
