//
//  MyMessageView_List.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension MyMessageView {
    struct List: View {
        var icon: String
        var title: String
        var action: (() -> Void)?
        
        var body: some View {
            Button(action: { action?() }) {
                VStack {
                    HStack {
                        HStack {
                            Image(systemName: icon)
                                .font(.system(size: 20))
                        }
                        .frame(width: 60, height: 60)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                        .buttonStyle(.plain)
                        VStack(alignment: .leading) {
                            Text(title)
                                .font(.system(size: 18))
                                .bold()
                                .padding(.bottom, 10)
                            Text("暂无消息")
                                .font(.system(size: 16))
                        }
                        .padding(.leading, 10)
                        Spacer()
                    }
                    .padding(.top, 25)
                    .padding(.leading, 5)
                    .padding(.trailing, 5)
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
    MyMessageView.List(icon: "text.bubble.fill", title: "标题")
}
