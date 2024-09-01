//
//  TopCloseTitleBar.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

/// 顶部带关闭的标题Bar
struct TopCloseTitleBar: View {
    @Environment(\.dismiss) private var dismiss
    var title: String = ""
    var action: (() -> Void)?
    var body: some View {
        ZStack {
            HStack {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .bold()
                Spacer()
                Button(action: {
                    action?() ?? dismiss()
                }) {
                    Image("cross")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct TopCloseTitleBar_Previews: PreviewProvider {
    static var previews: some View {
        TopCloseTitleBar(title: "标题")
    }
}
