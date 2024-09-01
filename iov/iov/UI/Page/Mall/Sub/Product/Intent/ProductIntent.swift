//
//  ProductIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

class ProductIntent: MviIntentProtocol {
    private weak var modelAction: ProductModelActionProtocol?
    private weak var modelRouter: ProductModelRouterProtocol?
    
    init(model: ProductModelActionProtocol & ProductModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    func viewOnAppear() {
        
    }
}

extension ProductIntent: ProductIntentProtocol {
    func viewOnAppear(id: String) {
        modelAction?.displayLoading()
        TspApi.getProduct(id: id) { (result: Result<TspResponse<Product>, Error>) in
            switch result {
            case .success(let response):
                if(response.code == 0) {
                    self.modelAction?.updateContent(product: response.data!)
                } else {
                    self.modelAction?.displayError(text: response.message ?? "异常")
                }
            case let .failure(error):
                print(error)
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    func onTapBuyButton() {
        modelRouter?.routeToOrderConfirm()
    }
}
