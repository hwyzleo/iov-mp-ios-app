//
//  MySettingProfileView_List.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

extension MySettingProfileView {
    struct List: View {
        var title: String
        var value: String
        
        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    Text(title)
                        .font(AppTheme.fonts.body)
                        .foregroundColor(AppTheme.colors.fontPrimary)
                    Spacer()
                    Text(value)
                        .font(AppTheme.fonts.body)
                        .foregroundColor(AppTheme.colors.fontSecondary)
                    Image(systemName: "chevron.right")
                        .font(AppTheme.fonts.body)
                        .foregroundColor(AppTheme.colors.fontTertiary)
                }
                .padding(.vertical, 20)
                Divider()
            }
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    MySettingProfileView.List(title: "标题", value: "值")
}
