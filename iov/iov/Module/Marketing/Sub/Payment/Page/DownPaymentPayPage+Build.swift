//
//  DownPaymentPayPage+Build.swift
//  iov
//
//  Created on 2026/5/16.
//

import SwiftUI

extension DownPaymentPayPage {
    
    static func buildContainer() -> some MviContainer<DownPaymentPayIntentProtocol, DownPaymentPayModelStateProtocol> {
        let model = DownPaymentPayModel()
        let intent = DownPaymentPayIntent(model: model)
        let container = MviContainer(
            intent: intent as DownPaymentPayIntentProtocol,
            model: model as any DownPaymentPayModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return DownPaymentPayPage(container: buildContainer())
    }
    
}