//
//  ChargingPileView+Build.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension ChargingPileView {
    
    static func buildContainer() -> some MviContainer<ChargingPileIntentProtocol, ChargingPileModelStateProtocol> {
        let model = ChargingPileModel()
        let intent = ChargingPileIntent(model: model)
        let container = MviContainer(
            intent: intent as ChargingPileIntentProtocol,
            model: model as ChargingPileModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return ChargingPileView(container: buildContainer())
    }
    
}
