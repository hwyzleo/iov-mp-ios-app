//
//  VehicleIndexIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

import Foundation

protocol VehicleModelConfigIntentProtocol : MviIntentProtocol {
    /// 点击车型
    func onTapModel(code: String, name: String, price: Decimal)
    /// 点击备胎
    func onTapSpareTire(code: String, price: Decimal)
    /// 点击外观
    func onTapExterior(code: String, price: Decimal)
    /// 点击车轮
    func onTapWheel(code: String, price: Decimal)
    /// 点击内饰
    func onTapInterior(code: String, price: Decimal)
    /// 点击智驾
    func onTapAdas(code: String, price: Decimal)
    /// 点击保存心愿单
    func onTapSaveWishlist(saleCode: String, modelCode: String, modelName: String, spareTireCode: String, exteriorCode: String, wheelCode: String, interiorCode: String, adasCode: String)
    /// 点击订购
    func onTapOrder(saleCode: String, modelCode: String, modelName: String, spareTireCode: String, exteriorCode: String, wheelCode: String, interiorCode: String, adasCode: String)
}
