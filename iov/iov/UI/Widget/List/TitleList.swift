//
//  TitleList.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import Foundation
import SwiftUI

struct TitleList: View {
    var title: String = "标题"
    var iconName: String = ""
    var action: (() -> Void)?
    var body: some View {
        VStack {
            Button(action: {
                self.action?()
            }) {
                HStack {
                    if(iconName.count > 0) {
                        Image(iconName)
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding(.trailing, 10)
                    }
                    Text(title)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
                .modifier(BottomLineModifier())
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}

struct TitleList_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState()
    static var previews: some View {
        TitleList()
    }
}
