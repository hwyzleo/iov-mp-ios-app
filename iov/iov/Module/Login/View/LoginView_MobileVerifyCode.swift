//
//  LoginView_MobileVerifyCode.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

/// 手机号登录输入验证码
extension LoginView {
    
    struct MobileVerifyCode: View {
        
        let state: LoginModelStateProtocol
        let intent: LoginIntentProtocol
        @State var verifyCode: String = ""
        @State var countdown = 60
        @State var isCountingDown = true
        
        var body: some View {
            VStack(alignment: .leading) {
                TopBackTitleBar() {
                    intent.onTapBackMobileLoginIcon()
                }
                Spacer().frame(height: 20)
                Text(LocalizedStringKey("input_verify_code"))
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.colors.fontPrimary)
                Spacer().frame(height: 20)
                HStack {
                    Text(LocalizedStringKey("verify_code_has_sent"))
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.colors.fontSecondary)
                    Text(state.mobile)
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.colors.fontSecondary)
                }
                Spacer().frame(height: 30)
                CaptchaTextField(maxDigits: 6, pin: $verifyCode, showPin: true) {
                    intent.onTapVerifyCodeLoginButton(
                        countryRegionCode: state.countryRegionCode,
                        mobile: state.mobile,
                        verifyCode: verifyCode
                    )
                }
                Spacer().frame(height: 50)
                if isCountingDown {
                    HStack {
                        Text(LocalizedStringKey("reget_verigy_code"))
                        Text("(\(countdown))")
                    }
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.colors.fontSecondary)
                    .frame(maxWidth: .infinity)
                } else {
                    Button(action: {
                        intent.onTapResendVerifyCodeText(countryRegionCode: state.countryRegionCode, mobile: state.mobile)
                        isCountingDown = true
                        startCountdown()
                    }) {
                        Text(LocalizedStringKey("reget_verigy_code"))
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity)
                    }
                }
                Spacer()
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .onAppear {
                startCountdown()
            }
        }
        
        func startCountdown() {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                countdown -= 1
                if countdown == 0 {
                    timer.invalidate()
                    isCountingDown = false
                    countdown = 60
                }
            }
        }
    }
    
}

struct LoginView_MobileVerifyCode_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState.shared
    static var previews: some View {
        LoginView.buildMobileVerifyCode()
            .environmentObject(appGlobalState)
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
