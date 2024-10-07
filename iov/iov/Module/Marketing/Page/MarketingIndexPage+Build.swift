//
//  VehicleView+Build.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension MarketingIndexPage {
    
    static func buildContainer() -> some MviContainer<MarketingIndexIntentProtocol, MarketingIndexModelStateProtocol> {
        let model = MarketingIndexModel()
        let intent = MarketingIndexIntent(model: model)
        let container = MviContainer(
            intent: intent as MarketingIndexIntentProtocol,
            model: model as MarketingIndexModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return MarketingIndexPage(container: buildContainer())
    }
    
}
