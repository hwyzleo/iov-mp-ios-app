//
//  VehicleView_TopBar.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct VehicleView_TopBar: View {
    var body: some View {
        HStack {
            Text("开源汽车")
                .font(.system(size: 18))
                .bold()
            Image(systemName: "chevron.up.chevron.down")
            Spacer()
            NavigationLink(
                destination: CustomScannerView() { qrcode in
                    debugPrint("QRCode: \(qrcode)")
                }
                .ignoresSafeArea()
                .navigationBarBackButtonHidden()
            ) {
                Image(systemName: "qrcode.viewfinder")
            }
            .buttonStyle(.plain)
            Spacer()
                .frame(width: 20)
            NavigationLink(destination: VehicleSettingView().navigationBarBackButtonHidden()) {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    VehicleView_TopBar()
}
