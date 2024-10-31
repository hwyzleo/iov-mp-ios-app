//
//  VehicleView+Build.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension DealershipPage {
    
    static func buildContainer() -> some MviContainer<DealershipIntentProtocol, DealershipModelStateProtocol> {
        let model = DealershipModel()
        let intent = DealershipIntent(model: model)
        let container = MviContainer(
            intent: intent as DealershipIntentProtocol,
            model: model as DealershipModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return DealershipPage(container: buildContainer())
    }
    
}
