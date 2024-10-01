//
//  MyRightsIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

class MyRightsIntent: MviIntentProtocol {
    private weak var modelAction: MyRightsModelActionProtocol?
    private weak var modelRouter: MyRightsModelRouterProtocol?
    
    init(model: MyRightsModelActionProtocol & MyRightsModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    func viewOnAppear() {}
}

extension MyRightsIntent: MyRightsIntentProtocol {
}
