//
//  CommunityArticleTypes.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

enum CommunityArticleTypes {
    enum Intent {}
    enum Model {}
}

extension CommunityArticleTypes.Model {
    enum ContentState: Equatable {
        case loading
        case content(ExploreArticleDetailViewState)
        case unavailable
        case error(ExploreFailure)
    }
}
