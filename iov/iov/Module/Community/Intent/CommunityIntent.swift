//
//  CommunityIntent.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import Foundation

class CommunityIntent: MviIntentProtocol {
    private weak var modelAction: CommunityModelActionProtocol?
    private weak var modelRouter: CommunityModelRouterProtocol?
    private weak var modelState: CommunityModelStateProtocol?

    private let service: ExploreServiceProtocol
    private let resolver: ExploreTargetResolver
    private let pageSize: Int

    /// 页面代次：频道切换 / 刷新 / 发布版本变化时递增，旧响应不得覆盖新状态
    private var pageGeneration = 0
    private var channelsRequestInFlight = false
    private var pageRequestInFlight = false
    private var currentChannelCode: String?
    private var currentETag: String?
    private var loadingMoreComponentIds: Set<String> = []

    init(model: CommunityModelActionProtocol & CommunityModelRouterProtocol & CommunityModelStateProtocol,
         service: ExploreServiceProtocol = RealExploreService(),
         resolver: ExploreTargetResolver = ExploreTargetResolver()) {
        self.modelAction = model
        self.modelRouter = model
        self.modelState = model
        self.service = service
        self.resolver = resolver
        self.pageSize = RealExploreService.defaultPageSize
    }

    /// 页面出现：已有内容时不重复请求
    func viewOnAppear() {
        guard modelState?.page == nil else { return }
        guard modelState?.channels.isEmpty ?? true else { return }
        startChannelLoad(isRefresh: false)
    }
}

extension CommunityIntent: CommunityIntentProtocol {

    func refresh() {
        guard !pageRequestInFlight else { return }
        startChannelLoad(isRefresh: true)
    }

    func retry() {
        if let code = modelState?.selectedChannelCode,
           !(modelState?.channels.isEmpty ?? true) {
            pageGeneration += 1
            pageRequestInFlight = false
            currentChannelCode = code
            currentETag = nil
            loadingMoreComponentIds.removeAll()
            modelAction?.beginInitialLoad()
            loadPage(channelCode: code, etag: nil, generation: pageGeneration)
        } else {
            startChannelLoad(isRefresh: false)
        }
    }

    func selectChannel(code: String) {
        guard code != modelState?.selectedChannelCode else { return }
        pageGeneration += 1
        pageRequestInFlight = false
        currentChannelCode = code
        currentETag = nil
        loadingMoreComponentIds.removeAll()
        modelAction?.beginChannelChange(code: code)
        loadPage(channelCode: code, etag: nil, generation: pageGeneration)
    }

    func loadMore(componentId: String) {
        guard !pageRequestInFlight, !(modelState?.isRefreshing ?? false) else { return }
        guard let page = modelState?.page,
              let feed = page.feed(componentId: componentId),
              feed.hasMore,
              let cursor = feed.nextCursor else {
            return
        }
        guard currentChannelCode == page.channelCode else { return }
        guard !loadingMoreComponentIds.contains(componentId),
              !(modelState?.loadingMoreComponentIds.contains(componentId) ?? false) else {
            return
        }

        let generation = pageGeneration
        let releaseId = page.releaseId
        let channelCode = page.channelCode
        loadingMoreComponentIds.insert(componentId)
        modelAction?.beginFeedLoad(componentId: componentId)

        service.loadArticleFeed(channelCode: channelCode,
                                componentId: componentId,
                                releaseId: releaseId,
                                cursor: cursor,
                                pageSize: pageSize) { [weak self] result in
            guard let self = self else { return }
            self.onMain {
                self.loadingMoreComponentIds.remove(componentId)
                guard generation == self.pageGeneration,
                      self.currentChannelCode == channelCode else {
                    self.modelAction?.endFeedLoad(componentId: componentId)
                    return
                }
                guard let currentPage = self.modelState?.page,
                      currentPage.releaseId == releaseId else {
                    self.modelAction?.endFeedLoad(componentId: componentId)
                    return
                }

                switch result {
                case let .success(feed):
                    self.modelAction?.applyFeedPage(feed)
                case let .failure(failure):
                    if failure == .releaseChanged {
                        self.modelAction?.endFeedLoad(componentId: componentId)
                        self.reloadForReleaseChange()
                    } else {
                        self.modelAction?.failFeedLoad(componentId: componentId, failure: failure)
                    }
                }
            }
        }
    }

