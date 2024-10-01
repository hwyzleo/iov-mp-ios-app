//
//  MyMessageIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

class MyMessageIntent: MviIntentProtocol {
    private weak var modelAction: MyMessageModelActionProtocol?
    private weak var modelRouter: MyMessageModelRouterProtocol?
    
    init(model: MyMessageModelActionProtocol & MyMessageModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    func viewOnAppear() {}
}

extension MyMessageIntent: MyMessageIntentProtocol {
    
}
