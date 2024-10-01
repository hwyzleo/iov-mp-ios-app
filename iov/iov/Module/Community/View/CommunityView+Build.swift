//
//  CommunityView+Build.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension CommunityView {
    
    static func buildContainer() -> some MviContainer<CommunityIntentProtocol, CommunityModelStateProtocol> {
        let model = CommunityModel()
        let intent = CommunityIntent(model: model)
        let container = MviContainer(
            intent: intent as CommunityIntentProtocol,
            model: model as CommunityModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return CommunityView(container: buildContainer())
    }
    
}
