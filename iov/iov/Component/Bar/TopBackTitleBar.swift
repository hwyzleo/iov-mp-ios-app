//
//  TopBackTitleBar.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import Foundation
import SwiftUI

/// 顶部带返回的标题Bar
struct TopBackTitleBar: View {
    @Environment(\.dismiss) private var dismiss
    var title: String?
    var titleLocal: LocalizedStringKey?
    var color: Color = AppTheme.colors.fontPrimary
    var action: (() -> Void)?
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                if(title != nil) {
                    Text(title!)
                } else if(titleLocal != nil) {
                    Text(titleLocal!)
                }
                Spacer()
            }
            .font(AppTheme.fonts.title1)
            HStack {
                Button(action: {
                    action?() ?? dismiss()
                }) {
                    Image("icon_arrow_left")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
        .frame(height: 44)
        .foregroundColor(color)
    }
}

#if DEBUG
// MARK: - Previews
struct TopBar_Previews: PreviewProvider {
    static var previews: some View {
        TopBackTitleBar(titleLocal: LocalizedStringKey("title"))
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
#endif
