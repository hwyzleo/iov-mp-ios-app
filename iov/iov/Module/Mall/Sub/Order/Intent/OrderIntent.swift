//
//  OrderIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

class OrderIntent: MviIntentProtocol {
    private weak var modelAction: OrderModelActionProtocol?
    private weak var modelRouter: OrderModelRouterProtocol?
    
    init(model: OrderModelActionProtocol & OrderModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    func viewOnAppear() {}
}

extension OrderIntent: OrderIntentProtocol {
    func viewOnAppear(id: String, buyCount: Int) {
        modelAction?.displayLoading()
        TspApi.buyProductConfirm(id: id, buyCount: buyCount) { (result: Result<TspResponse<ProductOrder>, Error>) in
            switch result {
            case .success(let response):
                if(response.code == 0) {
                    self.modelAction?.updateContent(productOrder: response.data!)
                } else {
                    self.modelAction?.displayError(text: response.message ?? "异常")
                }
            case let .failure(error):
                print(error)
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    func onTapAddress() {
        modelRouter?.routeToAddress()
    }
}
