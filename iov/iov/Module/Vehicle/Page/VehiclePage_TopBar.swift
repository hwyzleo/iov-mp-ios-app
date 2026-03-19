//
//  VehicleView_TopBar.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct VehiclePage_TopBar: View {
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
                // 扫码
                NavigationLink(
                    destination: CustomScannerView() { qrcode in
                        debugPrint("QRCode: \(qrcode)")
                    }
                    .ignoresSafeArea()
                    .navigationBarBackButtonHidden()
                ) {
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
