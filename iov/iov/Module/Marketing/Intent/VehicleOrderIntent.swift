//
//  VehicleIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

class VehicleOrderIntent: MviIntentProtocol {
    private weak var modelAction: VehicleOrderModelActionProtocol?
    private weak var modelRouter: VehicleOrderModelRouterProtocol?
    
    init(model: VehicleOrderModelActionProtocol & VehicleOrderModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    func viewOnAppear() {

    }
}

extension VehicleOrderIntent: VehicleOrderIntentProtocol {
    func onTapOrder() {
        modelAction?.displayLoading()
        TspApi.createSmallOrder(licenseCityCode: "", vehicleSeries: "", vehicleModel: "", paymentType: "", agreementId: "") { (result: Result<TspResponse<OrderResponse>, Error>) in
            switch result {
            case .success(let res):
                self.modelAction?.saveOrder(orderNum: res.data!.orderNum)
            case .failure(_):
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
}
