//
//  SettingView+Build.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension SettingView {
    
    static func buildContainer() -> some MviContainer<SettingIntentProtocol, SettingModelStateProtocol> {
        let model = SettingModel()
        let intent = SettingIntent(model: model)
        let container = MviContainer(
            intent: intent as SettingIntentProtocol,
            model: model as SettingModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return SettingView(container: buildContainer())
    }
    
}
