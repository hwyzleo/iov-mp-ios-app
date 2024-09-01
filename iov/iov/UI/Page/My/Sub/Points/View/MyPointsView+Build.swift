//
//  MyPointsView+Build.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension MyPointsView {
    
    static func buildContainer() -> some MviContainer<MyPointsIntentProtocol, MyPointsModelStateProtocol> {
        let model = MyPointsModel()
        let intent = MyPointsIntent(model: model)
        let container = MviContainer(
            intent: intent as MyPointsIntentProtocol,
            model: model as MyPointsModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return MyPointsView(container: buildContainer())
    }
    
}
