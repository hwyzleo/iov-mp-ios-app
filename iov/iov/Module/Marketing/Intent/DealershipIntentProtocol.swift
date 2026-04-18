//
//  VehicleIndexIntent.swift
//  iov
//
//  Created by hwyz_leo on 2024/10/6.
//

import Foundation

protocol DealershipIntentProtocol : MviIntentProtocol {
    /// 点击具体销售门店
    func onTapDealership(code: String, name: String)
}
