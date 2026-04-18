//
//  MyAccountQrcodeView+Build.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

extension MyAccountQrcodeView {
    
    static func build() -> some View {
        return MyAccountQrcodeView(container: buildContainer())
    }
    
    static func buildContainer() -> MviContainer<MyAccountQrcodeIntentProtocol, MyAccountQrcodeModelStateProtocol> {
        let model = MyAccountQrcodeModel()
        let intent = MyAccountQrcodeIntent(model: model)
        let container = MviContainer(
            intent: intent as MyAccountQrcodeIntentProtocol,
            model: model as MyAccountQrcodeModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
}
