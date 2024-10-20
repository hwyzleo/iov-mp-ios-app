//
//  VehicleView+Build.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension VehicleModelConfigPage {
    
    static func buildContainer() -> some MviContainer<VehicleModelConfigIntentProtocol, VehicleModelConfigModelStateProtocol> {
        let model = VehicleModelConfigModel()
        let intent = VehicleModelConfigIntent(model: model)
        let container = MviContainer(
            intent: intent as VehicleModelConfigIntentProtocol,
            model: model as VehicleModelConfigModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return VehicleModelConfigPage(container: buildContainer())
    }
    
}
