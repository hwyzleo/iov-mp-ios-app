//
//  SettingView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct SettingView: View {
    
    @StateObject var container: MviContainer<SettingIntentProtocol, SettingModelStateProtocol>
    private var intent: SettingIntentProtocol { container.intent }
    private var state: SettingModelStateProtocol { container.model }
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    
    var body: some View {
        ZStack {
            SettingView.Content(
                tapProfile: { intent.onTapProfile() },
                tapAccountChange: { intent.onTapAccountChange() },
                tapAccountSecurity: { intent.onTapAccountSecurity() },
                tapAccountBinding: { intent.onTapAccountBinding() },
                tapPrivillegeAction: { intent.onTapPrivillege() },
                tapUserProtocolAction: { intent.onTapUserProtocol() },
                tapCommunityConvention: { intent.onTapCommunityConvention() },
                tapPrivacyAgreement: { intent.onTapPrivacyAgreement() },
                loginAction: { intent.onTapLogin() },
                logoutAction: { intent.onTapLogout() }, 
                appVersion: appVersion
            )
        }
        .modifier(SettingRouter(
            subjects: state.routerSubject,
            intent: intent
        ))
    }
    
}

extension SettingView {
    
    struct Content: View {
        @State private var showAlert = false
        var tapProfile: (()->Void)?
        var tapAccountChange: (()->Void)?
        var tapAccountSecurity: (()->Void)?
        var tapAccountBinding: (()->Void)?
        var tapPrivillegeAction: (()->Void)?
        var tapUserProtocolAction: (()->Void)?
        var tapCommunityConvention: (()->Void)?
        var tapPrivacyAgreement: (()->Void)?
        var loginAction: (()->Void)?
        var logoutAction: (()->Void)?
        var appVersion: String
        var version: LocalizedStringKey = "version"
        var setting: LocalizedStringKey = "setting"
        
        
        var body: some View {
            VStack {
                TopBackTitleBar(titleLocal: LocalizedStringKey("setting"))
                ScrollView {
                    VStack {
//                        MySettingView.List(title: "个人资料") {
//                            if User.isLogin() {
//                                tapProfile?()
//                            } else {
//                                loginAction?()
//                            }
//                        }
//                        MySettingView.List(title: "主使用人变更") {
//                            if User.isLogin() {
//                                tapAccountChange?()
//                            } else {
//                                loginAction?()
//                            }
//                        }
//                        MySettingView.List(title: "账号安全") {
//                            if User.isLogin() {
//                                tapAccountSecurity?()
//                            } else {
//                                loginAction?()
//                            }
//                        }
//                        MySettingView.List(title: "账号绑定") {
//                            if User.isLogin() {
//                                tapAccountBinding?()
//                            } else {
//                                loginAction?()
//                            }
//                        }
//                        MySettingView.List(title: "权限管理") {
//                            tapPrivillegeAction?()
//                        }
//                        MySettingView.List(title: "用户协议") {
//                            tapUserProtocolAction?()
//                        }
//                        MySettingView.List(title: "社区公约") {
//                            tapCommunityConvention?()
//                        }
//                        MySettingView.List(title: "隐私协议") {
//                            tapPrivacyAgreement?()
//                        }
                        Button(action: {  }) {
                            VStack {
                                HStack {
                                    Text(LocalizedStringKey("version"))
                                        .foregroundStyle(AppTheme.colors.primaryText)
                                        .font(AppTheme.fonts.listTitle)
                                    Spacer()
                                    Text("\(appVersion)")
                                        .foregroundStyle(AppTheme.colors.secondaryText)
                                        .font(AppTheme.fonts.listTitle)
                                }
                                .padding(.top, 20)
                                .padding(.bottom, 15)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        if(User.isLogin()) {
                            Spacer()
                                .frame(height: 20)
                            Button(action: { showAlert = true }) {
                                Text("退出登录")
                                    .font(.system(size: 15))
                                    .padding(10)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(Color.black)
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .scaleEffect(1)
                            }
                        }
                    }
                    .alert(Text("提示"), isPresented: $showAlert) {
                        Button("取消", role: .cancel) { }
                        Button("确认") {
                            logoutAction?()
                        }
                    } message: {
                        Text("您确定登出？")
                    }
                }
                .scrollIndicators(.hidden)
                .padding(20)
            }
        }
    }
}

struct MySettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView.Content(appVersion: "0.0.1")
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
