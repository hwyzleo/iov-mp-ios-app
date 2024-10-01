//
//  OrderModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class OrderModel: ObservableObject, OrderModelStateProtocol {
    @Published var contentState: OrderTypes.Model.ContentState = .content
    let routerSubject = OrderRouter.Subjects()
    var productOrder: ProductOrder = ProductOrder.init(
        product: Product.init(id: "", name: ""),
        buyCount: 0, totalPrice: 0, freight: 0, remainingPoints: 0
    )
}

// MARK: - Action Protocol

extension OrderModel: OrderModelActionProtocol {
    func displayLoading() {
        contentState = .loading
    }
    func updateContent(productOrder: ProductOrder) {
        self.productOrder = productOrder
        contentState = .content
    }
    func displayError(text: String) {
        contentState = .error(text: text)
    }
}

// MARK: - Route

extension OrderModel: OrderModelRouterProtocol {
    func closeScreen() {}
    func routeToLogin() {
        routerSubject.screen.send(.login)
    }
    func routeToAddress() {
        routerSubject.screen.send(.address)
    }
}

extension OrderTypes.Model {
    enum ContentState {
        case loading
        case content
        case error(text: String)
    }
}
