//
//  AppGlobalState.swift
//  iov
//
//  Created by hwyz_leo on 2024/8/31.
//

import Foundation

class AppGlobalState: ObservableObject {
    static let shared = AppGlobalState()
    
    @Published var selectedTab: Int = 0
    @Published var isFirstActive: Bool = false
    @Published var isSecondActive: Bool = false
    @Published var isMock: Bool = true
    @Published var isLogin: Bool = UserManager.isLogin()
    @Published var mockOrderState: OrderState = .WISHLIST
    @Published var tspUrl: String = "https://sgw.rox-motor.com"
    @Published var currentView: String = ""
    @Published var productId: String = ""
    @Published var parameters: [String: Any] = [:]
    @Published var needRefresh: Bool = false
    @Published var backRefresh: Bool = false
    @Published var appLocale: Locale = {
        if let language = UserDefaults.standard.string(forKey: "AppLanguage") {
            return Locale(identifier: language)
        }
        return .current
    }()
    
    private init() {}
    
    func setLanguage(_ language: String) {
        UserDefaults.standard.set(language, forKey: "AppLanguage")
        appLocale = Locale(identifier: language)
        
        // 云端同步语言设置 (参数传 2 字缩写)
        let langCode = language.contains("zh") ? "zh" : "en"
        TspApi.changeLanguage(language: langCode) { _ in }
    }
    
    func refreshLoginStatus() {
        let currentStatus = UserManager.isLogin()
        if isLogin != currentStatus {
            isLogin = currentStatus
        }
    }
}
