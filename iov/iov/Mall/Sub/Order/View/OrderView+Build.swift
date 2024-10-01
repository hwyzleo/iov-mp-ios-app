//
//  OrderView+Build.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension OrderView {
    
    static func buildContainer() -> some MviContainer<OrderIntentProtocol, OrderModelStateProtocol> {
        let model = OrderModel()
        let intent = OrderIntent(model: model)
        let container = MviContainer(
            intent: intent as OrderIntentProtocol,
            model: model as OrderModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return OrderView(container: buildContainer())
    }
    
}
