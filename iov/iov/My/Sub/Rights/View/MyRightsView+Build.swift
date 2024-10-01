//
//  MyRightsView+Build.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension MyRightsView {
    
    static func buildContainer() -> some MviContainer<MyRightsIntentProtocol, MyRightsModelStateProtocol> {
        let model = MyRightsModel()
        let intent = MyRightsIntent(model: model)
        let container = MviContainer(
            intent: intent as MyRightsIntentProtocol,
            model: model as MyRightsModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return MyRightsView(container: buildContainer())
    }
    
}
