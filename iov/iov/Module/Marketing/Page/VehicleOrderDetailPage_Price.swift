//
//  VehicleWishlistPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/13.
//

import SwiftUI
import Kingfisher

/// 车辆订单详情 - 价格明细部分
extension VehicleOrderDetailPage {
    struct Price: View {
        var saleModelPrice: Decimal
        var saleSpareTireName: String
        var saleSpareTirePrice: Decimal
        var saleExteriorName: String
        var saleExteriorPrice: Decimal
        var saleWheelName: String
        var saleWheelPrice: Decimal
        var saleInteriorName: String
        var saleInteriorPrice: Decimal
        var saleAdasName: String
        var saleAdasPrice: Decimal
        var totalPrice: Decimal
        
        var body: some View {
            VStack {
                HStack {
                    Text(LocalizedStringKey("price_detail"))
                        .bold()
                    Spacer()
                }
                Spacer().frame(height: 10)
                HStack {
                    Text(LocalizedStringKey("national_unified_retail_price"))
                    Spacer()
                    Text("￥\(saleModelPrice.formatted())")
                }
                Spacer().frame(height: 5)
                HStack {
                    Text(saleSpareTireName)
                    Spacer()
                    if saleSpareTirePrice > 0 {
                        Text("￥\(saleSpareTirePrice.formatted())")
                    } else {
                        Text(LocalizedStringKey("price_included"))
                            .font(.system(size: 14))
                    }
                }
                Spacer().frame(height: 5)
                HStack {
                    Text(saleExteriorName)
                    Spacer()
                    if saleExteriorPrice > 0 {
                        Text("￥\(saleExteriorPrice.formatted())")
                    } else {
                        Text(LocalizedStringKey("price_included"))
                            .font(.system(size: 14))
                    }
                }
                Spacer().frame(height: 5)
                HStack {
                    Text(saleWheelName)
                    Spacer()
                    if saleWheelPrice > 0 {
                        Text("￥\(saleWheelPrice.formatted())")
                    } else {
                        Text(LocalizedStringKey("price_included"))
                            .font(.system(size: 14))
                    }
                }
                Spacer().frame(height: 5)
                HStack {
                    Text(saleInteriorName)
                    Spacer()
                    if saleInteriorPrice > 0 {
                        Text("￥\(saleInteriorPrice.formatted())")
                    } else {
                        Text(LocalizedStringKey("price_included"))
                            .font(.system(size: 14))
                    }
                }
                Spacer().frame(height: 5)
                HStack {
                    Text(saleAdasName)
                    Spacer()
                    if saleAdasPrice > 0 {
                        Text("￥\(saleAdasPrice.formatted())")
                    } else {
                        Text(LocalizedStringKey("price_included"))
                            .font(.system(size: 14))
                    }
                }
                Spacer().frame(height: 5)
                Divider()
                Spacer().frame(height: 5)
                HStack {
                    Text(LocalizedStringKey("total_price"))
                    Spacer()
                    Text("￥\(totalPrice.formatted())")
                }
            }
        }
    }
}

struct VehicleOrderDetailPage_Price_Previews: PreviewProvider {
    static var previews: some View {
        VehicleOrderDetailPage.Price(
            saleModelPrice: 188888,
            saleSpareTireName: "有备胎",
            saleSpareTirePrice: 6000,
            saleExteriorName: "翡翠绿车漆",
            saleExteriorPrice: 0,
            saleWheelName: "21寸轮毂（四季胎）高亮黑",
            saleWheelPrice: 0,
            saleInteriorName: "乌木黑内饰",
            saleInteriorPrice: 0,
            saleAdasName: "高价智驾",
            saleAdasPrice: 10000,
            totalPrice: 205888
        )
        .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
