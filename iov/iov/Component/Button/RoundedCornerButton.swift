//
//  RoundedCornerButton.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/2.
//

import SwiftUI

// 圆角按钮
struct RoundedCornerButton: View {
    var name: String?
    var nameLocal: LocalizedStringKey?
    var color: Color = AppTheme.colors.fontPrimary
    var bgColor: Color = Color.white
    var action: (() -> Void)?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(bgColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 1)
                )
            if(name != nil) {
                Text(name!)
                    .font(.system(size: 15))
                    .foregroundColor(color)
            } else if(nameLocal != nil) {
                Text(nameLocal!)
                    .font(.system(size: 15))
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .contentShape(Rectangle())
        .onTapGesture {
            action?()
        }
    }
}

#Preview {
    RoundedCornerButton(name: "按钮")
}
