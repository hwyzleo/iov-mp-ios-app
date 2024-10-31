//
//  VehicleIndexIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

import Foundation

protocol DeliveryCenterIntentProtocol : MviIntentProtocol {
    /// 点击具体交付中心
    func onTapDeliveryCenter(code: String, name: String)
}