    func onTapItem(target: ExploreTargetViewState) {
        let resolution = resolver.resolve(target)
        if case .success = resolution {
            modelAction?.setPresentationError(nil)
        }
        switch resolution {
        case let .success(.article(ref)):
            modelRouter?.routeToArticle(ref: ref)
        case let .success(.topic(ref)):
            modelRouter?.routeToTopic(ref: ref)
        case let .success(.web(url)):
            modelRouter?.routeToWeb(url: url)
        case let .success(.native(destination)):
            modelRouter?.routeToNative(destination)
        case .failure:
            modelAction?.setPresentationError(.target(.invalidTarget))
        }
    }

    func retryPresentationError() {
        guard let error = modelState?.presentationError else { return }
        switch error {
        case .refresh:
            refresh()
        case let .feed(componentId, _):
            modelAction?.setPresentationError(nil)
            loadMore(componentId: componentId)
        case .target:
            modelAction?.setPresentationError(nil)
        }
    }

    func dismissPresentationError() {
        modelAction?.setPresentationError(nil)
    }
}

// MARK: - Private

private extension CommunityIntent {

    func startChannelLoad(isRefresh: Bool) {
        guard !channelsRequestInFlight else { return }
        channelsRequestInFlight = true
        pageGeneration += 1
        let generation = pageGeneration
        pageRequestInFlight = false
        loadingMoreComponentIds.removeAll()
        let priorSelected = modelState?.selectedChannelCode ?? currentChannelCode

        if isRefresh {
            modelAction?.beginRefresh()
        } else {
            modelAction?.beginInitialLoad()
        }

        service.loadChannels { [weak self] result in
            guard let self = self else { return }
            self.onMain {
                self.channelsRequestInFlight = false
                guard generation == self.pageGeneration else { return }
                switch result {
                case let .failure(failure):
                    self.modelAction?.applyPageFailure(failure)
                case let .success(channels):
                    let selected = channels.contains(where: { $0.code == priorSelected })
                        ? priorSelected
                        : channels.first?.code
                    self.modelAction?.updateChannels(channels, selectedChannelCode: selected)
                    guard let channelCode = selected, !channels.isEmpty else {
                        self.modelAction?.applyNoContent()
                        return
                    }
                    self.currentChannelCode = channelCode
                    let etag = (isRefresh && channelCode == priorSelected) ? self.currentETag : nil
                    self.loadPage(channelCode: channelCode, etag: etag, generation: generation)
                }
            }
        }
    }

    func loadPage(channelCode: String, etag: String?, generation: Int) {
        pageRequestInFlight = true
        service.loadCurrentPage(channelCode: channelCode,
                                pageSize: pageSize,
                                ifNoneMatch: etag) { [weak self] result in
            guard let self = self else { return }
            self.onMain {
                guard generation == self.pageGeneration else { return }
                self.pageRequestInFlight = false
                guard self.currentChannelCode == channelCode,
                      self.modelState?.selectedChannelCode == channelCode else {
                    return
                }

                switch result {
                case let .success(.loaded(page, newETag)):
                    self.currentETag = newETag
                    self.modelAction?.applyPage(page)
                case .success(.notModified):
                    self.modelAction?.applyNotModified()
                case let .failure(failure):
                    if failure == .noContent {
                        self.currentETag = nil
                        self.modelAction?.applyNoContent()
                    } else {
                        self.modelAction?.applyPageFailure(failure)
                    }
                }
            }
        }
    }

    func reloadForReleaseChange() {
        guard let channelCode = currentChannelCode ?? modelState?.selectedChannelCode else {
            return
        }
        pageGeneration += 1
        pageRequestInFlight = false
        currentChannelCode = channelCode
        currentETag = nil
        loadingMoreComponentIds.removeAll()
        modelAction?.discardFeedPagination()
        modelAction?.beginRefresh()
        loadPage(channelCode: channelCode, etag: nil, generation: pageGeneration)
    }

    func onMain(_ action: @escaping () -> Void) {
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.async(execute: action)
        }
    }
}
