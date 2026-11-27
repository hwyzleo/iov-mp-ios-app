//
//  RealExploreService.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-012 on 2026/11/26.
//

import Foundation
import Alamofire

/// 生产实现：复用共享网络层，解释 HTTP 200 / 304 与 `TspResponse` 业务码。
final class RealExploreService: ExploreServiceProtocol {

    static let defaultPageSize = 10

    // MARK: - 频道

    func loadChannels(completion: @escaping (Result<[ExploreChannelViewState], ExploreFailure>) -> Void) {
        TspApi.getExploreChannels { result in
            switch result {
            case let .failure(error):
                completion(.failure(Self.mapTransportError(error)))
            case let .success(response):
                guard response.isSuccess else {
                    completion(.failure(Self.mapBusinessCode(response.code)))
                    return
                }
                guard let data = response.data else {
                    completion(.failure(.invalidResponse))
                    return
                }
                completion(.success(ExploreViewStateMapper.mapChannels(data)))
            }
        }
    }

    // MARK: - 当前页面

    func loadCurrentPage(channelCode: String,
                         pageSize: Int,
                         ifNoneMatch: String?,
                         completion: @escaping (Result<ExplorePageLoadOutcome, ExploreFailure>) -> Void) {
        guard !channelCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(.failure(.invalidArgument))
            return
        }
        TspApi.getExploreCurrentPage(channelCode: channelCode,
                                     pageSize: pageSize,
                                     ifNoneMatch: ifNoneMatch) { result in
            switch result {
            case let .failure(error):
                completion(.failure(Self.mapTransportError(error)))
            case let .success(outcome):
                switch outcome {
                case .notModified:
                    completion(.success(.notModified))
                case let .loaded(response, etag):
                    guard response.isSuccess else {
                        completion(.failure(Self.mapBusinessCode(response.code)))
                        return
                    }
                    guard let dto = response.data else {
                        completion(.failure(.invalidResponse))
                        return
                    }
                    switch ExploreViewStateMapper.mapPage(dto) {
                    case let .failure(failure):
                        completion(.failure(failure))
                    case let .success(page):
                        guard page.channelCode == channelCode else {
                            // 过期或错配页面不得覆盖当前频道
                            completion(.failure(.invalidResponse))
                            return
                        }
                        completion(.success(.loaded(page: page, etag: etag)))
                    }
                }
            }
        }
    }

    // MARK: - 文章流

    func loadArticleFeed(channelCode: String,
                         componentId: String,
                         releaseId: String,
                         cursor: String?,
                         pageSize: Int,
                         completion: @escaping (Result<ExploreFeedPageViewState, ExploreFailure>) -> Void) {
        guard !channelCode.isEmpty, !componentId.isEmpty, !releaseId.isEmpty else {
            completion(.failure(.invalidArgument))
            return
        }
        TspApi.getExploreArticleFeed(channelCode: channelCode,
                                     componentId: componentId,
                                     releaseId: releaseId,
                                     cursor: cursor,
                                     pageSize: pageSize) { result in
            switch result {
            case let .failure(error):
                completion(.failure(Self.mapTransportError(error)))
            case let .success(response):
                guard response.isSuccess else {
                    completion(.failure(Self.mapBusinessCode(response.code)))
                    return
                }
                guard let dto = response.data else {
                    completion(.failure(.invalidResponse))
                    return
                }
                completion(ExploreViewStateMapper.mapFeedPage(dto,
                                                               expectedReleaseId: releaseId,
                                                               expectedComponentId: componentId))
            }
        }
    }

    // MARK: - 文章详情

    func loadArticleDetail(articleId: String,
                           revisionId: String,
                           completion: @escaping (Result<ExploreArticleDetailViewState, ExploreFailure>) -> Void) {
        guard !articleId.isEmpty, !revisionId.isEmpty else {
            completion(.failure(.invalidArgument))
            return
        }
        TspApi.getExploreArticleDetail(articleId: articleId, revisionId: revisionId) { result in
            switch result {
            case let .failure(error):
                completion(.failure(Self.mapTransportError(error)))
            case let .success(response):
                guard response.isSuccess else {
                    completion(.failure(Self.mapBusinessCode(response.code)))
                    return
                }
                guard let dto = response.data else {
                    completion(.failure(.invalidResponse))
                    return
                }
                completion(ExploreViewStateMapper.mapArticleDetail(dto,
                                                                    expectedArticleId: articleId,
                                                                    expectedRevisionId: revisionId))
            }
        }
    }

    // MARK: - 专题详情

    func loadTopicDetail(topicId: String,
                         revisionId: String,
                         cursor: String?,
                         pageSize: Int,
                         completion: @escaping (Result<ExploreTopicDetailViewState, ExploreFailure>) -> Void) {
        guard !topicId.isEmpty, !revisionId.isEmpty else {
            completion(.failure(.invalidArgument))
            return
        }
        TspApi.getExploreTopicDetail(topicId: topicId,
                                     revisionId: revisionId,
                                     cursor: cursor,
                                     pageSize: pageSize) { result in
            switch result {
            case let .failure(error):
                completion(.failure(Self.mapTransportError(error)))
            case let .success(response):
                guard response.isSuccess else {
                    completion(.failure(Self.mapBusinessCode(response.code)))
                    return
                }
                guard let dto = response.data else {
                    completion(.failure(.invalidResponse))
                    return
                }
                completion(ExploreViewStateMapper.mapTopicDetail(dto,
                                                                  expectedTopicId: topicId,
                                                                  expectedRevisionId: revisionId))
            }
        }
    }

    // MARK: - 错误映射

    static func mapTransportError(_ error: Error) -> ExploreFailure {
        if let failure = error as? ExploreFailure {
            return failure
        }
        if let afError = error as? AFError,
           let underlying = afError.underlyingError as? URLError {
            return .network
        }
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return .network
        }
        return .invalidResponse
    }

    static func mapBusinessCode(_ code: String) -> ExploreFailure {
        switch code {
        case "105009": return .invalidArgument
        case "105010": return .contentUnavailable
        case "105011": return .noContent
        case "105016": return .serviceUnavailable
        case "105017": return .releaseChanged
        default:
            if code.hasPrefix("401") { return .unauthorized }
            return .unknown
        }
    }
}
