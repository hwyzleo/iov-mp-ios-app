//
//  MallModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class MallModel: ObservableObject, MallModelStateProtocol {
    @Published var contentState: MallTypes.Model.ContentState = .content
    let routerSubject = MallRouter.Subjects()
    var recommendedProducts: [Product] = []
    var categories: [String:[Product]] = [:]
    var zones: [MallZone] = []
}

// MARK: - Action Protocol

extension MallModel: MallModelActionProtocol {
    func displayLoading() {
        contentState = .loading
    }
    func updateContent(mallIndex: MallIndex) {
        self.recommendedProducts = mallIndex.recommendedProducts
        self.categories = mallIndex.categories
        self.zones = mallIndex.zones ?? []
        contentState = .content
    }
    func displayError(text: String) {
        contentState = .error(text: text)
    }
}

// MARK: - Route

extension MallModel: MallModelRouterProtocol {
    func closeScreen() {}
    func routeToProduct() {
        routerSubject.screen.send(.product)
    }
}

extension MallTypes.Model {
    enum ContentState {
        case loading
        case content
        case error(text: String)
    }
}
