//
//  SettingView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct SettingPage: View {
    
    @EnvironmentObject var appGlobalState: AppGlobalState
    @StateObject var container: MviContainer<SettingIntentProtocol, SettingModelStateProtocol>
    private var intent: SettingIntentProtocol { container.intent }
    private var state: SettingModelStateProtocol { container.model }
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    
    var body: some View {
        ZStack {
            SettingPage.Content(
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
                appVersion: appVersion,
                isMock: $appGlobalState.isMock,
                apiUrl: $appGlobalState.tspUrl
            )
        }
        .modifier(SettingRouter(
            subjects: state.routerSubject,
            intent: intent
        ))
    }
    
}

extension SettingPage {
    
    struct Content: View {
        
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
        @State private var showAlert = false
        @State private var showMock = false
        @State private var mockCount: Int = 0
        @Binding var isMock: Bool
        @Binding var apiUrl: String
        
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
                        Button(action: { 
                            mockCount = mockCount + 1
                            if(isMock && mockCount > 10) {
                                showMock = true
                                isMock.toggle()
                            }
                        }) {
                            VStack {
                                Spacer().frame(height: 20)
                                HStack {
                                    Text(LocalizedStringKey("version"))
                                        .foregroundStyle(AppTheme.colors.fontPrimary)
                                        .font(AppTheme.fonts.listTitle)
                                    Spacer()
                                    Text("\(appVersion)")
                                        .foregroundStyle(AppTheme.colors.fontSecondary)
                                        .font(AppTheme.fonts.listTitle)
                                    if(isMock) {
                                        Text("(Mock)")
                                            .foregroundStyle(AppTheme.colors.fontSecondary)
                                            .font(AppTheme.fonts.listTitle)
                                    }
                                }
                                Spacer().frame(height: 20)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        if(showMock) {
                            TextField("", text: $apiUrl)
                                .frame(height: 35)
                                .textFieldStyle(.plain)
                                .onChange(of: apiUrl) { newApiUrl in
                                }
                        }
                        if(User.isLogin()) {
                            Spacer()
                                .frame(height: 20)
                            RoundedCornerButton(nameLocal: LocalizedStringKey("logout")) {
                                showAlert = true
                            }
                        }
                    }
                    .alert(Text(LocalizedStringKey("tip")), isPresented: $showAlert) {
                        Button(LocalizedStringKey("cancel"), role: .cancel) { }
                        Button(LocalizedStringKey("confirm")) {
                            logoutAction?()
                        }
                    } message: {
                        Text(LocalizedStringKey("logout_confirm"))
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
        @StateObject var appGlobalState = AppGlobalState.shared
        @State var isMock = true
        @State var apiUrl = ""
        SettingPage.Content(appVersion: "0.0.1", isMock: $isMock, apiUrl: $apiUrl)
            .environment(\.locale, .init(identifier: "zh-Hans"))
            .environmentObject(appGlobalState)
    }
}
