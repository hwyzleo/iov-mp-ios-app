//
//  LoginIntentProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import Foundation

protocol LoginIntentProtocol {
    
    /// 点击退出登录页
    func onTapExitLoginIcon()
    /// 手机号输入变化（含格式化）
    func onChangeMobile(_ mobile: String)
    /// 切换协议勾选
    func onToggleAgree()
    /// 点击获取验证码
    func onTapSendVerifyCodeButton(countryRegionCode: String, mobile: String)
    /// 点击返回手机登录页
    func onTapBackMobileLoginIcon()
    /// 点击重发验证码
    func onTapResendVerifyCodeText(countryRegionCode: String, mobile: String)
    func onTapVerifyCodeLoginButton(countryRegionCode: String, mobile: String, verifyCode: String)
    
}

/// 登录完成/取消的统一状态发布方（生产实现为 AppGlobalState）
protocol LoginAuthPublishing: AnyObject {
    /// 是否由 Token 失效触发根页面强制登录
    var isForcedLogin: Bool { get }
    /// 登录成功，凭证已保存
    func handleLoginCompleted()
    /// 用户取消登录
    func handleLoginCancelled()
}

extension AppGlobalState: LoginAuthPublishing {
    var isForcedLogin: Bool {
        return needShowLoginPage
    }
}
