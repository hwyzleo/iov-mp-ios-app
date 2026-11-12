//
//  MySettingProfileModelProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

// MARK: - View State

protocol MySettingProfileModelStateProtocol {
    var contentState: MySettingProfileTypes.Model.ContentState { get }
    var loadingText: String { get }
    var avatar: String { get }
    var nickname: String { get }
    var bio: String { get }
    var gender: String { get }
    var birthday: Date? { get }
    var area: String { get }
    var city: String { get }
    var avatarOperation: MySettingProfileTypes.Model.AvatarOperation { get }
    var avatarErrorMessage: String? { get }
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
    /// 开始头像上传（置 uploading，阻止重复触发）
    func beginAvatarUpload()
    /// 结束头像上传（回到 idle 并记录错误文案）
    func finishAvatarUpload(error: String?)
    func displayError(text: String)
}

// MARK: - Route

protocol MySettingProfileModelRouterProtocol: MviModelRouterProtocol {
}
