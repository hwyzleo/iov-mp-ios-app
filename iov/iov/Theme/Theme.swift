//
//  Theme.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

// 应用主题接口
public protocol AppThemeProtocol {}

// 应用颜色集接口
public protocol AppColorsProtocol {
    // 主题风格颜色
    var themeUi: Color { get set }
    // 背景颜色
    var background: Color { get set }
    // 主要文本颜色
    var mainText: Color { get set }
    // 次要文本颜色
    var secondaryText: Color { get set }
}

// 应用字体集接口
public protocol AppFontsProtocol {
    // 列表标题
    var listTitle: Font { get set }
}

// 应用主题
public struct AppTheme: AppThemeProtocol {
    public static var colors: AppColorsProtocol = LightAppColors() as AppColorsProtocol
    public static var fonts: AppFontsProtocol = AppFonts() as AppFontsProtocol
}

// 白天应用颜色集
struct LightAppColors : AppColorsProtocol {
    var themeUi: Color = Color.white
    var background: Color = Color.white
    var mainText: Color = Color(hex: 0x1A171B)
    var secondaryText: Color = Color(hex: 0x8E8E8E)
}

// 夜晚应用颜色集
struct DarkAppColors : AppColorsProtocol {
    var themeUi: Color = Color.black
    var background: Color = Color.black
    var mainText: Color = Color.white
    var secondaryText: Color = Color.gray
}

// 字体集
struct AppFonts : AppFontsProtocol {
    var listTitle: Font = .system(size: 16)
}
