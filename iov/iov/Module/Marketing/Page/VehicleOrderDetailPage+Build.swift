//
//  VehicleView+Build.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension VehicleOrderDetailPage {
    
    static func buildContainer() -> some MviContainer<VehicleOrderDetailIntentProtocol, VehicleOrderDetailModelStateProtocol> {
        let model = VehicleOrderDetailModel()
        let intent = VehicleOrderDetailIntent(model: model)
        let container = MviContainer(
            intent: intent as VehicleOrderDetailIntentProtocol,
            model: model as VehicleOrderDetailModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return VehicleOrderDetailPage(container: buildContainer())
    }
    
}
