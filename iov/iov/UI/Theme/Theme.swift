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
    public static var color: MainColorTheme {
        return MainColorTheme()
    }

    // 字体
    public static var font: MainFontTheme {
        return MainFontTheme()
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
    var mainText: Color {
        return Color(hex: 0x1A171B)
    }
    
    // 次要文本颜色
    var secondaryText: Color {
        return Color(hex: 0x8E8E8E)
    }
    
}

extension MainColorTheme {
    
}

// 字体
public struct MainFontTheme {
    
    // 列表标题字体
    var listTitle: Font {
        return .system(size: 16)
    }
}

extension MainFontTheme {
    
}
