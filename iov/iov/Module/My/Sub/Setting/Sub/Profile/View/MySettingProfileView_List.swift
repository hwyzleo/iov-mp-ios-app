//
//  MySettingProfileView_List.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension MySettingProfileView {
    struct List: View {
        var title: String
        var value: String
        
        var body: some View {
            VStack {
                HStack {
                    Text(title)
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                    Spacer()
                    Text(value)
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                }
                .padding(.top, 25)
                Divider()
                    .padding(.top, 25)
            }
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    MySettingProfileView.List(title: "标题", value: "值")
}
