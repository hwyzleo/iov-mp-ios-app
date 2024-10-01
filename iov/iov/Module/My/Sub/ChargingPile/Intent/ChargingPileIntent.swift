//
//  ChargingPileIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

class ChargingPileIntent: MviIntentProtocol {
    private weak var modelAction: ChargingPileModelActionProtocol?
    private weak var modelRouter: ChargingPileModelRouterProtocol?
    
    init(model: ChargingPileModelActionProtocol & ChargingPileModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    /// 页面出现
    func viewOnAppear() {
        
    }
}

extension ChargingPileIntent: ChargingPileIntentProtocol {
}
