//
//  VehicleIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

class DeliveryCenterIntent: MviIntentProtocol {
    private weak var modelAction: DeliveryCenterModelActionProtocol?
    private weak var modelRouter: DeliveryCenterModelRouterProtocol?
    
    init(model: DeliveryCenterModelActionProtocol & DeliveryCenterModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    func viewOnAppear() {
        modelAction?.displayLoading()
        TspApi.getDeliveryCenter { (result: Result<TspResponse<[Dealership]>, Error>) in
            switch result {
            case .success(let res):
                if res.code == 0 {
                    self.modelAction?.displayContent(deliveryCenterList: res.data!)
                } else {
                    self.modelAction?.displayError(text: res.message ?? "请求异常")
                }
            case .failure(_):
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
}

extension DeliveryCenterIntent: DeliveryCenterIntentProtocol {
    func onTapDeliveryCenter(code: String, name: String) {
        AppGlobalState.shared.parameters["deliveryCenterCode"] = code
        AppGlobalState.shared.parameters["deliveryCenterName"] = name
        AppGlobalState.shared.backRefresh = true
        self.modelRouter?.closeScreen()
    }
}
