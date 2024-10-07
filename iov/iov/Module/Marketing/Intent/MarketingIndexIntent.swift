//
//  VehicleIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

class MarketingIndexIntent: MviIntentProtocol {
    private weak var modelAction: MarketingIndexModelActionProtocol?
    private weak var modelRouter: MarketingIndexModelRouterProtocol?
    
    init(model: MarketingIndexModelActionProtocol & MarketingIndexModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    func viewOnAppear() {

    }
}

extension MarketingIndexIntent: MarketingIndexIntentProtocol {
    func onTapOrder() {
        if UserManager.isLogin() {
            self.modelRouter?.routeToOrder()
        } else {
            self.modelRouter?.routeToLogin()
        }
    }
}
