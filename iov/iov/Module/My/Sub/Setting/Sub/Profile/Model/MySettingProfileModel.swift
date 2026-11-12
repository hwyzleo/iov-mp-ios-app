//
//  MySettingProfileModel.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

final class MySettingProfileModel: ObservableObject, MySettingProfileModelStateProtocol {
    @Published var contentState: MySettingProfileTypes.Model.ContentState = .content
    let loadingText = "Loading"
    @Published var avatar: String = ""
    @Published var nickname: String = ""
    @Published var bio: String = ""
    @Published var gender: String = "UNKNOWN"
    @Published var birthday: Date? = nil
    @Published var area: String = ""
    @Published var city: String = ""
    /// 头像上传状态（IOS-APP-DSN-CR-003 §4.2）
    @Published var avatarOperation: MySettingProfileTypes.Model.AvatarOperation = .idle
    /// 头像上传错误文案（错误提示复用 displayError 通道）
    @Published var avatarErrorMessage: String? = nil
    let routerSubject = MySettingProfileRouter.Subjects()
}

// MARK: - Action Protocol

extension MySettingProfileModel: MySettingProfileModelActionProtocol {
    func displayLoading() {
        contentState = .loading
    }
    func displayProfile() {
        contentState = .content
    }
    func updateProfile(account: AccountInfo) {
        self.avatar = account.avatarUrl ?? ""
        self.nickname = account.nickname ?? ""
        self.bio = account.description ?? ""
        switch account.gender {
        case 1: self.gender = "MALE"
        case 2: self.gender = "FEMALE"
        default: self.gender = "UNKNOWN"
        }
        self.birthday = nil
        if let birthdayArr = account.birthday, birthdayArr.count == 3 {
            var components = DateComponents()
            components.year = birthdayArr[0]
            components.month = birthdayArr[1]
            components.day = birthdayArr[2]
            if let birthday = Calendar.current.date(from: components) {
                self.birthday = birthday
            }
        }
        if let regionCode = account.regionCode {
            self.area = regionCode
        }
        if let regionName = account.regionName {
            self.city = regionName
        }
        contentState = .content
    }
    func updateNickname(nickname: String) {
        self.nickname = nickname
        contentState = .content
    }
    func updateAvatar(imageUrl: String) {
        self.avatar = imageUrl
        self.avatarOperation = .idle
        self.avatarErrorMessage = nil
        contentState = .content
    }
    func beginAvatarUpload() {
        avatarOperation = .uploading
        avatarErrorMessage = nil
    }
    func finishAvatarUpload(error: String?) {
        avatarOperation = .idle
        avatarErrorMessage = error
    }
    func displayError(text: String) {
        contentState = .error(text: text)
    }
}

// MARK: - Route Protocol

extension MySettingProfileModel: MySettingProfileModelRouterProtocol {
    func closeScreen() {
        routerSubject.close.send()
    }
    func routeToLogin() {
        
    }
}

extension MySettingProfileTypes.Model {
    enum ContentState {
        case loading
        case content
        case error(text: String)
    }

    /// 头像上传状态：上传期间保留表单，仅阻止重复触发
    enum AvatarOperation {
        case idle
        case uploading
    }
}
