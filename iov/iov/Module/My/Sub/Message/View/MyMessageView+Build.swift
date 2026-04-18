//
//  MyMessageView+Build.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

extension MyMessageView {
    
    static func buildContainer() -> some MviContainer<MyMessageIntentProtocol, MyMessageModelStateProtocol> {
        let model = MyMessageModel()
        let intent = MyMessageIntent(model: model)
        let container = MviContainer(
            intent: intent as MyMessageIntentProtocol,
            model: model as MyMessageModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return MyMessageView(container: buildContainer())
    }
    
}
