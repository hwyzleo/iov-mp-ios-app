//
//  MallIntent.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

class MallIntent: MviIntentProtocol {
    private weak var modelAction: MallModelActionProtocol?
    private weak var modelRouter: MallModelRouterProtocol?
    
    
    init(model: MallModelActionProtocol & MallModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    /// 页面出现
    func viewOnAppear() {
        modelAction?.displayLoading()
        TspApi.getMallIndex() { (result: Result<TspResponse<MallIndex>, Error>) in
            switch result {
            case .success(let response):
                if(response.isSuccess) {
                    self.modelAction?.updateContent(mallIndex: response.data!)
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

extension MallIntent: MallIntentProtocol {
    func onTapProduct(id: String) {
        modelRouter?.routeToProduct()
    }
}
