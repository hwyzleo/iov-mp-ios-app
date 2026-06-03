//
//  MarketingRoute.swift
//  iov
//
//  Created by iov on 2026/6/3.
//

import SwiftUI

/// 购车模块路由枚举
enum MarketingRoute: Hashable {
    case index
    case modelVariantSelection(saleModelCode: String)
    case modelConfig(saleModelCode: String)
    case orderDetail(orderNo: String)
    case licenseArea
    case dealership
    case deliveryCenter
    case earnestMoneyPay
    case downPaymentPay
}
