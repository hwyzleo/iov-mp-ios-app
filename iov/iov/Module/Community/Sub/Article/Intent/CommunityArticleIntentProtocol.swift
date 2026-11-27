//
//  CommunityArticleIntentProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

protocol CommunityArticleIntentProtocol: MviIntentProtocol {
    /// 重新加载当前修订
    func retry()
}
