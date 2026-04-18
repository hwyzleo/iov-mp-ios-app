//
//  ServiceView+Build.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

extension ServicePage {
    
    static func buildContainer() -> some MviContainer<ServiceIntentProtocol, ServiceModelStateProtocol> {
        let model = ServiceModel()
        let intent = ServiceIntent(model: model)
        let container = MviContainer(
            intent: intent as ServiceIntentProtocol,
            model: model as ServiceModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return ServicePage(container: buildContainer())
    }
    
}
