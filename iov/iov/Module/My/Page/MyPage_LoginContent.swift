//
//  MyView_LoginContent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension MyPage {
    struct LoginContent: View {
        var nickname: String
        var avatar: String
        var tapMessageAction: (() -> Void)?
        var tapSettingAction: (() -> Void)?
        var tapUserAction: (() -> Void)?
        var tapArticleAction: (() -> Void)?
        var tapPointsAction: (() -> Void)?
        var tapRightsAction: (() -> Void)?
        var tapOrderAction: (() -> Void)?
        var tapInviteAction: (() -> Void)?
        var tapTestDriveReportAction: (() -> Void)?
        var tapChargingPileAction: (() -> Void)?
        
        var body: some View {
            VStack(alignment: .leading) {
                MyPage.TopBar(
                    tapMessageAction: { tapMessageAction?() },
                    tapSettingAction: { tapSettingAction?() }
                )
                Spacer()
                    .frame(height: 20)
                HStack {
                    Text(nickname)
                        .font(.system(size: 22))
                        .lineLimit(2)
                        .frame(height: 60)
                    Spacer()
                    Button(action: {
                        tapUserAction?()
                    }) {
                        AvatarImage(avatar: avatar, width: 80)
                    }
                    .buttonStyle(.plain)
                }
                RoundedCornerButton(nameLocal: LocalizedStringKey("sign_in")) {
                    
                }
                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                ScrollView {
                }
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
        }
    }
}

struct MyView_Login_Previews: PreviewProvider {
    static var previews: some View {
        MyPage.LoginContent(nickname: "hwyz_leo", avatar: "https://pic.imgdb.cn/item/66e667a0d9c307b7e93075e8.png")
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
