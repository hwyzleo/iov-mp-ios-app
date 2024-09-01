//
//  CommunitySubjectView+Build.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension CommunitySubjectView {
    
    static func buildContainer() -> some MviContainer<CommunitySubjectIntentProtocol, CommunitySubjectModelStateProtocol> {
        let model = CommunitySubjectModel()
        let intent = CommunitySubjectIntent(model: model)
        let container = MviContainer(
            intent: intent as CommunitySubjectIntentProtocol,
            model: model as CommunitySubjectModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return CommunitySubjectView(container: buildContainer())
    }
    
}
