//
//  CommunityTopicIntentProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

protocol CommunityTopicIntentProtocol: MviIntentProtocol {
    /// 加载专题下一页
    func loadMore()
    /// 重新加载指定修订首页
    func retry()
    /// 点击专题内条目
    func onTapItem(target: ExploreTargetViewState)
    /// 关闭非阻塞错误
    func dismissPresentationError()
}
