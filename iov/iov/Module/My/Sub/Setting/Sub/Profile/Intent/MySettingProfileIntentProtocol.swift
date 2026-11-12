//
//  MySettingProfileIntentProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

protocol MySettingProfileIntentProtocol: MviIntentProtocol {
    /// 裁剪确认后上传头像（IOS-APP-DSN-CR-003）
    func onConfirmAvatarCrop(_ input: AvatarCropInput)
    /// 取消裁剪/结束上传（停止自动重试，不修改本地头像）
    func onCancelAvatarCrop()
    /// 点击保存昵称按钮
    func onTapNicknameSaveButton(nickname: String)
    /// 点击保存签名按钮
    func onTapBioSaveButton(bio: String)
    /// 点击保存性别按钮
    func onTapGenderSaveButton(gender: String)
    /// 点击生日保存按钮
    func onTapBirthdaySaveButton(date: Date)
    /// 点击市级行政区
    func onTapCity(city: String)
}
