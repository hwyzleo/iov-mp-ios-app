//
//  Theme.swift
//  iov
//
//  Created by Gemini on 2026/3/14.
//

import SwiftUI

// MARK: - 颜色协议增强
public protocol AppColorsProtocol {
    var background: Color { get }      // 基础底色：深青黑色 (#0D1117)
    var cardBackground: Color { get }  // 卡片背景：深灰色 (#1C212B)
    var brandMain: Color { get }       // 品牌主色：极光蓝
    var fontPrimary: Color { get }     // 一级标题：纯白 (#FFFFFF)
    var fontSecondary: Color { get }   // 二级正文：浅灰 (#A0A0A0)
    var fontTertiary: Color { get }    // 弱辅助字：深灰 (#666666)
}

// MARK: - 布局规范协议
public protocol AppLayoutProtocol {
    var margin: CGFloat { get }        // 页面外边距 (32pt)
    var spacing: CGFloat { get }       // 组件垂直间距 (24pt)
    var cardPadding: CGFloat { get }   // 卡片内部 Padding (32pt)
    
    var radiusLarge: CGFloat { get }   // 大容器圆角 (40pt)
    var radiusMedium: CGFloat { get }  // 中型构件圆角 (24pt)
    var radiusSmall: CGFloat { get }   // 小构件圆角 (12pt)
}

// MARK: - 字体规范协议
public protocol AppFontsProtocol {
    var bigTitle: Font { get }         // 大标题 (32pt Bold)
    var title1: Font { get }           // 一级标题 (28pt Medium)
    var body: Font { get }             // 正文内容 (24pt Regular)
    var subtext: Font { get }          // 辅助标签 (20pt Regular)
}

// MARK: - 默认实现
public struct AppTheme {
    public static var colors: AppColorsProtocol = DefaultColors()
    public static var layout: AppLayoutProtocol = DefaultLayout()
    public static var fonts: AppFontsProtocol = DefaultFonts()
}

struct DefaultColors: AppColorsProtocol {
    let background = Color(hex: "#0D1117")
    let cardBackground = Color(hex: "#1C212B")
    let brandMain = Color(hex: "#00E5FF") // 极光蓝/冷青色
    let fontPrimary = Color(hex: "#FFFFFF")
    let fontSecondary = Color(hex: "#A0A0A0")
    let fontTertiary = Color(hex: "#666666")
}

struct DefaultLayout: AppLayoutProtocol {
    let margin: CGFloat = 16
    let spacing: CGFloat = 16
    let cardPadding: CGFloat = 16
    
    let radiusLarge: CGFloat = 20
    let radiusMedium: CGFloat = 12
    let radiusSmall: CGFloat = 8
}

struct DefaultFonts: AppFontsProtocol {
    let bigTitle = Font.system(size: 24, weight: .bold)
    let title1 = Font.system(size: 18, weight: .bold)
    let body = Font.system(size: 15, weight: .regular)
    let subtext = Font.system(size: 12, weight: .regular)
}

// MARK: - Color 扩展支持 Hex 字符串
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
