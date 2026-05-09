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
    @Published var isLogin: Bool = UserManager.isLogin()
    @Published var mockOrderState: OrderState = .WISHLIST
    @Published var tspUrl: String = "https://sgw.openiov.top"
    @Published var currentView: String = ""
    @Published var productId: String = ""
    @Published var parameters: [String: Any] = [:]
    @Published var needRefresh: Bool = false
    @Published var backRefresh: Bool = false
    @Published var needShowLoginPage: Bool = false
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
    
    func handleTokenExpired() {
        DispatchQueue.main.async {
            self.isLogin = false
            self.needShowLoginPage = true
            self.selectedTab = 0
            print("Refresh token失效，即将跳转登录页")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                let realm = RealmManager.user.realm
                try realm.write {
                    realm.delete(realm.objects(UserManager.self))
                    realm.refresh()
                }
                print("已清除本地登录态")
            } catch {
                print("清除登录态失败：\(error)")
            }
        }
    }
}
