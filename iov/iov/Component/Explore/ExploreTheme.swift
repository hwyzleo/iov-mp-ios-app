//
//  ExploreTheme.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-012 on 2026/11/27.
//

import SwiftUI

/// 探索页主题令牌，对齐《手机端配色与组件设计规范》：
/// - 暗夜机能表面阶梯、户外高对比文字阶梯
/// - 品牌荧光青、告警橙
/// - 8 / 16 / 24 圆角节奏
enum ExploreTheme {

    enum Hex {
        static let background = "#0B0E14"
        static let surface1 = "#141923"
        static let surface2 = "#1C2331"
        static let surface3 = "#242D3D"
        static let brand = "#00F0FF"
        static let brandPressed = "#00D5D8"
        static let textPrimary = "#FFFFFF"
        static let textSecondary = "#B0B8C6"
        static let textTertiary = "#6C768A"
        static let warning = "#F59E0B"
        static let danger = "#EF4444"
        static let electric = "#10E599"
        static let fuel = "#38BDF8"
    }

    enum Colors {
        /// 背景底色：深度冷黑
        static let background = Color(hex: Hex.background)
        /// 一级容器：主卡片与板块底色
        static let surface1 = Color(hex: Hex.surface1)
        /// 二级容器 / 可点按控件
        static let surface2 = Color(hex: Hex.surface2)
        /// 按下态 / 更高一级容器
        static let surface3 = Color(hex: Hex.surface3)

        /// 1px 细微光泽边框
        static let border = Color.white.opacity(0.08)

        static let brand = Color(hex: Hex.brand)
        static let brandPressed = Color(hex: Hex.brandPressed)

        static let textPrimary = Color(hex: Hex.textPrimary)
        static let textSecondary = Color(hex: Hex.textSecondary)
        static let textTertiary = Color(hex: Hex.textTertiary)

        static let warning = Color(hex: Hex.warning)
        static let danger = Color(hex: Hex.danger)
        static let electric = Color(hex: Hex.electric)
        static let fuel = Color(hex: Hex.fuel)
    }

    enum Radius {
        /// Badge / 小标签 / 多图小格
        static let badge: CGFloat = 8
        /// 功能按键 / 卡片
        static let card: CGFloat = 16
        /// 顶层面板
        static let panel: CGFloat = 24
    }

    enum Layout {
        static let margin: CGFloat = 16
        static let spacing: CGFloat = 20
        static let cardPadding: CGFloat = 16
        static let compactPadding: CGFloat = 8
        static let controlHeight: CGFloat = 48
        static let iconSize: CGFloat = 24
        static let heroHeight: CGFloat = 200
    }

    enum Fonts {
        static let pageTitle = Font.title2.weight(.bold)
        static let sectionTitle = Font.title3.weight(.bold)
        static let cardTitle = Font.title3.weight(.bold)
        static let body = Font.body
        static let secondary = Font.subheadline
        static let caption = Font.caption
        static let badge = Font.caption2.weight(.semibold)
    }
}

// MARK: - 表面与背景

private struct ExploreSurfaceModifier: ViewModifier {
    let radius: CGFloat
    let background: Color
    let padding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(ExploreTheme.Colors.border, lineWidth: 1)
            )
    }
}

extension View {
    /// 一级容器：主卡片底色 + 1px 光泽边框
    func exploreSurface(radius: CGFloat = ExploreTheme.Radius.card,
                        background: Color = ExploreTheme.Colors.surface1,
                        padding: CGFloat = ExploreTheme.Layout.cardPadding) -> some View {
        modifier(ExploreSurfaceModifier(radius: radius, background: background, padding: padding))
    }

    /// 探索页全屏背景（仅背景忽略安全区）
    func exploreScreenBackground() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(ExploreTheme.Colors.background.ignoresSafeArea())
    }
}

// MARK: - 按钮

/// 次级功能按钮：二级容器 + 品牌色文字 + 16px 圆角
struct ExploreSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ExploreTheme.Fonts.secondary.weight(.semibold))
            .foregroundColor(configuration.isPressed ? ExploreTheme.Colors.brandPressed : ExploreTheme.Colors.brand)
            .frame(maxWidth: .infinity)
            .frame(minHeight: ExploreTheme.Layout.controlHeight)
            .background(configuration.isPressed ? ExploreTheme.Colors.surface3 : ExploreTheme.Colors.surface2)
            .clipShape(RoundedRectangle(cornerRadius: ExploreTheme.Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ExploreTheme.Radius.card, style: .continuous)
                    .strokeBorder(ExploreTheme.Colors.border, lineWidth: 1)
            )
    }
}

/// 内容卡片按下态：轻微透明度反馈，不改变布局
struct ExploreCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.86 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
