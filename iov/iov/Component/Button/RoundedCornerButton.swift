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
    var borderColor: Color = Color.gray
    var height: CGFloat = 40
    var fontSize: CGFloat = 15
    var action: (() -> Void)?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(bgColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(borderColor, lineWidth: 1)
                )
            if(name != nil) {
                Text(name!)
                    .font(.system(size: fontSize))
                    .foregroundColor(color)
            } else if(nameLocal != nil) {
                Text(nameLocal!)
                    .font(.system(size: fontSize))
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .contentShape(Rectangle())
        .onTapGesture {
            action?()
        }
    }
}

#Preview {
    RoundedCornerButton(name: "按钮")
}
