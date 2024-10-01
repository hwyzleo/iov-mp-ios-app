//
//  MySettingAccountBindingView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct MySettingAccountBindingView: View {
    @StateObject var container: MviContainer<MySettingAccountBindingIntentProtocol, MySettingAccountBindingModelStateProtocol>
    private var intent: MySettingAccountBindingIntentProtocol { container.intent }
    private var state: MySettingAccountBindingModelStateProtocol { container.model }
    
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
        .modifier(MySettingAccountBindingRouter(
            subjects: state.routerSubject,
            intent: intent
        ))
    }
}

// MARK: - Views

private extension MySettingAccountBindingView {
    
    private struct Content: View {
        let intent: MySettingAccountBindingIntentProtocol
        let state: MySettingAccountBindingModelStateProtocol
        @EnvironmentObject var appGlobalState: AppGlobalState
        @State private var isToggleOn = false
        
        var body: some View {
            VStack {
                TopBackTitleBar(title: "账号绑定")
                Spacer()
                    .frame(height: 20)
                VStack(alignment: .leading) {
                    Text("系统账号")
                    VStack(alignment: .leading) {
                        HStack {
                            Image("phone")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("手机账号")
                                .font(.system(size: 14))
                            Spacer()
                            Text("13917288107")
                                .font(.system(size: 14))
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                        .contentShape(Rectangle())
                    }
                    .modifier(BottomLineModifier())
                    Spacer()
                        .frame(height: 30)
                    Text("社交账号")
                    VStack(alignment: .leading) {
                        HStack {
                            Toggle(isOn: $isToggleOn) {
                                HStack {
                                    Image("weixin")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                    Text("微信")
                                        .font(.system(size: 14))
                                }
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                        .contentShape(Rectangle())
                    }
                    .modifier(BottomLineModifier())
                    VStack(alignment: .leading) {
                        HStack {
                            Toggle(isOn: $isToggleOn) {
                                HStack {
                                    Image("apple")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                    Text("Apple")
                                        .font(.system(size: 14))
                                }
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                        .contentShape(Rectangle())
                    }
                    .modifier(BottomLineModifier())
                }
                .padding(20)
                Spacer()
            }
            .onAppear {
                appGlobalState.currentView = "MySettingAccountBinding"
            }
        }
    }
    
}


struct MySettingAccountBindingView_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState()
    static var previews: some View {
        MySettingAccountBindingView(container: MySettingAccountBindingView.buildContainer())
            .environmentObject(appGlobalState)
    }
}
