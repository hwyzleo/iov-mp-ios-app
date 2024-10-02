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
                Spacer()
                    .frame(height: 20)
                VStack {
                    Button(action: {
                        tapLoginAction?()
                    }) {
                        VStack(alignment: .center) {
                            HStack {
                                Text(LocalizedStringKey("not_login_welcome"))
                                    .font(.system(size: 22))
                                    .lineLimit(2)
                                    .frame(height: 60)
                                Spacer()
                                Image("my_place_holder")
                            }
                            .padding(.bottom, 20)
                            RoundedCornerButton(nameLocal: LocalizedStringKey("login_register")) {
                                tapLoginAction?()
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    Spacer()
                        .frame(height: 50)
                }
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
        }
    }
}

struct MyView_NotLogin_Previews: PreviewProvider {
    static var previews: some View {
        MyView.NotLoginContent()
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
