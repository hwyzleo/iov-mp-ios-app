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
                loginAction: { intent.onTapLogin() },
                logoutAction: { intent.onTapLogout() }, 
                appVersion: appVersion,
                isMock: $appGlobalState.isMock,
                apiUrl: $appGlobalState.tspUrl
            )
        }
        .appBackground()
        .modifier(MyRouter(subjects: state.routerSubject))
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
            VStack(spacing: 0) {
                Spacer().frame(height: kStatusBarHeight)
                TopBackTitleBar(titleLocal: LocalizedStringKey("setting"))
                ScrollView {
                    VStack(spacing: AppTheme.layout.spacing) {
                        VStack(spacing: 0) {
                            SettingPage.List(title: "个人资料") {
                                if UserManager.isLogin() {
                                    tapProfile?()
                                } else {
                                    loginAction?()
                                }
                            }
                            // 版本信息
                            Button(action: { 
                                mockCount = mockCount + 1
                                if(isMock && mockCount > 10) {
                                    showMock = true
                                    isMock.toggle()
                                }
                            }) {
                                HStack {
                                    Text(LocalizedStringKey("version"))
                                        .foregroundStyle(AppTheme.colors.fontPrimary)
                                        .font(AppTheme.fonts.body)
                                    Spacer()
                                    Text("\(appVersion)")
                                        .foregroundStyle(AppTheme.colors.fontSecondary)
                                        .font(AppTheme.fonts.body)
                                    if(isMock) {
                                        Text("(Mock)")
                                            .foregroundStyle(AppTheme.colors.fontSecondary)
                                            .font(AppTheme.fonts.body)
                                    }
                                }
                                .padding(.vertical, 20)
                            }
                            .buttonStyle(.plain)
                        }
                        .appCardStyle()
                        
                        if(showMock) {
                            TextField("", text: $apiUrl)
                                .frame(height: 35)
                                .textFieldStyle(.plain)
                                .foregroundColor(AppTheme.colors.fontPrimary)
                                .padding()
                                .background(AppTheme.colors.cardBackground)
                                .cornerRadius(AppTheme.layout.radiusMedium)
                        }
                        
                        if(UserManager.isLogin()) {
                            RoundedCornerButton(nameLocal: LocalizedStringKey("logout"), color: .black, bgColor: AppTheme.colors.brandMain) {
                                showAlert = true
                            }
                            .padding(.top, 20)
                        }
                    }
                    .padding(.horizontal, AppTheme.layout.margin)
                    .padding(.top, 20)
                }
                .scrollIndicators(.hidden)
                .alert(Text(LocalizedStringKey("tip")), isPresented: $showAlert) {
                    Button(LocalizedStringKey("cancel"), role: .cancel) { }
                    Button(LocalizedStringKey("confirm")) {
                        logoutAction?()
                    }
                } message: {
                    Text(LocalizedStringKey("logout_confirm"))
                }
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
