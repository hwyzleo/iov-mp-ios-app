//
//  LoginModelProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

// MARK: - View State

protocol LoginModelStateProtocol {
    var contentState: LoginTypes.Model.ContentState { get }
    var mobile: String { get }
    var agree: Bool { get }
    var countryRegionCode: String { get }
    var routerSubject: LoginRouter.Subjects { get }
}

// MARK: - Intent Action

protocol LoginModelActionProtocol: MviModelActionProtocol {
    /// 路由至验证码输入页
    func routeInputVerify(countryRegionCode: String, mobile: String)
    /// 路由至手机登录页
    func routeMobileLogin()
    func displayError(text: String)
}

// MARK: - Route

protocol LoginModelRouterProtocol: MviModelRouterProtocol {
    /// 跳转至我的页面
    func routeToMy()
}
