//
//  VehicleView+Build.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension VehicleOrderPage {
    
    static func buildContainer() -> some MviContainer<VehicleOrderIntentProtocol, VehicleOrderModelStateProtocol> {
        let model = VehicleOrderModel()
        let intent = VehicleOrderIntent(model: model)
        let container = MviContainer(
            intent: intent as VehicleOrderIntentProtocol,
            model: model as VehicleOrderModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return VehicleOrderPage(container: buildContainer())
    }
    
}
