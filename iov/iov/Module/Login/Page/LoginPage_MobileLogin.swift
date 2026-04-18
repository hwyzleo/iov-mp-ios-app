//
//  LoginView_MobileLogin.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

/// 手机号登录
extension LoginPage {
    
    struct MobileLogin: View {
        
        let state: LoginModelStateProtocol
        let intent: LoginIntentProtocol
        @State var mobile: String
        @State var agree = false
        @State var showAgreeAlert = false
        @State var showMobileAlert = false
        
        init(state: LoginModelStateProtocol, intent: LoginIntentProtocol) {
            self.state = state
            self.intent = intent
            self._mobile = State(initialValue: state.mobile)
            self._agree = State(initialValue: state.agree)
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: kStatusBarHeight)
                
                TopBackTitleBar() {
                    intent.onTapExitLoginIcon()
                }
                .padding(.horizontal, AppTheme.layout.margin)
                
                VStack(alignment: .leading, spacing: 40) {
                    // 标题
                    VStack(alignment: .leading, spacing: 12) {
                        Text(L10n.login_register)
                            .font(AppTheme.fonts.bigTitle)
                            .foregroundColor(AppTheme.colors.fontPrimary)
                        Text(L10n.input_mobile)
                            .font(AppTheme.fonts.body)
                            .foregroundColor(AppTheme.colors.fontSecondary)
                    }
                    .padding(.top, 40)
                    
                    // 输入区
                    VStack(spacing: 0) {
                        HStack(spacing: 16) {
                            Text("+86")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(AppTheme.colors.fontPrimary)
                            
                            Rectangle()
                                .fill(AppTheme.colors.fontTertiary.opacity(0.3))
                                .frame(width: 1, height: 24)
                            
                            MobileTextField(mobile: $mobile)
                        }
                        .padding(.vertical, 16)
                        
                        Rectangle()
                            .fill(AppTheme.colors.brandMain.opacity(0.5))
                            .frame(height: 1)
                    }
                    
                    // 按钮
                    VStack(spacing: 20) {
                        RoundedCornerButton(
                            nameLocal: LocalizedStringKey("get_verify_code"),
                            color: .black,
                            bgColor: (mobile.count == 13 && agree) ? AppTheme.colors.brandMain : AppTheme.colors.brandMain.opacity(0.3)
                        ) {
                            if !agree {
                                self.showAgreeAlert = true
                                return
                            }
                            if mobile.isEmpty {
                                self.showMobileAlert = true
                                return
                            }
                            intent.onTapSendVerifyCodeButton(
                                countryRegionCode: "+86",
                                mobile: mobile
                            )
                        }
                        .disabled(mobile.count != 13)
                        
                        // 协议勾选
                        HStack(alignment: .top, spacing: 8) {
                            Button(action: {
                                withAnimation(.spring()) {
                                    self.agree.toggle()
                                }
                            }) {
                                Image(systemName: agree ? "checkmark.circle.fill" : "circle")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .foregroundColor(agree ? AppTheme.colors.brandMain : AppTheme.colors.fontTertiary)
                            }
                            .buttonStyle(.plain)
                            
                            Text(L10n.login_confirm_tip)
                                .font(AppTheme.fonts.subtext)
                                .foregroundColor(AppTheme.colors.fontSecondary)
                                .lineSpacing(4)
                        }
                        .padding(.top, 10)
                    }
                }
                .padding(.horizontal, AppTheme.layout.margin * 1.5)
                
                Spacer()
            }
            .background(AppTheme.colors.background.ignoresSafeArea())
            .alert(Text(L10n.tip), isPresented: $showAgreeAlert) {
                Button(L10n.confirm) {}
            } message: {
                Text(L10n.agree_user_agreement)
            }
            .alert(Text(L10n.tip), isPresented: $showMobileAlert) {
                Button(L10n.confirm) {}
            } message: {
                Text(L10n.input_mobile)
            }
        }
        
    }
    
}

struct LoginView_MobileLogin_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState.shared
    static var previews: some View {
        LoginPage.buildMobileLogin()
            .environmentObject(appGlobalState)
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
