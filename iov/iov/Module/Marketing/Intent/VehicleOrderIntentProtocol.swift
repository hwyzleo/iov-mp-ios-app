//
//  VehicleIndexIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

protocol VehicleOrderIntentProtocol : MviIntentProtocol {
    /// 点击车型
    func onTapModel(code: String, price: Decimal)
    /// 点击备胎
    func onTapSpareTire(code: String, price: Decimal)
    /// 点击外观
    func onTapExterior(code: String, price: Decimal)
    /// 点击车轮
    func onTapWheel(code: String, price: Decimal)
    /// 点击内饰
    func onTapInterior(code: String, price: Decimal)
    /// 点击订购
    func onTapOrder()
}
