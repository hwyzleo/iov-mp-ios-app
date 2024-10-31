//
//  VehicleModelProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

// MARK: - View State

protocol DealershipModelStateProtocol {
    var contentState: MarketingTypes.Model.DealershipContentState { get }
    var routerSubject: MarketingRouter.Subjects { get }
    var dealershipList: [Dealership] { get }
}

// MARK: - Intent Action

protocol DealershipModelActionProtocol: MviModelActionProtocol {
    /// 显示销售门店
    func displayContent(dealershipList: [Dealership])
}

// MARK: - Route

protocol DealershipModelRouterProtocol: MviModelRouterProtocol {

}
