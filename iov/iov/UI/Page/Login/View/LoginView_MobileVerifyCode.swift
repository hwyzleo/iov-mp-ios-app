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
                LoginView.TopBar(intent: intent, backAction: {
                    intent.onTapBackMobileLoginIcon()
                })
                Text("请输入验证码")
                    .padding(.leading, 25)
                    .padding(.top, 25)
                    .font(.system(size: 24))
                    .foregroundColor(Theme.color.mainText)
                Text("验证码已发送至您的手机：" + state.mobile)
                    .padding(.leading, 25)
                    .padding(.top, 5)
                    .font(.system(size: 15))
                    .foregroundColor(Color.gray)
                CaptchaTextField(maxDigits: 6, pin: $verifyCode, showPin: true) {
                    intent.onTapVerifyCodeLoginButton(
                        countryRegionCode: state.countryRegionCode,
                        mobile: state.mobile,
                        verifyCode: verifyCode
                    )
                }
                .padding(25)
                if isCountingDown {
                    Text("重新获取验证码(\(countdown))")
                        .padding(.top, 50)
                        .font(.system(size: 14))
                        .foregroundColor(Color.gray)
                        .frame(maxWidth: .infinity)
                } else {
                    Button(action: {
                        intent.onTapResendVerifyCodeText(countryRegionCode: state.countryRegionCode, mobile: state.mobile)
                        isCountingDown = true
                        startCountdown()
                    }) {
                        Text("重新获取验证码")
                            .padding(.top, 50)
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity)
                    }
                }
                Spacer()
            }
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
    @StateObject static var appGlobalState = AppGlobalState()
    static var previews: some View {
        LoginView.buildMobileVerifyCode()
            .environmentObject(appGlobalState)
    }
}
