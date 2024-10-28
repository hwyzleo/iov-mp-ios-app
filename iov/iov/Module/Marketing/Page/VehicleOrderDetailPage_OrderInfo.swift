//
//  VehicleWishlistPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/13.
//

import SwiftUI
import Kingfisher

/// 车辆订单详情 - 订单信息部分
extension VehicleOrderDetailPage {
    struct OrderInfo: View {
        var orderNum: String
        var orderTime: Int64
        
        var body: some View {
            VStack {
                HStack {
                    Text(LocalizedStringKey("order_info"))
                        .bold()
                    Spacer()
                }
                Spacer().frame(height: 10)
                HStack {
                    Text(LocalizedStringKey("order_number"))
                    Spacer()
                    Text(orderNum)
                }
                Spacer().frame(height: 5)
                HStack {
                    Text(LocalizedStringKey("order_time"))
                    Spacer()
                    Text(tsFormat(ts: orderTime))
                }
            }
        }
    }
}

struct VehicleOrderDetailPage_OrderInfo_Previews: PreviewProvider {
    static var previews: some View {
        VehicleOrderDetailPage.OrderInfo(
            orderNum: "ORDERNUM001",
            orderTime: 1729403155
        )
        .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
