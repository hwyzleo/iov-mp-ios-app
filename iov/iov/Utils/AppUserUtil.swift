//
//  AppUserUtil.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import Foundation

class AppUserUtil {
    
    static func isLogin() -> Bool {
        return UserDefaults.standard.bool(forKey: "isLogin")
    }
    
    static func login(login: LoginResponse) {
        UserDefaults.standard.set(true, forKey: "isLogin")
        UserDefaults.standard.set(login.token, forKey: "token")
        UserDefaults.standard.set(login.tokenExpires, forKey: "tokenExpires")
        UserDefaults.standard.set(login.refreshToken, forKey: "refreshToken")
        UserDefaults.standard.set(login.refreshTokenExpires, forKey: "refreshTokenExpires")
        UserDefaults.standard.set(login.mobile, forKey: "mobile")
        UserDefaults.standard.set(login.nickname, forKey: "nickname")
    }
    
    static func logout() {
        UserDefaults.standard.set(false, forKey: "isLogin")
    }
}
