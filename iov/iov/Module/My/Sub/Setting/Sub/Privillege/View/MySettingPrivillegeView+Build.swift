//
//  MySettingPrivillegeView+Build.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension MySettingPrivillegeView {
    
    static func buildContainer() -> some MviContainer<MySettingPrivillegeIntentProtocol, MySettingPrivillegeModelStateProtocol> {
        let model = MySettingPrivillegeModel()
        let intent = MySettingPrivillegeIntent(model: model)
        let container = MviContainer(
            intent: intent as MySettingPrivillegeIntentProtocol,
            model: model as MySettingPrivillegeModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        let view = MySettingPrivillegeView(container: buildContainer())
        return view
    }
    
}
