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
        
        var agreement: AttributedString {
            var agreement = AttributedString("我已阅读并同意《用户协议》《隐私政策》，用户首次登录将会同步注册APP账号")
            let prot = agreement.range(of: "《用户协议》")
            agreement[prot!].link = URL(string: "https://www.baidu.com")
            let priv = agreement.range(of: "《隐私政策》")
            agreement[priv!].link = URL(string: "https://www.baidu.com")
            return agreement;
        }
        
        var body: some View {
            VStack(alignment: .leading) {
                LoginView.TopBar(intent: intent, backAction: {
                    intent.onTapExitLoginIcon()
                })
                Text("请输入手机号")
                    .padding(25)
                    .font(.system(size: 24))
                    .foregroundColor(Theme.color.mainText)
                HStack {
                    Text("+86")
                        .foregroundColor(Color(hex: 0x333333))
                        .font(.system(size: 20))
                    Divider()
                        .frame(height: 30)
                        .background(Color(hex: 0x333333))
                        .padding(.leading, 5)
                        .padding(.trailing, 5)
                    MobileTextField(mobile: $mobile)
                }
                .padding(.top, 5)
                .padding(.leading, 25)
                .padding(.trailing, 25)
                .padding(.bottom, 10)
                HStack(alignment: .center) {
                    Spacer()
                    Button("获取验证码") {
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
                    .alert(Text("提示"), isPresented: $showAgreeAlert) {
                        Button("取消", role: .cancel) { }
                        Button("确认") {}
                    } message: {
                        Text("请勾选同意用户协议")
                    }
                    .alert(Text("提示"), isPresented: $showMobileAlert) {
                        Button("取消", role: .cancel) { }
                        Button("确认") {}
                    } message: {
                        Text("请输入手机号")
                    }
                    Spacer()
                }
                .padding(.leading, 15)
                .padding(.trailing, 15)
                HStack(alignment: .top) {
                    Button(action: {
                        self.agree.toggle()
                    }) {
                        if agree {
                            Image("red_select")
                            .resizable()
                            .frame(width: 12, height: 12)
                        } else {
                            Image("black_unSelect")
                            .resizable()
                            .frame(width: 12, height: 12)
                        }
                    }
                    Text(agreement)
                    .font(.system(size: 10))
                    .lineSpacing(4)
                }
                .padding(.top, 15)
                .padding(.leading, 25)
                .padding(.trailing, 25)
                Spacer()
                VStack(alignment: .center) {
                    HStack {
                        Image("black_weixin")
                            .padding(.trailing, 10)
                        Image("black_apple")
                            .padding(.leading, 10)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 10)
            }
        }
    
    }
    
}

struct LoginView_MobileLogin_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState()
    static var previews: some View {
        LoginView.buildMobileLogin()
            .environmentObject(appGlobalState)
    }
}
