//
//  CommunityTopicTypes.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

enum CommunityTopicTypes {
    enum Intent {}
    enum Model {}
}

extension CommunityTopicTypes.Model {
    enum ContentState: Equatable {
        case loading
        case content
        case error(ExploreFailure)
    }
}
