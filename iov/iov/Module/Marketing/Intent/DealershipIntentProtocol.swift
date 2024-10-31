//
//  VehicleIndexIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

import Foundation

protocol DealershipIntentProtocol : MviIntentProtocol {
    /// 点击具体销售门店
    func onTapDealership(code: String, name: String)
}
