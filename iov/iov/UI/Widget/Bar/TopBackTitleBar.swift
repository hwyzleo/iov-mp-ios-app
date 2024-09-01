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
    var title: String = ""
    var color: Color = .black
    var action: (() -> Void)?
    var body: some View {
        ZStack {
            HStack {
                HStack {
                    Spacer()
                    Text(title)
                        .bold()
                        .foregroundColor(color)
                    Spacer()
                }
            }
            HStack {
                Button(action: {
                    action?() ?? dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .padding(.leading, 20)
                        .foregroundColor(color)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
        .padding(.bottom, 10)
    }
}

#if DEBUG
// MARK: - Previews
struct TopBar_Previews: PreviewProvider {
    static var previews: some View {
        TopBackTitleBar(title: "标题")
    }
}
#endif
