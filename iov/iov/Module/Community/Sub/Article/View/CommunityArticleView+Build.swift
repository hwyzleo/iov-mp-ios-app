//
//  CommunityArticleView+Build.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

extension CommunityArticleView {

    static func buildContainer(articleId: String,
                               revisionId: String,
                               service: ExploreServiceProtocol = RealExploreService()) -> some MviContainer<CommunityArticleIntentProtocol, CommunityArticleModelStateProtocol> {
        let model = CommunityArticleModel()
        let intent = CommunityArticleIntent(model: model,
                                            articleId: articleId,
                                            revisionId: revisionId,
                                            service: service)
        let container = MviContainer(
            intent: intent as CommunityArticleIntentProtocol,
            model: model as CommunityArticleModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }

    static func build(articleId: String,
                      revisionId: String,
                      service: ExploreServiceProtocol = RealExploreService()) -> some View {
        return CommunityArticleView(container: buildContainer(articleId: articleId,
                                                              revisionId: revisionId,
                                                              service: service))
    }

    /// 旧话题页的兼容入口：缺少修订标识，按不可用处理，不读取全局 `id`
    static func build() -> some View {
        return build(articleId: "", revisionId: "")
    }
}
