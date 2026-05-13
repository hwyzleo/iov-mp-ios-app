//
//  EarnestMoneyPayPage+Build.swift
//  iov
//
//  Created on 2026/5/13.
//

import SwiftUI

extension EarnestMoneyPayPage {
    
    static func buildContainer() -> some MviContainer<EarnestMoneyPayIntentProtocol, EarnestMoneyPayModelStateProtocol> {
        let model = EarnestMoneyPayModel()
        let intent = EarnestMoneyPayIntent(model: model)
        let container = MviContainer(
            intent: intent as EarnestMoneyPayIntentProtocol,
            model: model as EarnestMoneyPayModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return EarnestMoneyPayPage(container: buildContainer())
    }
    
}