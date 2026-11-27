//
//  CommunityTopicView+Build.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

extension CommunityTopicView {

    static func buildContainer(topicId: String,
                               revisionId: String,
                               service: ExploreServiceProtocol = RealExploreService()) -> some MviContainer<CommunityTopicIntentProtocol, CommunityTopicModelStateProtocol> {
        let model = CommunityTopicModel()
        let intent = CommunityTopicIntent(model: model,
                                          topicId: topicId,
                                          revisionId: revisionId,
                                          service: service)
        let container = MviContainer(
            intent: intent as CommunityTopicIntentProtocol,
            model: model as CommunityTopicModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }

    static func build(topicId: String,
                      revisionId: String,
                      service: ExploreServiceProtocol = RealExploreService()) -> some View {
        return CommunityTopicView(container: buildContainer(topicId: topicId,
                                                            revisionId: revisionId,
                                                            service: service))
    }

    /// 旧话题入口的兼容方法：缺少修订标识，按不可用处理
    static func build() -> some View {
        return build(topicId: "", revisionId: "")
    }
}
