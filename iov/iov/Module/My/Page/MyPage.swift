//
//  MyView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct MyPage: View {
    
    @StateObject var container: MviContainer<MyIntentProtocol, MyModelStateProtocol>
    private var intent: MyIntentProtocol { container.intent }
    private var state: MyModelStateProtocol { container.model }
    @State var isLogin: Bool
    
    var body: some View {
        ZStack {
            switch state.contentState {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(2)
            case .content:
                Content(intent: intent, state: state, isLogin: $isLogin)
            case let .error(text):
                ErrorTip(text: text)
            }
        }
        .onAppear {
            isLogin = User.isLogin()
        }
        .modifier(MyRouter(
            subjects: state.routerSubject,
            intent: intent
        ))
    }
}

extension MyPage {
    
    struct Content: View {
        var intent: MyIntentProtocol
        var state: MyModelStateProtocol
        @Binding var isLogin: Bool
        
        var body: some View {
            if(isLogin) {
                if let user = User.getUser() {
                    MyPage.LoginContent(
                        nickname: user.nickname, avatar: user.avatar,
                        tapMessageAction: { intent.onTapMessage() },
                        tapSettingAction: { intent.onTapSetting() },
                        tapUserAction: { intent.onTapProfile() },
                        tapArticleAction: { intent.onTapMyArticle() },
                        tapPointsAction: { intent.onTapMyPoints() },
                        tapRightsAction: { intent.onTapMyRights() },
                        tapOrderAction: { intent.onTapMyOrder() },
                        tapInviteAction: { intent.onTapMyInvite() },
                        tapChargingPileAction: { intent.onTapChargingPile() }
                    )
                }
            } else {
                MyPage.NotLoginContent(
                    tapLoginAction: { intent.onTapLogin() },
                    tapSettingAction: { intent.onTapSetting() }
                )
            }
        }
    }
}
