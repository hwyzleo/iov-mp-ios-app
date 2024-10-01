//
//  SettingModelProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import Foundation

// MARK: - View State

protocol SettingModelStateProtocol {
    var contentState: SettingTypes.Model.ContentState { get }
    var routerSubject: SettingRouter.Subjects { get }
}

// MARK: - Intent Action

protocol SettingModelActionProtocol: MviModelActionProtocol {
    /// 用户登出
    func logout()
}

// MARK: - Route

protocol SettingModelRouterProtocol: MviModelRouterProtocol {
    /// 跳转至登录页
    func routeToLogin()
    /// 跳转至个人资料
    func routeToProfile()
    /// 跳转至主使用人变更
    func routeToAccountChange()
    /// 跳转至账号安全
    func routeToAccountSecurity()
    /// 跳转至账号绑定
    func routeToAccountBinding()
    /// 跳转至权限管理
    func routeToPrivillege()
    /// 跳转至用户协议
    func routeToUserProtocol()
    /// 跳转至社区公约
    func routeToCommunityConvention()
    /// 跳转至隐私协议
    func routeToPrivacyAgreement()
    /// 跳转至我的
    func routeToMy()
}
