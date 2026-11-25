//
//  VehicleView_TopBar.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

struct VehiclePage_TopBar: View {
    var onTapScan: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 20) {
            HStack(spacing: 4) {
                Text("开源汽车")
                    .font(AppTheme.fonts.title1)
                    .foregroundColor(AppTheme.colors.fontPrimary)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.colors.brandMain)
            }
            
            Spacer()
            
            HStack(spacing: 24) {
                // 扫码（绑车激活入口，不代表已绑定；需登录，未登录先登录并在登录后续跑已扫到的二维码）
                Button {
                    onTapScan?()
                } label: {
                    Image("icon_scan_qrcode")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(AppTheme.colors.fontPrimary)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                
                // 设置
                NavigationLink(destination: VehicleSettingPage().navigationBarBackButtonHidden()) {
                    Image("icon_setting")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(AppTheme.colors.fontPrimary)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: 44)
    }
}

#Preview {
    ZStack {
        AppTheme.colors.background.ignoresSafeArea()
        VehiclePage_TopBar()
            .padding()
    }
}
