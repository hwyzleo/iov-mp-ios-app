//
//  SettingIntentProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

protocol SettingIntentProtocol : MviIntentProtocol {
    /// 点击登录
    func onTapLogin()
    /// 点击返回
    func onTapBack()
    /// 点击个人资料
    func onTapProfile()
    /// 点击主使用人变更
    func onTapAccountChange()
    /// 点击账号安全
    func onTapAccountSecurity()
    /// 点击账号绑定
    func onTapAccountBinding()
    /// 点击权限管理
    func onTapPrivillege()
    /// 点击用户协议
    func onTapUserProtocol()
    /// 点击社区公约
    func onTapCommunityConvention()
    /// 点击隐私协议
    func onTapPrivacyAgreement()
    /// 点击登出
    func onTapLogout()
}
