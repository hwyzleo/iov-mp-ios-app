//
//  VehicleOrderDetailPage_OrderInfo.swift
//  iov
//
//  Created by hwyz_leo on 2024/10/13.
//

import SwiftUI

/// 车辆订单详情 - 订单信息部分
extension VehicleOrderDetailPage {
    struct OrderInfo: View {
        var orderNum: String
        var orderTime: Int64
        
        var body: some View {
            VStack(spacing: 12) {
                InfoRow(label: LocalizedStringKey("order_number"), value: orderNum)
                InfoRow(label: LocalizedStringKey("order_time"), value: tsFormat(ts: orderTime))
            }
        }
    }
}

private struct InfoRow: View {
    let label: LocalizedStringKey
    let value: String
    var body: some View {
        HStack {
            Text(label)
                .font(AppTheme.fonts.subtext)
                .foregroundColor(AppTheme.colors.fontSecondary)
            Spacer()
            Text(value)
                .font(AppTheme.fonts.subtext)
                .foregroundColor(AppTheme.colors.fontPrimary)
        }
    }
}
