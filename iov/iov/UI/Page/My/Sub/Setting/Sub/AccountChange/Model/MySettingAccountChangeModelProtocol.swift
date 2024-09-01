//
//  MySettingAccountChangeModelProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

// MARK: - View State

protocol MySettingAccountChangeModelStateProtocol {
    var contentState: MySettingAccountChangeTypes.Model.ContentState { get }
    var loadingText: String { get }
    var routerSubject: MySettingAccountChangeRouter.Subjects { get }
}

// MARK: - Intent Action

protocol MySettingAccountChangeModelActionProtocol: MviModelActionProtocol {
    func displayLoading()
    func displayError(text: String)
}

// MARK: - Route

protocol MySettingAccountChangeModelRouterProtocol: MviModelRouterProtocol {
}
