//
//  ModelVariantSelectionPage+Build.swift
//  iov
//
//  Created by iov on 2026/6/2.
//

import SwiftUI

extension ModelVariantSelectionPage {
    
    static func buildContainer(saleModelCode: String = "") -> some MviContainer<ModelVariantSelectionIntentProtocol, ModelVariantSelectionModelStateProtocol> {
        let model = ModelVariantSelectionModel()
        let intent = ModelVariantSelectionIntent(model: model, saleModelCode: saleModelCode)
        let container = MviContainer(
            intent: intent as ModelVariantSelectionIntentProtocol,
            model: model as ModelVariantSelectionModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build(saleModelCode: String = "") -> some View {
        return ModelVariantSelectionPage(container: buildContainer(saleModelCode: saleModelCode))
    }
    
}
