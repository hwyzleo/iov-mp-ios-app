//
//  CommunityTopicIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

class CommunityTopicIntent: MviIntentProtocol {
    private weak var modelAction: CommunityTopicModelActionProtocol?
    private weak var modelRouter: CommunityTopicModelRouterProtocol?
    
    
    init(model: CommunityTopicModelActionProtocol & CommunityTopicModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    /// 页面出现
    func viewOnAppear() {
        
    }
}

extension CommunityTopicIntent: CommunityTopicIntentProtocol {
    func viewOnAppear(id: String) {
        modelAction?.displayLoading()
        TspApi.getTopic(id: id) { (result: Result<TspResponse<Topic>, Error>) in
            switch result {
            case .success(let response):
                if(response.code == 0) {
                    self.modelAction?.updateContent(topic: response.data!)
                } else {
                    self.modelAction?.displayError(text: response.message ?? "异常")
                }
            case let .failure(error):
                print(error)
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    func onTapContent(type: String) {
        switch type {
        case "article":
            modelRouter?.routeToArticle()
        case "subject":
            modelRouter?.routeToSubject()
        case "topic":
            modelRouter?.routeToTopic()
        default:
            modelRouter?.closeScreen()
        }
    }
}
