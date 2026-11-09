//
//  LoginModelProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

// MARK: - View State

protocol LoginModelStateProtocol: AnyObject {
    /// 当前登录步骤（输入手机号 / 输入验证码）
    var step: LoginTypes.Model.LoginStep { get }
    /// 当前请求状态（空闲 / 发送中 / 重发中 / 登录中）
    var operation: LoginTypes.Model.LoginOperation { get }
    /// 已转换的用户可读错误
    var errorMessage: String? { get }
    /// 最近一次发送成功后的可重发时刻
    var resendAvailableAt: Date? { get }
    var mobile: String { get }
    var agree: Bool { get }
    var countryRegionCode: String { get }
    var routerSubject: LoginRouter.Subjects { get }

    /// 重发倒计时剩余秒数
    func resendRemainingSeconds(now: Date) -> Int
}

// MARK: - Intent Action

protocol LoginModelActionProtocol: MviModelActionProtocol {
    /// 更新手机号输入（格式化后）
    func updateMobile(_ mobile: String)
    /// 更新协议勾选
    func updateAgree(_ agree: Bool)
    /// 进入发送验证码处理中
    func beginSendingCode()
    /// 进入重新发送验证码处理中
    func beginResendingCode()
    /// 进入登录提交处理中
    func beginLoggingIn()
    /// 发送验证码成功：进入验证码步骤并设置可重发时刻
    func completeSendingCode(countryRegionCode: String, mobile: String, resendAvailableAt: Date)
    /// 重新发送成功：重启倒计时，保持当前步骤
    func completeResendingCode(resendAvailableAt: Date)
    /// 请求结束，回到空闲
    func completeOperation()
    /// 展示已本地化的错误，不改变当前步骤
    func showError(message: String)
    /// 路由至手机登录页
    func routeMobileLogin()
}

// MARK: - Route

protocol LoginModelRouterProtocol: MviModelRouterProtocol {
    /// 跳转至我的页面
    func routeToMy()
}
