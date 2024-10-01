//
//  CommunityArticleIntentProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

protocol CommunityArticleIntentProtocol : MviIntentProtocol {
    /// 页面出现
    func viewOnAppear(id: String)
    /// 点赞
    func onTapLike(id: String, liked: Bool)
}
