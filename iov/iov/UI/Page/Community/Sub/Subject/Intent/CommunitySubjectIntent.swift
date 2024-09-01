//
//  CommunitySubjectIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

class CommunitySubjectIntent: MviIntentProtocol {
    private weak var modelAction: CommunitySubjectModelActionProtocol?
    private weak var modelRouter: CommunitySubjectModelRouterProtocol?
    
    
    init(model: CommunitySubjectModelActionProtocol & CommunitySubjectModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    /// 页面出现
    func viewOnAppear() {
        
    }
}

extension CommunitySubjectIntent: CommunitySubjectIntentProtocol {
    func viewOnAppear(id: String) {
        modelAction?.displayLoading()
        TspApi.getSubject(id: id) { (result: Result<TspResponse<Subject>, Error>) in
            switch result {
            case .success(let response):
                if(response.code == 0) {
                    self.modelAction?.updateContent(subject: response.data!)
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
