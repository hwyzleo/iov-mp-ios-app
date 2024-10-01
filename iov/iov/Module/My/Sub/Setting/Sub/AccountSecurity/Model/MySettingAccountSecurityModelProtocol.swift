//
//  MySettingAccountSecurityModelProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

// MARK: - View State

protocol MySettingAccountSecurityModelStateProtocol {
    var contentState: MySettingAccountSecurityTypes.Model.ContentState { get }
    var loadingText: String { get }
    var routerSubject: MySettingAccountSecurityRouter.Subjects { get }
}

// MARK: - Intent Action

protocol MySettingAccountSecurityModelActionProtocol: MviModelActionProtocol {
    func displayLoading()
    func displayError(text: String)
}

// MARK: - Route

protocol MySettingAccountSecurityModelRouterProtocol: MviModelRouterProtocol {
}
