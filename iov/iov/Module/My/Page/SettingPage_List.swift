//
//  SettingView_List.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension SettingPage {
    struct List: View {
        var title: String = ""
        var titleLocal: LocalizedStringKey?
        var action: (() -> Void)?
        
        var body: some View {
            Button(action: { action?() }) {
                VStack {
                    HStack {
                        if let local = titleLocal {
                            Text(local)
                                .foregroundStyle(AppTheme.colors.fontPrimary)
                                .font(AppTheme.fonts.body)
                        } else {
                            Text(title)
                                .foregroundStyle(AppTheme.colors.fontPrimary)
                                .font(AppTheme.fonts.body)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(AppTheme.colors.fontSecondary)
                            .font(AppTheme.fonts.body)
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
    SettingPage.List(title: "标题")
}
