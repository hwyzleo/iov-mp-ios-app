//
//  MyOrderView+Build.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

extension MyOrderView {
    
    static func buildContainer() -> some MviContainer<MyOrderIntentProtocol, MyOrderModelStateProtocol> {
        let model = MyOrderModel()
        let intent = MyOrderIntent(model: model)
        let container = MviContainer(
            intent: intent as MyOrderIntentProtocol,
            model: model as MyOrderModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return MyOrderView(container: buildContainer())
    }
    
}
