//
//  MyView_TopBar.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension MyPage {
    struct TopBar: View {
        var tapLoginAction: (() -> Void)?
        var tapMessageAction: (() -> Void)?
        var tapSettingAction: (() -> Void)?
        
        var body: some View {
            HStack(spacing: 24) {
                Spacer()
                
                // 扫码
                Button(action: { /* 扫码逻辑 */ }) {
                    Image("icon_scan_qrcode")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(AppTheme.colors.fontPrimary)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                
                // 二维码
                Button(action: { /* 二维码逻辑 */ }) {
                    Image("qrCode")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(AppTheme.colors.fontPrimary)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                
                // 设置
                Button(action: {
                    tapSettingAction?()
                }) {
                    Image("icon_setting")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(AppTheme.colors.fontPrimary)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 10)
        }
    }
}

#Preview {
    MyPage.TopBar()
}
