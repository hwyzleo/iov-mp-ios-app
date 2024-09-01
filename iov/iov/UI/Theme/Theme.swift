//
//  Theme.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

public protocol ThemeProtocol {}

/**
 * 主要配置App颜色、字体
 */
public struct Theme: ThemeProtocol {
    
    // 主色
    public static var mainColor: MainColorTheme {
        return MainColorTheme()
    }

    // 字体
    public static var titleFont: TitleFontTheme {
        return TitleFontTheme()
    }

}

// 主色
public struct MainColorTheme {

    // 主题颜色
    var mainColor: Color {
        return Color(hex: 0xFFFFFF)
    }
    
    // 主背景色
    var baseColor: Color {
        return Color(hex: 0xFFFFFF)
    }
    
    // 文本颜色
    var textColor: Color {
        return Color(hex: 0x1A171B)
    }
    
}

extension MainColorTheme {
    
}

// 字体
public struct TitleFontTheme {

}

extension TitleFontTheme {
    
}
