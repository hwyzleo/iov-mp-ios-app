//
//  ProductModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class ProductModel: ObservableObject, ProductModelStateProtocol {
    @Published var contentState: ProductTypes.Model.ContentState = .content
    let routerSubject = ProductRouter.Subjects()
    var product: Product = Product.init(id: "", name: "")
    var buyCount: Int = 1
}

// MARK: - Action Protocol

extension ProductModel: ProductModelActionProtocol {
    func displayLoading() {
        contentState = .loading
    }
    func updateContent(product: Product) {
        self.product = product
        contentState = .content
    }
    func displayError(text: String) {
        contentState = .error(text: text)
    }
}

// MARK: - Route

extension ProductModel: ProductModelRouterProtocol {
    func closeScreen() {}
    func routeToOrderConfirm() {
        routerSubject.screen.send(.orderConfirm)
    }
}

extension ProductTypes.Model {
    enum ContentState {
        case loading
        case content
        case error(text: String)
    }
}
