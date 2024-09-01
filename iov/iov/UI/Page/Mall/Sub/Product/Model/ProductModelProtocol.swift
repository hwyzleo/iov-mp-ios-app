//
//  ProductModelProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

// MARK: - View State

protocol ProductModelStateProtocol {
    var contentState: ProductTypes.Model.ContentState { get }
    var routerSubject: ProductRouter.Subjects { get }
    var product: Product { get }
    var buyCount: Int { get }
}

// MARK: - Intent Action

protocol ProductModelActionProtocol: MviModelActionProtocol {
    /// 更新页面内容
    func updateContent(product: Product)
}

// MARK: - Route

protocol ProductModelRouterProtocol: MviModelRouterProtocol {
    /// 跳转至订单确认页
    func routeToOrderConfirm()
}

