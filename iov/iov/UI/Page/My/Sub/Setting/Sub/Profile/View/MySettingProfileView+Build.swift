//
//  MySettingProfileView+Build.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension MySettingProfileView {
    
    static func buildContainer() -> some MviContainer<MySettingProfileIntentProtocol, MySettingProfileModelStateProtocol> {
        let model = MySettingProfileModel()
        let intent = MySettingProfileIntent(model: model)
        let container = MviContainer(
            intent: intent as MySettingProfileIntentProtocol,
            model: model as MySettingProfileModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        let view = MySettingProfileView(container: buildContainer())
        return view
    }
    
}
