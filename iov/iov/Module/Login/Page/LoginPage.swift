//
//  LoginView.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

struct LoginPage: View {
    
    @StateObject var container: MviContainer<LoginIntentProtocol, LoginModelStateProtocol>
    private var intent: LoginIntentProtocol { container.intent }
    private var state: LoginModelStateProtocol { container.model }
    @EnvironmentObject var appGlobalState: AppGlobalState
    
    var body: some View {
        NavigationView {
            ZStack {
                // 按登录步骤渲染，请求处理中保留当前表单（IOS-APP-DSN-CR-001 §4.1）
                // 子视图只接收值类型片段，保证模型变化能够驱动重绘
                switch state.step {
                case .inputMobile:
                    MobileLogin(
                        mobile: state.mobile,
                        agree: state.agree,
                        countryRegionCode: state.countryRegionCode,
                        operation: state.operation,
                        intent: intent
                    )
                case .inputVerifyCode:
                    MobileVerifyCode(
                        mobile: state.mobile,
                        countryRegionCode: state.countryRegionCode,
                        operation: state.operation,
                        resendAvailableAt: state.resendAvailableAt,
                        intent: intent
                    )
                }
                
                if let message = state.errorMessage {
                    LoginErrorBanner(text: message)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: state.errorMessage)
            .modifier(
                LoginRouter(
                    subjects: state.routerSubject,
                    intent: intent
                )
            )
        }
        .onAppear {
            appGlobalState.currentView = "Login"
        }
    }
    
}

// MARK: - Views

extension LoginPage {
    
    // MARK: - 顶部条
    
    struct TopBar: View {
        let intent: LoginIntentProtocol
        var backAction: () -> Void
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Button(action: {
                        backAction()
                    }) {
                        Image(systemName: "chevron.backward")
                    }
                    .foregroundColor(.black)
                    Spacer()
                }
            }
        }
    }
    
    /// 页内错误提示：不替换表单，不改变当前步骤
    struct LoginErrorBanner: View {
        let text: String
        
        var body: some View {
            VStack {
                Spacer()
                Text(text)
                    .font(AppTheme.fonts.subtext)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(AppTheme.colors.brandMain.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, AppTheme.layout.margin)
                    .padding(.bottom, 40)
            }
            .allowsHitTesting(false)
            .transition(.opacity)
        }
    }
    
}
