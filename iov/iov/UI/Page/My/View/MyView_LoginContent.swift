//
//  MyView_LoginContent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension MyView {
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
            VStack {
                MyView.TopBar(
                    tapMessageAction: { tapMessageAction?() },
                    tapSettingAction: { tapSettingAction?() }
                )
                ScrollView {
                    VStack(alignment: .leading) {
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
                        .padding(.bottom, 10)
                        Button("签到") {
                            
                        }
                        .font(.system(size: 15))
                        .padding(5)
                        .frame(width: 100)
                        .foregroundColor(Color.black)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .scaleEffect(1)
                        Spacer()
                            .frame(height: 50)
                        VStack {
                            MyView.List(icon: "doc.plaintext", title: "我的作品") {
                                tapArticleAction?()
                            }
                            MyView.List(icon: "gift", title: "我的积分") {
                                tapPointsAction?()
                            }
                            MyView.List(icon: "medal", title: "我的权益") {
                                tapRightsAction?()
                            }
                            MyView.List(icon: "list.bullet", title: "我的订单") {
                                tapOrderAction?()
                            }
                            MyView.List(icon: "person.badge.plus", title: "邀请好友") {
                                tapInviteAction?()
                            }
                            MyView.List(icon: "doc.text.below.ecg", title: "试驾报告") {
                                tapTestDriveReportAction?()
                            }
                            MyView.List(icon: "ev.charger", title: "我的家充桩") {
                                tapChargingPileAction?()
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
    }
}

struct MyView_Login_Previews: PreviewProvider {
    static var previews: some View {
        MyView.LoginContent(nickname: "测试昵称", avatar: "")
    }
}
