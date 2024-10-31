//
//  VehicleModelProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

// MARK: - View State

protocol DeliveryCenterModelStateProtocol {
    var contentState: MarketingTypes.Model.DeliveryCenterContentState { get }
    var routerSubject: MarketingRouter.Subjects { get }
    var deliveryCenterList: [Dealership] { get }
}

// MARK: - Intent Action

protocol DeliveryCenterModelActionProtocol: MviModelActionProtocol {
    /// 显示交付中心
    func displayContent(deliveryCenterList: [Dealership])
}

// MARK: - Route

protocol DeliveryCenterModelRouterProtocol: MviModelRouterProtocol {

}
