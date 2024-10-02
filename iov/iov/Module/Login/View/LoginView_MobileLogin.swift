//
//  LoginView_MobileLogin.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

/// 手机号登录
extension LoginView {
    
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
            VStack(alignment: .leading) {
                TopBackTitleBar() {
                    intent.onTapExitLoginIcon()
                }
                Spacer().frame(height: 20)
                Text(LocalizedStringKey("input_mobile"))
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.colors.fontPrimary)
                Spacer().frame(height: 20)
                HStack {
                    Text("+86")
                        .foregroundColor(AppTheme.colors.fontPrimary)
                        .font(.system(size: 20))
                    Divider()
                        .frame(height: 30)
                        .background(AppTheme.colors.fontPrimary)
                        .padding(.leading, 5)
                        .padding(.trailing, 5)
                    MobileTextField(mobile: $mobile)
                }
                Spacer().frame(height: 20)
                HStack(alignment: .center) {
                    Spacer()
                    Button(LocalizedStringKey("get_verify_code")) {
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
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color.white)
                    .background(mobile.isEmpty || mobile.count != 13 ? Color.gray : Color.black)
                    .cornerRadius(22.5)
                    .alert(Text(LocalizedStringKey("tip")), isPresented: $showAgreeAlert) {
                        Button(LocalizedStringKey("cancel"), role: .cancel) { }
                        Button(LocalizedStringKey("confirm")) {}
                    } message: {
                        Text(LocalizedStringKey("agree_user_agreement"))
                    }
                    .alert(Text(LocalizedStringKey("tip")), isPresented: $showMobileAlert) {
                        Button(LocalizedStringKey("cancel"), role: .cancel) { }
                        Button(LocalizedStringKey("confirm")) {}
                    } message: {
                        Text(LocalizedStringKey("input_mobile"))
                    }
                    Spacer()
                }
                Spacer().frame(height: 20)
                HStack(alignment: .top) {
                    Button(action: {
                        self.agree.toggle()
                    }) {
                        if agree {
                            Image("icon_circle_check")
                            .resizable()
                            .frame(width: 14, height: 14)
                        } else {
                            Image("icon_circle")
                            .resizable()
                            .frame(width: 14, height: 14)
                        }
                    }
                    Text(LocalizedStringKey("login_confirm_tip"))
                    .font(.system(size: 12))
                    .lineSpacing(4)
                }
                .padding(.leading, 10)
                .padding(.trailing, 10)
                Spacer()
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
        }
        
    }
    
}

struct LoginView_MobileLogin_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState.shared
    static var previews: some View {
        LoginView.buildMobileLogin()
            .environmentObject(appGlobalState)
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
