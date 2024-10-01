//
//  CommunityIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

class CommunityIntent: MviIntentProtocol {
    private weak var modelAction: CommunityModelActionProtocol?
    private weak var modelRouter: CommunityModelRouterProtocol?
    
    
    init(model: CommunityModelActionProtocol & CommunityModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    /// 页面出现
    func viewOnAppear() {
        modelAction?.displayLoading()
        TspApi.getContentBlock(channel: "community") { (result: Result<TspResponse<Array<ContentBlock>>, Error>) in
            switch result {
            case .success(let response):
                if(response.code == 0) {
                    self.modelAction?.updateContent(contentBlocks: response.data!)
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

extension CommunityIntent: CommunityIntentProtocol {
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
