//
//  MyInviteView+Build.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension MyInviteView {
    
    static func buildContainer() -> some MviContainer<MyInviteIntentProtocol, MyInviteModelStateProtocol> {
        let model = MyInviteModel()
        let intent = MyInviteIntent(model: model)
        let container = MviContainer(
            intent: intent as MyInviteIntentProtocol,
            model: model as MyInviteModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return MyInviteView(container: buildContainer())
    }
    
}
