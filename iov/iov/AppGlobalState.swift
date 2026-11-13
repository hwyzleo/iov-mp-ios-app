//
//  AppGlobalState.swift
//  iov
//
//  Created by hwyz_leo on 2024/8/31.
//

import Foundation
import RxSwift

class AppGlobalState: ObservableObject {
    static let shared = AppGlobalState()
    
    @Published var selectedTab: Int = 0
    @Published var isFirstActive: Bool = false
    @Published var isSecondActive: Bool = false
    @Published var isMock: Bool = true
    /// 登录状态以 Keychain 会话为准（IOS-APP-DSN-CR-001 §5.5）
    @Published var isLogin: Bool = AuthEnvironment.shared.sessionRepository.hasSession()
    @Published var mockOrderState: OrderState = .WISHLIST
    @Published var tspUrl: String = "https://sgw.openiov.top"
    @Published var currentView: String = ""
    @Published var productId: String = ""
    @Published var parameters: [String: Any] = [:]
    @Published var needRefresh: Bool = false
    @Published var backRefresh: Bool = false
    @Published var needCloseOrderDetail: Bool = false
    @Published var needShowLoginPage: Bool = false
    @Published var appLocale: Locale = {
        if let language = UserDefaults.standard.string(forKey: "AppLanguage") {
            return Locale(identifier: language)
        }
        return .current
    }()
    
    private init() {}
    
    /// 云端上报的语言标识（单一来源，登录与切换语言共用）
    /// 支持：`zh-Hans`（简体）/ `zh-Hant`（繁体）/ `en`，其余回落 `en`
    /// （与本地资源回退行为一致，目前仅 zh-Hans / en 两套 lproj）
    static func serverLanguageCode(for localeIdentifier: String) -> String {
        let normalized = localeIdentifier
            .replacingOccurrences(of: "_", with: "-")
            .lowercased()
        guard normalized.hasPrefix("zh") else { return "en" }
        return isTraditionalChinese(normalized) ? "zh-Hant" : "zh-Hans"
    }

    /// 繁体判定：显式脚本（Hant）或港台澳地区（TW/HK/MO）
    private static let traditionalChineseMarkers = ["hant", "-tw", "-hk", "-mo"]

    private static func isTraditionalChinese(_ normalizedIdentifier: String) -> Bool {
        traditionalChineseMarkers.contains { normalizedIdentifier.contains($0) }
    }
    
    /// 当前应用语言对应的云端上报标识
    var serverLanguageCode: String {
        Self.serverLanguageCode(for: appLocale.identifier)
    }
    
    func setLanguage(_ language: String) {
        UserDefaults.standard.set(language, forKey: "AppLanguage")
        appLocale = Locale(identifier: language)
        
        // 云端同步语言设置（上报 zh-Hans / zh-Hant / en）
        TspApi.changeLanguage(language: Self.serverLanguageCode(for: language)) { _ in }
    }
    
    /// 根据可恢复的 Keychain 会话刷新登录状态
    func refreshLoginStatus() {
        let currentStatus = AuthEnvironment.shared.sessionRepository.hasSession()
        if isLogin != currentStatus {
            isLogin = currentStatus
        }
    }
    
    // MARK: - 统一认证状态事件（IOS-APP-DSN-CR-001 §5.4）
    
    /// 登录完成：进入已登录状态并退出登录流程（含根强制登录）
    func handleLoginCompleted() {
        runOnMain {
            self.isLogin = true
            self.needShowLoginPage = false
        }
    }
    
    /// 登录取消：返回未登录状态，受保护功能保持不可用
    func handleLoginCancelled() {
        runOnMain {
            self.isLogin = false
            self.needShowLoginPage = false
        }
    }
    
    /// 会话失效：清除凭证、进入强制登录，保留当前选中 Tab
    func handleSessionExpired() {
        AuthEnvironment.shared.sessionRepository.clearSession()
        runOnMain {
            self.isLogin = false
            self.needShowLoginPage = true
        }
        SafeLog.log("会话已失效，进入强制重新登录")
    }
    
    /// 退出登录完成
    func handleLogoutCompleted() {
        runOnMain {
            self.isLogin = false
            self.needShowLoginPage = false
        }
    }
    
    // MARK: - Private
    
    private func runOnMain(_ action: @escaping () -> Void) {
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.async(execute: action)
        }
    }
}
