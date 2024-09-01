//
//  MySettingAccountChangeIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

class MySettingAccountChangeIntent: MviIntentProtocol {
    private weak var modelAction: MySettingAccountChangeModelActionProtocol?
    private weak var modelRouter: MySettingAccountChangeModelRouterProtocol?
    @AppStorage("userNickname") private var userNickname: String = ""
    @AppStorage("userAvatar") private var userAvatar: String = ""
    
    init(model: MySettingAccountChangeModelActionProtocol & MySettingAccountChangeModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    /// 页面出现
    func viewOnAppear() {
        
    }
}

// MARK: Public

extension MySettingAccountChangeIntent: MySettingAccountChangeIntentProtocol {
}

// MARK: - Helper classes

extension MySettingAccountChangeTypes.Intent {
    struct ExternalData {}
}
