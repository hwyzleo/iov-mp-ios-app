//
//  CommunityArticleIntentProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

protocol CommunityArticleIntentProtocol : MviIntentProtocol {
    /// 页面出现
    func viewOnAppear(id: String)
    /// 点赞
    func onTapLike(id: String, liked: Bool)
}
