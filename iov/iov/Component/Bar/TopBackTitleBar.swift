//
//  TopBackTitleBar.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import Foundation
import SwiftUI

/// 顶部带返回的标题Bar
struct TopBackTitleBar: View {
    @Environment(\.dismiss) private var dismiss
    var title: String?
    var titleLocal: LocalizedStringKey?
    var color: Color = .black
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
            .bold()
            HStack {
                Button(action: {
                    action?() ?? dismiss()
                }) {
                    Image("icon_arrow_left")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
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
