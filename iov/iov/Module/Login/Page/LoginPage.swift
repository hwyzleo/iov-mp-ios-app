//
//  LoginView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct LoginPage: View {
    
    @StateObject var container: MviContainer<LoginIntentProtocol, LoginModelStateProtocol>
    private var intent: LoginIntentProtocol { container.intent }
    private var state: LoginModelStateProtocol { container.model }
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appGlobalState: AppGlobalState
    
    var body: some View {
        NavigationView {
            ZStack {
                switch state.contentState {
                case .loading:
                    LoadingTip()
                case .inputMobile:
                    MobileLogin(state: state, intent: intent)
                case .inputVerifyCode:
                    MobileVerifyCode(state: state, intent: intent)
                case let .error(text):
                    MobileLogin(state: state, intent: intent)
                    ErrorTip(text: text)
                }
            }
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
    
}
