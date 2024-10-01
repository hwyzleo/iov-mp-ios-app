//
//  ProductView+Build.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension ProductView {
    
    static func buildContainer() -> some MviContainer<ProductIntentProtocol, ProductModelStateProtocol> {
        let model = ProductModel()
        let intent = ProductIntent(model: model)
        let container = MviContainer(
            intent: intent as ProductIntentProtocol,
            model: model as ProductModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return ProductView(container: buildContainer())
    }
    
}
