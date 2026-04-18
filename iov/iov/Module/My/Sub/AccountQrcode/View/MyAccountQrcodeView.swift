//
//  MyAccountQrcodeView.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI
import Kingfisher

struct MyAccountQrcodeView: View {
    
    @StateObject var container: MviContainer<MyAccountQrcodeIntentProtocol, MyAccountQrcodeModelStateProtocol>
    private var intent: MyAccountQrcodeIntentProtocol { container.intent }
    private var state: MyAccountQrcodeModelStateProtocol { container.model }
    @EnvironmentObject var appGlobalState: AppGlobalState
    
    var body: some View {
        VStack(spacing: 0) {
            TopBackTitleBar(title: "我的二维码")
            
            ZStack {
                AppTheme.colors.background.ignoresSafeArea()
                
                switch state.contentState {
                case .loading:
                    ProgressView()
                case .content:
                    VStack(spacing: 30) {
                        Spacer()
                        
                        VStack(spacing: 20) {
                            if let user = UserManager.getUser() {
                                HStack(spacing: 15) {
                                    AvatarImage(avatar: user.avatar, width: 60)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(user.nickname)
                                            .font(AppTheme.fonts.title1)
                                            .foregroundColor(AppTheme.colors.fontPrimary)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                            }
                            
                            if !state.qrcode.isEmpty {
                                if let qrImage = QRCodeUtil.generateQRCode(from: state.qrcode) {
                                    Image(uiImage: qrImage)
                                        .resizable()
                                        .interpolation(.none)
                                        .scaledToFit()
                                        .foregroundColor(.black) // 确保前景色为黑色
                                        .frame(width: 250, height: 250)
                                        .padding(10)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                } else {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(width: 250, height: 250)
                                        .overlay(Text("二维码生成失败"))
                                }
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 250, height: 250)
                                    .overlay(Text("二维码生成中..."))
                            }
                            
                            Text("扫一扫上面的二维码，加我好友")
                                .font(AppTheme.fonts.subtext)
                                .foregroundColor(AppTheme.colors.fontSecondary)
                                .padding(.bottom, 30)
                        }
                        .background(AppTheme.colors.cardBackground)
                        .cornerRadius(20)
                        .padding(.horizontal, 40)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        
                        Spacer()
                        Spacer()
                    }
                case .error(let text):
                    ErrorTip(text: text)
                }
            }
        }
        .onAppear {
            appGlobalState.currentView = "MyAccountQrcode"
            intent.viewOnAppear()
        }
    }
}

struct MyAccountQrcodeView_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState.shared
    static var previews: some View {
        MyAccountQrcodeView(container: MyAccountQrcodeView.buildContainer())
            .environmentObject(appGlobalState)
    }
}
