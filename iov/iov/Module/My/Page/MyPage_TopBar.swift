//
//  MyView_TopBar.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension MyPage {
    struct TopBar: View {
        var tapLoginAction: (() -> Void)?
        var tapMessageAction: (() -> Void)?
        var tapSettingAction: (() -> Void)?
        
        var body: some View {
            VStack(alignment: .trailing) {
                HStack {
                    Spacer()
                    Button(action: {
                        if User.isLogin() {
                            tapMessageAction?()
                        } else {
                            tapLoginAction?()
                        }
                    }) {
                        Image("icon_bell")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                        .frame(width: 20)
                    Button(action: {
                        tapSettingAction?()
                    }) {
                        Image("icon_setting")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    MyPage.TopBar()
}
