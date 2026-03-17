//
//  RoundedCornerButton.swift
//  iov
//
//  Created by Gemini on 2026/3/14.
//

import SwiftUI

/// 工业级高圆角交互按钮
struct RoundedCornerButton: View {
    var name: String?
    var nameLocal: LocalizedStringKey?
    var color: Color
    var bgColor: Color
    var borderColor: Color
    var height: CGFloat
    var fontSize: CGFloat
    var action: (() -> Void)?
    
    init(
        name: String? = nil,
        nameLocal: LocalizedStringKey? = nil,
        color: Color = AppTheme.colors.fontPrimary,
        bgColor: Color = AppTheme.colors.brandMain,
        borderColor: Color = .clear,
        height: CGFloat = 56,
        fontSize: CGFloat = 16,
        action: (() -> Void)? = nil
    ) {
        self.name = name
        self.nameLocal = nameLocal
        self.color = color
        self.bgColor = bgColor
        self.borderColor = borderColor
        self.height = height
        self.fontSize = fontSize
        self.action = action
    }
    
    var body: some View {
        Button(action: { action?() }) {
            ZStack {
                Capsule()
                    .fill(bgColor)
                    .overlay(
                        Capsule()
                            .stroke(borderColor, lineWidth: 1)
                    )
                
                Group {
                    if let name = name {
                        Text(name)
                    } else if let nameLocal = nameLocal {
                        Text(nameLocal)
                    }
                }
                .font(.system(size: fontSize, weight: .bold)) // 按钮文字加粗
                .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .buttonStyle(PlainButtonStyle()) // 移除原生点击缩放，交给自定义
    }
}

#Preview {
    VStack {
        RoundedCornerButton(name: "激活状态")
        RoundedCornerButton(name: "辅助操作", bgColor: AppTheme.colors.cardBackground)
    }
    .padding()
    .background(AppTheme.colors.background)
}
