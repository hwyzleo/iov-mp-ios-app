//
//  MySettingProfileIntent.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

class MySettingProfileIntent: MviIntentProtocol {
    private weak var modelAction: MySettingProfileModelActionProtocol?
    private weak var modelRouter: MySettingProfileModelRouterProtocol?
    private let avatarService: AvatarUploading
    @AppStorage("userNickname") private var userNickname: String = ""
    @AppStorage("userAvatar") private var userAvatar: String = ""
    
    init(
        model: MySettingProfileModelActionProtocol & MySettingProfileModelRouterProtocol,
        avatarService: AvatarUploading = AvatarUploadService()
    ) {
        self.modelAction = model
        self.modelRouter = model
        self.avatarService = avatarService
    }

    deinit {
        // 离开页面：停止自动重试，不影响已生效头像（RD-003-7）
        avatarService.cancel()
    }
    
    /// 页面出现
    func viewOnAppear() {
        modelAction?.displayLoading()
        TspApi.getAccountInfo() { (result: Result<TspResponse<AccountInfo>, Error>) in
            switch result {
            case .success(let response):
                if response.isSuccess, let account = response.data {
                    self.userAvatar = account.avatarUrl ?? ""
                    UserManager.modifyAvatar(avatar: account.avatarUrl ?? "")
                    self.modelAction?.updateProfile(account: account)
                } else {
                    self.modelAction?.displayError(text: response.message ?? "异常")
                }
            case let .failure(error):
                print(error)
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
}

// MARK: Public

extension MySettingProfileIntent: MySettingProfileIntentProtocol {
    
    func onConfirmAvatarCrop(_ input: AvatarCropInput) {
        // 上传期间阻止重复触发（TC-003-9）
        guard !avatarService.isUploading else { return }
        modelAction?.beginAvatarUpload()
        avatarService.upload(input) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(avatar):
                // 只有确认成功才更新本地头像（RD-003-6）
                self.userAvatar = avatar.avatarUrl
                UserManager.modifyAvatar(avatar: avatar.avatarUrl)
                self.modelAction?.updateAvatar(imageUrl: avatar.avatarUrl)
            case let .failure(error):
                let message = AvatarUploadErrorMessage.text(for: error)
                self.modelAction?.finishAvatarUpload(error: message)
                if let message = message {
                    self.modelAction?.displayError(text: message)
                }
            }
        }
    }

    func onCancelAvatarCrop() {
        avatarService.cancel()
        modelAction?.finishAvatarUpload(error: nil)
    }

    func onTapNicknameSaveButton(nickname: String) {
        TspApi.updateProfile(nickname: nickname, gender: nil, birthday: nil, regionCode: nil, regionName: nil) { (result: Result<TspResponse<NoReply>, Error>) in
            switch result {
            case .success(let response):
                if(response.isSuccess) {
                    UserManager.modifyNickname(nickname: nickname)
                    self.modelRouter?.closeScreen()
                } else {
                    self.modelAction?.displayError(text: response.message ?? "异常")
                }
            case let .failure(error):
                print(error)
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    func onTapBioSaveButton(bio: String) {
        TspApi.updateProfile(nickname: nil, gender: nil, birthday: nil, regionCode: nil, regionName: nil) { (result: Result<TspResponse<NoReply>, Error>) in
            switch result {
            case .success(let response):
                if(response.isSuccess) {
                    self.modelRouter?.closeScreen()
                } else {
                    self.modelAction?.displayError(text: response.message ?? "异常")
                }
            case let .failure(error):
                print(error)
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    func onTapGenderSaveButton(gender: String) {
        var genderInt: Int? = nil
        switch gender {
        case "MALE": genderInt = 1
        case "FEMALE": genderInt = 2
        default: genderInt = 0
        }
        TspApi.updateProfile(nickname: nil, gender: genderInt, birthday: nil, regionCode: nil, regionName: nil) { (result: Result<TspResponse<NoReply>, Error>) in
            switch result {
            case .success(let response):
                if(response.isSuccess) {
                    self.modelRouter?.closeScreen()
                } else {
                    self.modelAction?.displayError(text: response.message ?? "异常")
                }
            case let .failure(error):
                print(error)
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    func onTapBirthdaySaveButton(date: Date) {
        TspApi.updateProfile(nickname: nil, gender: nil, birthday: dateToStr(date: date), regionCode: nil, regionName: nil) { (result: Result<TspResponse<NoReply>, Error>) in
            switch result {
            case .success(let response):
                if(response.isSuccess) {
                    TspApi.getAccountInfo() { (result: Result<TspResponse<AccountInfo>, Error>) in
                        switch result {
                        case .success(let response):
                            if(response.isSuccess) {
                                self.modelAction?.updateProfile(account: response.data!)
                            } else {
                                self.modelAction?.displayError(text: response.message ?? "异常")
                            }
                        case let .failure(error):
                            print(error)
                            self.modelAction?.displayError(text: "请求异常")
                        }
                    }
                } else {
                    self.modelAction?.displayError(text: response.message ?? "异常")
                }
            case let .failure(error):
                print(error)
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    func onTapCity(city: String) {
        modelAction?.displayLoading()
        let regionCode = "china"
        TspApi.updateProfile(nickname: nil, gender: nil, birthday: nil, regionCode: regionCode, regionName: city) { (result: Result<TspResponse<NoReply>, Error>) in
            switch result {
            case .success(let response):
                if(response.isSuccess) {
                    self.modelRouter?.closeScreen()
                } else {
                    self.modelAction?.displayError(text: response.message ?? "异常")
                }
            case let .failure(error):
                print(error)
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
}

// MARK: - Helper classes

extension MySettingProfileTypes.Intent {
    struct ExternalData {}
}
