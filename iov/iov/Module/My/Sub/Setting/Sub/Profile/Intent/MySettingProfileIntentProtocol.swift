//
//  MySettingProfileIntentProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

protocol MySettingProfileIntentProtocol: MviIntentProtocol {
    func onSelectAvatar(image: UIImage)
    /// 点击保存昵称按钮
    func onTapNicknameSaveButton(nickname: String)
    /// 点击保存性别按钮
    func onTapGenderSaveButton(gender: String)
    /// 点击生日保存按钮
    func onTapBirthdaySaveButton(date: Date)
    /// 点击市级行政区
    func onTapCity(city: String)
}
