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
        modelAction?.displayLoading()
        TspApi.getSaleModelList(saleCode: "H01") { (result: Result<TspResponse<SaleModelResponse>, Error>) in
            switch result {
            case .success(let res):
                self.modelAction?.updateSaleModel(saleModels: res.data!.saleModels)
            case .failure(_):
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
}

extension VehicleOrderIntent: VehicleOrderIntentProtocol {
    func onTapModel(code: String, price: Decimal) {
        modelAction?.selectModel(code: code, price: price)
    }
    func onTapSpareTire(code: String, price: Decimal) {
        modelAction?.selectSpareTire(code: code, price: price)
    }
    func onTapExterior(code: String, price: Decimal) {
        modelAction?.selectExterior(code: code, price: price)
    }
    func onTapWheel(code: String, price: Decimal) {
        modelAction?.selectWheel(code: code, price: price)
    }
    func onTapInterior(code: String, price: Decimal) {
        modelAction?.selectInterior(code: code, price: price)
    }
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
