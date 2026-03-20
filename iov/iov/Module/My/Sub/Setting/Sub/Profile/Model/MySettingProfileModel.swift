//
//  MySettingProfileModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
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
        self.avatar = account.avatar ?? ""
        self.nickname = account.nickname
        self.bio = account.bio ?? ""
        self.gender = account.gender.isEmpty ? "UNKNOWN" : account.gender
        self.birthday = nil
        if let birthdayStr = account.birthday, !birthdayStr.isEmpty {
            if let birthday = strToDate(str: birthdayStr) {
                self.birthday = birthday
            }
        }
        if let area = account.area {
            self.area = area
        }
        if let city = account.city {
            self.city = city
        }
        contentState = .content
    }
    func updateNickname(nickname: String) {
        self.nickname = nickname
        contentState = .content
    }
    func updateAvatar(imageUrl: String) {
        self.avatar = imageUrl
        contentState = .content
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
}
