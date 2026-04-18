//
//  CommunityArticleView+Build.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

extension CommunityArticleView {
    
    static func buildContainer() -> some MviContainer<CommunityArticleIntentProtocol, CommunityArticleModelStateProtocol> {
        let model = CommunityArticleModel()
        let intent = CommunityArticleIntent(model: model)
        let container = MviContainer(
            intent: intent as CommunityArticleIntentProtocol,
            model: model as CommunityArticleModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return CommunityArticleView(container: buildContainer())
    }
    
}
