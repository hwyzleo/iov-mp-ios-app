//
//  MySettingAccountSecurityIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

class MySettingAccountSecurityIntent: MviIntentProtocol {
    private weak var modelAction: MySettingAccountSecurityModelActionProtocol?
    private weak var modelRouter: MySettingAccountSecurityModelRouterProtocol?
    @AppStorage("userNickname") private var userNickname: String = ""
    @AppStorage("userAvatar") private var userAvatar: String = ""
    
    init(model: MySettingAccountSecurityModelActionProtocol & MySettingAccountSecurityModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    /// 页面出现
    func viewOnAppear() {
        
    }
}

// MARK: Public

extension MySettingAccountSecurityIntent: MySettingAccountSecurityIntentProtocol {
}

// MARK: - Helper classes

extension MySettingAccountSecurityTypes.Intent {
    struct ExternalData {}
}
