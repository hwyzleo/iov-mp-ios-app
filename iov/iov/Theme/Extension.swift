//
//  Extension.swift
//  iov
//
//  Created by Gemini on 2026/3/14.
//

import SwiftUI

// MARK: - 通用 UI 修饰符
extension View {
    /// 应用标准卡片样式：深灰色背景、大圆角、统一内边距、无投影
    func appCardStyle(radius: CGFloat = AppTheme.layout.radiusLarge) -> some View {
        self.padding(AppTheme.layout.cardPadding)
            .background(AppTheme.colors.cardBackground)
            .cornerRadius(radius)
    }
    
    /// 全屏应用深青黑底色
    func appBackground() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.colors.background)
            .ignoresSafeArea()
    }
    
    /// 为视图指定特定位置的圆角
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - 辅助形状
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - 导航控制器扩展 (保持原有侧滑返回)
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
