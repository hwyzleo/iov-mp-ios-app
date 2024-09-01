//
//  MyArticleIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

class MyArticleIntent: MviIntentProtocol {
    private weak var modelAction: MyArticleModelActionProtocol?
    private weak var modelRouter: MyArticleModelRouterProtocol?
    
    init(model: MyArticleModelActionProtocol & MyArticleModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    /// 页面出现
    func viewOnAppear() {
        
    }
}

extension MyArticleIntent: MyArticleIntentProtocol {
    func onTapBack() {
        modelRouter?.closeScreen()
    }
}
