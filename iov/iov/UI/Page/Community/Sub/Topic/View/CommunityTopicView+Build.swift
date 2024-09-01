//
//  CommunityTopicView+Build.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension CommunityTopicView {
    
    static func buildContainer() -> some MviContainer<CommunityTopicIntentProtocol, CommunityTopicModelStateProtocol> {
        let model = CommunityTopicModel()
        let intent = CommunityTopicIntent(model: model)
        let container = MviContainer(
            intent: intent as CommunityTopicIntentProtocol,
            model: model as CommunityTopicModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return CommunityTopicView(container: buildContainer())
    }
    
}
