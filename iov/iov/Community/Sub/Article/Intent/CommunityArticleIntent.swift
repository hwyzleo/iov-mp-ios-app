//
//  CommunityArticleIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

class CommunityArticleIntent: MviIntentProtocol {
    private weak var modelAction: CommunityArticleModelActionProtocol?
    private weak var modelRouter: CommunityArticleModelRouterProtocol?
    
    
    init(model: CommunityArticleModelActionProtocol & CommunityArticleModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    /// 页面出现
    func viewOnAppear() {
        
    }
}

extension CommunityArticleIntent: CommunityArticleIntentProtocol {
    func viewOnAppear(id: String) {
        modelAction?.displayLoading()
        TspApi.getArticle(id: id) { (result: Result<TspResponse<Article>, Error>) in
            switch result {
            case .success(let response):
                if(response.code == 0) {
                    self.modelAction?.updateContent(article: response.data!)
                } else {
                    self.modelAction?.displayError(text: response.message ?? "异常")
                }
            case let .failure(error):
                print(error)
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    func onTapLike(id: String, liked: Bool) {
        TspApi.likeArticle(id: id, liked: liked) { (result: Result<TspResponse<NoReply>, Error>) in
            switch result {
            case .success(let response):
                if(response.code == 0) {
                    self.modelAction?.updateLike(liked: liked)
                } else {
                    self.modelAction?.displayError(text: response.message ?? "异常")
                }
            case let .failure(error):
                print(error)
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
}
