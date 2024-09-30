//
//  MySettingView_List.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension MySettingView {
    struct List: View {
        var title: String
        var action: (() -> Void)?
        
        var body: some View {
            Button(action: { action?() }) {
                VStack {
                    HStack {
                        Text(title)
                            .foregroundStyle(Theme.color.mainText)
                            .font(Theme.font.listTitle)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Theme.color.secondaryText)
                            .font(Theme.font.listTitle)
                    }
                    .padding(.top, 20)
                    Divider()
                        .padding(.top, 15)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    MySettingView.List(title: "标题")
}
