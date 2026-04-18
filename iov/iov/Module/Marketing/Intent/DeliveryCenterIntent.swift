//
//  VehicleIntent.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
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
        ServiceContainer.marketingService.getDeliveryCenter { [weak self] (result: Result<TspResponse<[Dealership]>, Error>) in
            switch result {
            case .success(let res):
                if res.isSuccess {
                    guard let resData = res.data else {
                        self?.modelAction?.displayError(text: "数据异常")
                        return
                    }
                    self?.modelAction?.displayContent(deliveryCenterList: resData)
                } else {
                    self?.modelAction?.displayError(text: res.message ?? "请求异常")
                }
            case .failure(_):
                self?.modelAction?.displayError(text: "请求异常")
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
