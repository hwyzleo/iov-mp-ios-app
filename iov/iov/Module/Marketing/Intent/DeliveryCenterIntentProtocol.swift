//
//  VehicleIndexIntent.swift
//  iov
//
//  Created by hwyz_leo on 2024/10/6.
//

import Foundation

protocol DeliveryCenterIntentProtocol : MviIntentProtocol {
    /// 点击具体交付中心
    func onTapDeliveryCenter(code: String, name: String)
}
