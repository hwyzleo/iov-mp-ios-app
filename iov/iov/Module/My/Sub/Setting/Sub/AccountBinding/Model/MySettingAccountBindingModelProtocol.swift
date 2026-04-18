//
//  MySettingAccountBindingModelProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

// MARK: - View State

protocol MySettingAccountBindingModelStateProtocol {
    var contentState: MySettingAccountBindingTypes.Model.ContentState { get }
    var loadingText: String { get }
    var routerSubject: MySettingAccountBindingRouter.Subjects { get }
}

// MARK: - Intent Action

protocol MySettingAccountBindingModelActionProtocol: MviModelActionProtocol {
    func displayLoading()
    func displayError(text: String)
}

// MARK: - Route

protocol MySettingAccountBindingModelRouterProtocol: MviModelRouterProtocol {
}
