//
//  ExploreServiceProtocol.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-012 on 2026/11/26.
//

import Foundation

enum ExplorePageLoadOutcome: Equatable {
    case loaded(page: ExplorePageViewState, etag: String?)
    case notModified
}

/// 探索页只读服务：Intent 只依赖该协议，测试注入可控替身。
protocol ExploreServiceProtocol {
    func loadChannels(completion: @escaping (Result<[ExploreChannelViewState], ExploreFailure>) -> Void)

    func loadCurrentPage(channelCode: String,
                         pageSize: Int,
                         ifNoneMatch: String?,
                         completion: @escaping (Result<ExplorePageLoadOutcome, ExploreFailure>) -> Void)

    func loadArticleFeed(channelCode: String,
                         componentId: String,
                         releaseId: String,
                         cursor: String?,
                         pageSize: Int,
                         completion: @escaping (Result<ExploreFeedPageViewState, ExploreFailure>) -> Void)

    func loadArticleDetail(articleId: String,
                           revisionId: String,
                           completion: @escaping (Result<ExploreArticleDetailViewState, ExploreFailure>) -> Void)

    func loadTopicDetail(topicId: String,
                         revisionId: String,
                         cursor: String?,
                         pageSize: Int,
                         completion: @escaping (Result<ExploreTopicDetailViewState, ExploreFailure>) -> Void)
}

