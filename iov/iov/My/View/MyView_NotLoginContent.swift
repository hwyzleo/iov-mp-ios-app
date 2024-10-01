//
//  MyView_NotLoginContent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import SwiftyJSON
import MBProgressHUD

extension MyView {
    struct NotLoginContent: View {
        var tapLoginAction: (() -> Void)?
        var tapMessageAction: (() -> Void)?
        var tapSettingAction: (() -> Void)?
        
        var body: some View {
            ScrollView {
                MyView.TopBar(
                    tapLoginAction: { tapLoginAction?() },
                    tapMessageAction: { tapMessageAction?() },
                    tapSettingAction: { tapSettingAction?() }
                )
                VStack {
                    Button(action: {
                        tapLoginAction?()
                    }) {
                        VStack(alignment: .center) {
                            HStack {
                                Text("Hi，\n欢迎您的到来")
                                    .font(.system(size: 22))
                                    .lineLimit(2)
                                    .frame(height: 60)
                                Spacer()
                                Image("MyPlaceHolder")
                            }
                            .padding(.bottom, 20)
                            Button("登录 / 注册") {
                                tapLoginAction?()
                            }
                            .font(.system(size: 15))
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color.black)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .scaleEffect(1)
                        }
                    }
                    .buttonStyle(.plain)
                    Spacer()
                        .frame(height: 50)
                    VStack {
                        MyView.List(icon: "doc.plaintext", title: "我的作品") {
                            tapLoginAction?()
                        }
                        MyView.List(icon: "gift", title: "我的积分") {
                            tapLoginAction?()
                        }
                        MyView.List(icon: "medal", title: "我的权益") {
                            tapLoginAction?()
                        }
                        MyView.List(icon: "list.bullet", title: "我的订单") {
                            tapLoginAction?()
                        }
                        MyView.List(icon: "person.badge.plus", title: "邀请好友") {
                            tapLoginAction?()
                        }
                        MyView.List(icon: "doc.text.below.ecg", title: "试驾报告") {
                            tapLoginAction?()
                        }
                        MyView.List(icon: "ev.charger", title: "我的家充桩") {
                            tapLoginAction?()
                        }
                    }
                }
                .padding(20)
            }
        }
    }
}

struct MyView_NotLogin_Previews: PreviewProvider {
    static var previews: some View {
        MyView.NotLoginContent()
    }
}
