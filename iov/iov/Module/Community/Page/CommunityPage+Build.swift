//
//  CommunityView+Build.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

extension CommunityPage {

    static func buildContainer(service: ExploreServiceProtocol = RealExploreService()) -> some MviContainer<CommunityIntentProtocol, CommunityModelStateProtocol> {
        let model = CommunityModel()
        let intent = CommunityIntent(model: model, service: service)
        let container = MviContainer(
            intent: intent as CommunityIntentProtocol,
            model: model as CommunityModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }

    static func build(service: ExploreServiceProtocol = RealExploreService()) -> some View {
        return CommunityPage(container: buildContainer(service: service))
    }

}
