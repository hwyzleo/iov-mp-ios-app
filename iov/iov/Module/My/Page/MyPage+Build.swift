//
//  MyView+Build.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension MyPage {
    
    static func buildContainer() -> some MviContainer<MyIntentProtocol, MyModelStateProtocol> {
        let model = MyModel()
        let intent = MyIntent(model: model)
        let container = MviContainer(
            intent: intent as MyIntentProtocol,
            model: model as MyModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return MyPage(container: buildContainer(), isLogin: false)
    }
    
}
