//
//  MallModelProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

// MARK: - View State

protocol MallModelStateProtocol {
    var contentState: MallTypes.Model.ContentState { get }
    var routerSubject: MallRouter.Subjects { get }
    var recommendedProducts: [Product] { get }
    var categories: [String:[Product]] { get }
}

// MARK: - Intent Action

protocol MallModelActionProtocol: MviModelActionProtocol {
    /// 更新内容
    func updateContent(mallIndex: MallIndex)
}

// MARK: - Route

protocol MallModelRouterProtocol: MviModelRouterProtocol {
    /// 跳转至产品页
    func routeToProduct()
}
