//
//  MockIndicatorModifier.swift
//  iov
//
//  Created by Gemini on 2026/3/14.
//

import SwiftUI

/// 当处于 Mock 模式时，在页面右上角显示一个微小的橙色标签
struct MockIndicatorModifier: ViewModifier {
    @ObservedObject var globalState = AppGlobalState.shared
    
    func body(content: Content) -> some View {
        ZStack(alignment: .topTrailing) {
            content
            
            if globalState.isMock {
                Text("MOCK")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
                    .padding(2)
                    .padding(.horizontal, 4)
                    .background(Color.orange.opacity(0.8))
                    .cornerRadius(4)
                    .padding(.top, 50) // 避开刘海屏/状态栏
                    .padding(.trailing, 10)
                    .allowsHitTesting(false) // 确保不影响下方按钮的点击
                    .transition(.opacity)
            }
        }
    }
}

extension View {
    /// 应用 Mock 环境提示标签
    func showMockIndicator() -> some View {
        self.modifier(MockIndicatorModifier())
    }
}
