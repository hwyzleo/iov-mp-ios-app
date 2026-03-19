//
//  MyView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct MyPage: View {
    
    @StateObject var container: MviContainer<MyIntentProtocol, MyModelStateProtocol>
    private var intent: MyIntentProtocol { container.intent }
    private var state: MyModelStateProtocol { container.model }
    
    var body: some View {
        ZStack {
            switch state.contentState {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(2)
            case .notLogin:
                MyPage.NotLogin(
                    tapScanAction: { intent.onTapScan() },
                    tapQrCodeAction: { intent.onTapMyQrCode() },
                    tapLoginAction: { intent.onTapLogin() },
                    tapSettingAction: { intent.onTapSetting() }
                )
            case .login:
                MyPage.Login(
                    user: UserManager.getUser()!,
                    tapScanAction: { intent.onTapScan() },
                    tapQrCodeAction: { intent.onTapMyQrCode() },
                    tapMessageAction: { intent.onTapMessage() },
                    tapSettingAction: { intent.onTapSetting() },
                    tapUserAction: { intent.onTapProfile() },
                    tapOrderAction: { intent.onTapMyOrder() },
                    tapChargingPileAction: { intent.onTapChargingPile() }
                )
            case .scan:
                CustomScannerView() {
                    intent.onTapBackFromScan()
                } qrcodeAction: { qrcode in
                    debugPrint("QRCode: \(qrcode)")
                    intent.onTapBackFromScan()
                }
                .ignoresSafeArea()
            case let .error(text):
                ErrorTip(text: text)
            }
        }
        .onAppear {
            intent.viewOnAppear()
        }
        .modifier(MyRouter(subjects: state.routerSubject))
    }
}
