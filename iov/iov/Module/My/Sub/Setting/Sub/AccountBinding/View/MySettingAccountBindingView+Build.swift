//
//  MySettingAccountBindingView+Build.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension MySettingAccountBindingView {
    
    static func buildContainer() -> some MviContainer<MySettingAccountBindingIntentProtocol, MySettingAccountBindingModelStateProtocol> {
        let model = MySettingAccountBindingModel()
        let intent = MySettingAccountBindingIntent(model: model)
        let container = MviContainer(
            intent: intent as MySettingAccountBindingIntentProtocol,
            model: model as MySettingAccountBindingModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        let view = MySettingAccountBindingView(container: buildContainer())
        return view
    }
    
}
