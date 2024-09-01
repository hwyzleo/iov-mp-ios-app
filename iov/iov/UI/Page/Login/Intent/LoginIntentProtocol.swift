//
//  LoginIntentProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

protocol LoginIntentProtocol {
    
    /// 点击退出登录页
    func onTapExitLoginIcon()
    /// 点击获取验证码
    func onTapSendVerifyCodeButton(countryRegionCode: String, mobile: String)
    /// 点击返回手机登录页
    func onTapBackMobileLoginIcon()
    /// 点击重发验证码
    func onTapResendVerifyCodeText(countryRegionCode: String, mobile: String)
    func onTapVerifyCodeLoginButton(countryRegionCode: String, mobile: String, verifyCode: String)
    
}
