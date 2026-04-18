//
//  LoginView_MobileVerifyCode.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

/// 手机号登录输入验证码
extension LoginPage {
    
    struct MobileVerifyCode: View {
        
        let state: LoginModelStateProtocol
        let intent: LoginIntentProtocol
        @State var verifyCode: String = ""
        @State var countdown = 60
        @State var isCountingDown = true
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: kStatusBarHeight)
                
                TopBackTitleBar() {
                    intent.onTapBackMobileLoginIcon()
                }
                .padding(.horizontal, AppTheme.layout.margin)
                
                VStack(alignment: .leading, spacing: 40) {
                    // 标题
                    VStack(alignment: .leading, spacing: 12) {
                        Text(LocalizedStringKey("input_verify_code"))
                            .font(AppTheme.fonts.bigTitle)
                            .foregroundColor(AppTheme.colors.fontPrimary)
                        
                        HStack(spacing: 4) {
                            Text(LocalizedStringKey("verify_code_has_sent"))
                            Text(state.mobile)
                        }
                        .font(AppTheme.fonts.body)
                        .foregroundColor(AppTheme.colors.fontSecondary)
                    }
                    .padding(.top, 40)
                    
                    // 验证码输入
                    CaptchaTextField(maxDigits: 6, pin: $verifyCode, showPin: true) {
                        intent.onTapVerifyCodeLoginButton(
                            countryRegionCode: state.countryRegionCode,
                            mobile: state.mobile,
                            verifyCode: verifyCode
                        )
                    }
                    .padding(.vertical, 20)
                    
                    // 倒计时/重发
                    VStack(spacing: 24) {
                        if isCountingDown {
                            HStack(spacing: 4) {
                                Text(LocalizedStringKey("reget_verigy_code"))
                                Text("\(countdown)s")
                                    .foregroundColor(AppTheme.colors.brandMain)
                            }
                            .font(AppTheme.fonts.body)
                            .foregroundColor(AppTheme.colors.fontSecondary)
                        } else {
                            Button(action: {
                                intent.onTapResendVerifyCodeText(countryRegionCode: state.countryRegionCode, mobile: state.mobile)
                                countdown = 60
                                isCountingDown = true
                                // 这里不需要再次调用 startCountdown，因为 onAppear 里的 timer 还在跑或者需要重新触发
                            }) {
                                Text(LocalizedStringKey("reget_verigy_code"))
                                    .font(AppTheme.fonts.body)
                                    .foregroundColor(AppTheme.colors.brandMain)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(AppTheme.colors.brandMain.opacity(0.1))
                                    .cornerRadius(AppTheme.layout.radiusSmall)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, AppTheme.layout.margin * 1.5)
                
                Spacer()
            }
            .background(AppTheme.colors.background.ignoresSafeArea())
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
        LoginPage.buildMobileVerifyCode()
            .environmentObject(appGlobalState)
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
