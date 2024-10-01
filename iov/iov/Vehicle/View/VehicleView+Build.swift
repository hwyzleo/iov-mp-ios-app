//
//  VehicleView+Build.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension VehicleView {
    
    static func buildContainer() -> some MviContainer<VehicleIntentProtocol, VehicleModelStateProtocol> {
        let model = VehicleModel()
        let intent = VehicleIntent(model: model)
        let container = MviContainer(
            intent: intent as VehicleIntentProtocol,
            model: model as VehicleModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return VehicleView(container: buildContainer())
    }
    
}
