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
        
        let mobile: String
        let countryRegionCode: String
        let operation: LoginTypes.Model.LoginOperation
        let resendAvailableAt: Date?
        let intent: LoginIntentProtocol
        @State var verifyCode: String = ""
        
        private var isResending: Bool {
            return operation == .resendingCode
        }
        
        private var isLoggingIn: Bool {
            return operation == .loggingIn
        }
        
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
                            Text(mobile)
                        }
                        .font(AppTheme.fonts.body)
                        .foregroundColor(AppTheme.colors.fontSecondary)
                    }
                    .padding(.top, 40)
                    
                    // 验证码输入
                    CaptchaTextField(
                        maxDigits: 6,
                        pin: $verifyCode,
                        showPin: true,
                        isEnabled: !isLoggingIn
                    ) {
                        intent.onTapVerifyCodeLoginButton(
                            countryRegionCode: countryRegionCode,
                            mobile: mobile,
                            verifyCode: verifyCode
                        )
                    }
                    .padding(.vertical, 20)
                    
                    if isLoggingIn {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(AppTheme.colors.brandMain)
                    }
                    
                    // 倒计时/重发：由 resendAvailableAt 与时间轴计算，避免 Timer 失效
                    VStack(spacing: 24) {
                        TimelineView(.periodic(from: Date(), by: 1)) { context in
                            let remaining = LoginModel.resendRemainingSeconds(availableAt: resendAvailableAt, now: context.date)
                            if remaining > 0 {
                                HStack(spacing: 4) {
                                    Text(LocalizedStringKey("reget_verigy_code"))
                                    Text("\(remaining)s")
                                        .foregroundColor(AppTheme.colors.brandMain)
                                }
                                .font(AppTheme.fonts.body)
                                .foregroundColor(AppTheme.colors.fontSecondary)
                            } else {
                                HStack(spacing: 8) {
                                    Button(action: {
                                        intent.onTapResendVerifyCodeText(
                                            countryRegionCode: countryRegionCode,
                                            mobile: mobile
                                        )
                                    }) {
                                        Text(LocalizedStringKey("reget_verigy_code"))
                                            .font(AppTheme.fonts.body)
                                            .foregroundColor(AppTheme.colors.brandMain)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(AppTheme.colors.brandMain.opacity(0.1))
                                            .cornerRadius(AppTheme.layout.radiusSmall)
                                    }
                                    .disabled(operation != .idle)
                                    
                                    if isResending {
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                            .tint(AppTheme.colors.brandMain)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, AppTheme.layout.margin * 1.5)
                
                Spacer()
            }
            .background(AppTheme.colors.background.ignoresSafeArea())
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
