//
//  CommunityIntentProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/8/31.
//

protocol CommunityIntentProtocol: MviIntentProtocol {
    /// 下拉刷新：重新加载频道与当前页面
    func refresh()
    /// 重新加载选中频道页面
    func retry()
    /// 选择频道
    func selectChannel(code: String)
    /// 加载某个文章流的下一页
    func loadMore(componentId: String)
    /// 点击条目：完整类型化目标交给 Intent
    func onTapItem(target: ExploreTargetViewState)
    /// 重试非阻塞错误
    func retryPresentationError()
    /// 关闭非阻塞错误
    func dismissPresentationError()
}
