//
//  MyPointsIntent.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

class MyPointsIntent: MviIntentProtocol {
    private weak var modelAction: MyPointsModelActionProtocol?
    private weak var modelRouter: MyPointsModelRouterProtocol?
    
    init(model: MyPointsModelActionProtocol & MyPointsModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    func viewOnAppear() {}
}

extension MyPointsIntent: MyPointsIntentProtocol {
}
