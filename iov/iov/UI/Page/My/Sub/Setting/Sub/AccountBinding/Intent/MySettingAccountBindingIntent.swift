//
//  MySettingAccountBindingIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

class MySettingAccountBindingIntent: MviIntentProtocol {
    private weak var modelAction: MySettingAccountBindingModelActionProtocol?
    private weak var modelRouter: MySettingAccountBindingModelRouterProtocol?
    
    init(model: MySettingAccountBindingModelActionProtocol & MySettingAccountBindingModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    func viewOnAppear() {}
}

// MARK: Public

extension MySettingAccountBindingIntent: MySettingAccountBindingIntentProtocol {
}

// MARK: - Helper classes

extension MySettingAccountBindingTypes.Intent {
    struct ExternalData {}
}
