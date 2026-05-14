//
//  VehicleOrderDetailPage_Price.swift
//  iov
//
//  Created by hwyz_leo on 2024/10/13.
//

import SwiftUI
import Kingfisher

/// 车辆订单详情 - 价格明细部分
extension VehicleOrderDetailPage {
    struct Price: View {
        var saleModelPrice: Decimal
        var dynamicConfigs: [(String, String, Decimal)]
        var totalPrice: Decimal
        
        var body: some View {
            VStack(spacing: 12) {
                PriceRow(label: "官方指导价", price: saleModelPrice)
                
                ForEach(dynamicConfigs.indices, id: \.self) { index in
                    let config = dynamicConfigs[index]
                    PriceRow(label: config.1, price: config.2)
                }
                
                Divider().background(Color.white.opacity(0.1)).padding(.vertical, 4)
                
                HStack {
                    Text("总价")
                        .font(AppTheme.fonts.body)
                        .foregroundColor(AppTheme.colors.fontPrimary)
                    Spacer()
                    Text("￥\(totalPrice.formatted())")
                        .font(AppTheme.fonts.title1)
                        .foregroundColor(AppTheme.colors.brandMain)
                }
            }
        }
    }
}

private struct PriceRow: View {
    let label: String
    let price: Decimal
    var body: some View {
        HStack {
            Text(label)
                .font(AppTheme.fonts.subtext)
                .foregroundColor(AppTheme.colors.fontSecondary)
            Spacer()
            if price == 0 {
                Text("包含")
                    .font(AppTheme.fonts.subtext)
                    .foregroundColor(AppTheme.colors.fontPrimary)
            } else {
                Text("￥\(price.formatted())")
                    .font(AppTheme.fonts.subtext)
                    .foregroundColor(AppTheme.colors.fontPrimary)
            }
        }
    }
}
