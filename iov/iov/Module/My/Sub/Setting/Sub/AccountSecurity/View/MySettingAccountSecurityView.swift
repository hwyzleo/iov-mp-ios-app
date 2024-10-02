//
//  MySettingAccountSecurityView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct MySettingAccountSecurityView: View {
    @StateObject var container: MviContainer<MySettingAccountSecurityIntentProtocol, MySettingAccountSecurityModelStateProtocol>
    private var intent: MySettingAccountSecurityIntentProtocol { container.intent }
    private var state: MySettingAccountSecurityModelStateProtocol { container.model }
    
    var body: some View {
        ZStack {
            switch state.contentState {
            case .loading:
                LoadingTip()
            case .content:
                Content(intent: intent, state: state)
            case let .error(text):
                ErrorTip(text: text)
            }
        }
        .onAppear(perform: intent.viewOnAppear)
        .modifier(MySettingAccountSecurityRouter(
            subjects: state.routerSubject,
            intent: intent
        ))
    }
}

// MARK: - Views

private extension MySettingAccountSecurityView {
    
    private struct Content: View {
        let intent: MySettingAccountSecurityIntentProtocol
        let state: MySettingAccountSecurityModelStateProtocol
        @State private var image: Image? = nil
        @State private var showBirthday = false
        @State private var selectedDate = Date()
        @EnvironmentObject var appGlobalState: AppGlobalState
        @State private var isToggleOn = false
        
        var body: some View {
            VStack {
                TopBackTitleBar(title: "账号与安全")
                Spacer()
                    .frame(height: 40)
                VStack {
                    TitleList(title: "服务密码") {
                    }
                    Button(action: {
                        
                    }) {
                        VStack(alignment: .leading) {
                            HStack {
                                Toggle(isOn: $isToggleOn) {
                                    Text("面容ID")
                                }
                            }
                            .padding(.top, 20)
                            .padding(.bottom, 10)
                            .contentShape(Rectangle())
                            Text("开启后可以使用面容ID替代服务密码，仅对本机生效")
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                                .padding(.bottom, 20)
                        }
                        .modifier(BottomLineModifier())
                    }
                    .buttonStyle(.plain)
                    TitleList(title: "注销账号") {
                    }
                }
                .padding(20)
                Spacer()
            }
            .onAppear {
                appGlobalState.currentView = "MySettingAccountSecuriy"
            }
        }
    }
    
}


struct MySettingAccountSecurityView_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState.shared
    static var previews: some View {
        MySettingAccountSecurityView(container: MySettingAccountSecurityView.buildContainer())
            .environmentObject(appGlobalState)
    }
}
