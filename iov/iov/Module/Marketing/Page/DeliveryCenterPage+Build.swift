//
//  VehicleView+Build.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension DeliveryCenterPage {
    
    static func buildContainer() -> some MviContainer<DeliveryCenterIntentProtocol, DeliveryCenterModelStateProtocol> {
        let model = DeliveryCenterModel()
        let intent = DeliveryCenterIntent(model: model)
        let container = MviContainer(
            intent: intent as DeliveryCenterIntentProtocol,
            model: model as DeliveryCenterModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return DeliveryCenterPage(container: buildContainer())
    }
    
}
