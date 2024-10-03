//
//  MyView_List.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension MyPage {
    struct List: View {
        var icon: String
        var title: String
        var action: (() -> Void)?
        var body: some View {
            Button(action: { action?() }) {
                VStack {
                    HStack {
                        Image(systemName: icon)
                            .font(.system(size: 18))
                            .padding(.trailing, 20)
                        Text(title)
                            .font(.system(size: 18))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18))
                    }
                    .padding(.top, 25)
                    Divider()
                        .padding(.top, 25)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    MyPage.List(icon: "doc.plaintext", title: "标题")
}
