//
//  MallView+Build.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension MallView {
    
    static func buildContainer() -> some MviContainer<MallIntentProtocol, MallModelStateProtocol> {
        let model = MallModel()
        let intent = MallIntent(model: model)
        let container = MviContainer(
            intent: intent as MallIntentProtocol,
            model: model as MallModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return MallView(container: buildContainer())
    }
    
}
