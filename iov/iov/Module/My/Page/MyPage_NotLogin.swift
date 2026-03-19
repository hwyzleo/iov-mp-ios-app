//
//  MyView_NotLoginContent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import SwiftyJSON
import MBProgressHUD

extension MyPage {
    struct NotLogin: View {
        var tapScanAction: (() -> Void)?
        var tapLoginAction: (() -> Void)?
        var tapMessageAction: (() -> Void)?
        var tapSettingAction: (() -> Void)?
        
        var body: some View {
            VStack(spacing: 0) {
                Spacer().frame(height: kStatusBarHeight)
                MyPage.TopBar(
                    tapScanAction: { tapScanAction?() },
                    tapLoginAction: { tapLoginAction?() },
                    tapMessageAction: { tapMessageAction?() },
                    tapSettingAction: { tapSettingAction?() }
                )
                .padding(.horizontal, AppTheme.layout.margin)
                
                ScrollView {
                    VStack(spacing: AppTheme.layout.spacing) {
                        VStack(alignment: .leading, spacing: 24) {
                            HStack {
                                Text(LocalizedStringKey("not_login_welcome"))
                                    .font(AppTheme.fonts.title1)
                                    .foregroundColor(AppTheme.colors.fontPrimary)
                                    .lineLimit(2)
                                    .frame(height: 80)
                                Spacer()
                                Image("my_place_holder")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            }
                            
                            RoundedCornerButton(
                                nameLocal: LocalizedStringKey("login_register"),
                                color: .black,
                                bgColor: AppTheme.colors.brandMain
                            ) {
                                tapLoginAction?()
                            }
                        }
                        .appCardStyle()
                    }
                    .padding(.horizontal, AppTheme.layout.margin)
                    .padding(.top, 20)
                }
                .scrollIndicators(.hidden)
            }
            .appBackground()
        }
    }
}

struct MyView_NotLogin_Previews: PreviewProvider {
    static var previews: some View {
        MyPage.NotLogin()
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
