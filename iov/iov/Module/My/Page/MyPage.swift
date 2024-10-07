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
    
    var body: some View {
        ZStack {
            switch state.contentState {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(2)
            case .notLogin:
                MyPage.NotLogin(
                    tapLoginAction: { intent.onTapLogin() },
                    tapSettingAction: { intent.onTapSetting() }
                )
            case .login:
                MyPage.Login(
                    nickname: UserManager.getUser()!.nickname,
                    avatar: UserManager.getUser()!.avatar,
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
            case let .error(text):
                ErrorTip(text: text)
            }
        }
        .onAppear {
            intent.viewOnAppear()
        }
        .modifier(MyRouter(subjects: state.routerSubject))
    }
}
