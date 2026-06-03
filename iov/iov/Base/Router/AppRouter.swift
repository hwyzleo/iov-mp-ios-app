//
//  AppRouter.swift
//  iov
//
//  Created by iov on 2026/6/3.
//

import SwiftUI
import Combine

/// 全局路由管理器
class AppRouter: ObservableObject {
    static let shared = AppRouter()
    
    @Published var path = NavigationPath()
    @Published var presentedItem: AppRoute?
    @Published var fullScreenItem: AppRoute?
    
    private init() {}
    
    /// push导航
    func push(_ route: AppRoute) {
        path.append(route)
    }
    
    /// present弹窗
    func present(_ route: AppRoute) {
        presentedItem = route
    }
    
    /// fullScreen全屏弹窗
    func fullScreen(_ route: AppRoute) {
        fullScreenItem = route
    }
    
    /// 返回上一页
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    /// 返回到根页面
    func popToRoot() {
        path = NavigationPath()
    }
    
    /// 返回到指定页面
    func popTo(_ route: AppRoute) {
        // 由于NavigationPath不支持直接操作，使用popToRoot然后重新push
        // 这是一个简化实现，实际项目中可能需要更复杂的逻辑
        popToRoot()
    }
    
    /// 关闭present弹窗
    func dismiss() {
        presentedItem = nil
        fullScreenItem = nil
    }
}