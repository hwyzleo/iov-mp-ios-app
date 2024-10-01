//
//  MySettingProfileModelProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

// MARK: - View State

protocol MySettingProfileModelStateProtocol {
    var contentState: MySettingProfileTypes.Model.ContentState { get }
    var loadingText: String { get }
    var avatar: String { get }
    var nickname: String { get }
    var gender: String { get }
    var birthday: Date { get }
    var area: String { get }
    var routerSubject: MySettingProfileRouter.Subjects { get }
}

// MARK: - Intent Action

protocol MySettingProfileModelActionProtocol: MviModelActionProtocol {
    func displayLoading()
    func displayProfile()
    func updateProfile(account: AccountInfo)
    /// 修改昵称
    func updateNickname(nickname: String)
    func updateAvatar(imageUrl: String)
    func displayError(text: String)
}

// MARK: - Route

protocol MySettingProfileModelRouterProtocol: MviModelRouterProtocol {
}
