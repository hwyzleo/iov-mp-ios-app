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
                            .foregroundStyle(AppTheme.colors.mainText)
                            .font(AppTheme.fonts.listTitle)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(AppTheme.colors.secondaryText)
                            .font(AppTheme.fonts.listTitle)
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
