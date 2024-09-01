//
//  MySettingView+Build.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension MySettingView {
    
    static func buildContainer() -> some MviContainer<MySettingIntentProtocol, MySettingModelStateProtocol> {
        let model = MySettingModel()
        let intent = MySettingIntent(model: model)
        let container = MviContainer(
            intent: intent as MySettingIntentProtocol,
            model: model as MySettingModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return MySettingView(container: buildContainer())
    }
    
}
