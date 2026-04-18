//
//  MySettingPrivillegeModelProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

// MARK: - View State

protocol MySettingPrivillegeModelStateProtocol {
    var contentState: MySettingPrivillegeTypes.Model.ContentState { get }
    var loadingText: String { get }
    var routerSubject: MySettingPrivillegeRouter.Subjects { get }
}

// MARK: - Intent Action

protocol MySettingPrivillegeModelActionProtocol: MviModelActionProtocol {
    func displayLoading()
    func displayError(text: String)
}

// MARK: - Route

protocol MySettingPrivillegeModelRouterProtocol: MviModelRouterProtocol {
}
