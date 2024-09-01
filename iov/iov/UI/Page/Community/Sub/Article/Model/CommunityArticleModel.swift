//
//  CommunityArticleModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class CommunityArticleModel: ObservableObject, CommunityArticleModelStateProtocol {
    @Published var contentState: CommunityArticleTypes.Model.ContentState = .content
    let routerSubject = CommunityArticleRouter.Subjects()
    var article: Article = Article.init(id: "", title: "", content: "", images: [], ts: 0, username: "", views: 0, tags: [], comments: [], likeCount: 0, liked: false, shareCount: 0)
}

// MARK: - Action Protocol

extension CommunityArticleModel: CommunityArticleModelActionProtocol {
    func displayLoading() {
        contentState = .loading
    }
    func updateContent(article: Article) {
        self.article = article
        contentState = .content
    }
    func updateLike(liked: Bool) {
        self.article.liked = liked
    }
    func displayError(text: String) {
        contentState = .error(text: text)
    }
}

// MARK: - Route

extension CommunityArticleModel: CommunityArticleModelRouterProtocol {
    func closeScreen() {
        
    }
}

extension CommunityArticleTypes.Model {
    enum ContentState {
        case loading
        case content
        case error(text: String)
    }
}
