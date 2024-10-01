//
//  MyOrderIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

class MyOrderIntent: MviIntentProtocol {
    private weak var modelAction: MyOrderModelActionProtocol?
    private weak var modelRouter: MyOrderModelRouterProtocol?
    
    init(model: MyOrderModelActionProtocol & MyOrderModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    /// 页面出现
    func viewOnAppear() {
        
    }
}

extension MyOrderIntent: MyOrderIntentProtocol {
}
