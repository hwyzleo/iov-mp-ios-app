//
//  VehicleIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

class DealershipIntent: MviIntentProtocol {
    private weak var modelAction: DealershipModelActionProtocol?
    private weak var modelRouter: DealershipModelRouterProtocol?
    
    init(model: DealershipModelActionProtocol & DealershipModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    func viewOnAppear() {
        modelAction?.displayLoading()
        TspApi.getDealership() { (result: Result<TspResponse<[Dealership]>, Error>) in
            switch result {
            case .success(let res):
                if res.code == 0 {
                    self.modelAction?.displayContent(dealershipList: res.data!)
                } else {
                    self.modelAction?.displayError(text: res.message ?? "请求异常")
                }
            case .failure(_):
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
}

extension DealershipIntent: DealershipIntentProtocol {
    func onTapDealership(code: String, name: String) {
        AppGlobalState.shared.parameters["dealershipCode"] = code
        AppGlobalState.shared.parameters["dealershipName"] = name
        AppGlobalState.shared.backRefresh = true
        self.modelRouter?.closeScreen()
    }
}
