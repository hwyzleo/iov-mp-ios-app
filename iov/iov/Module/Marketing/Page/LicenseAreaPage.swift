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
                VStack {
                    TopBackTitleBar(titleLocal: LocalizedStringKey("license_area"))
                    ScrollView {
                        ForEach(Array(state.displayLicenseAreaList.enumerated()), id:\.offset) { index, area in
                            VStack {
                                Spacer().frame(height: 20)
                                HStack {
                                    Text(area.displayName)
                                    Spacer()
                                }
                                Spacer().frame(height: 20)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                intent.onTapLicenseArea(
                                    provinceCode: area.provinceCode,
                                    cityCode: area.cityCode ?? "",
                                    displayName: area.displayName
                                )
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

struct LicenseAreaPage_Previews: PreviewProvider {
    static var previews: some View {
        LicenseAreaPage(
            container: LicenseAreaPage.buildContainer()
        )
        .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
