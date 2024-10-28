//
//  VehicleWishlistPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/13.
//

import SwiftUI
import Kingfisher

/// 车辆订单详情 - 车型简介部分
extension VehicleOrderDetailPage {
    struct Intro: View {
        var saleModelImages: [String]
        var saleModelName: String
        var saleModelDesc: String
        
        var body: some View {
            VStack {
                TabView {
                    ForEach(saleModelImages, id: \.self) { image in
                        ZStack {
                            if !image.isEmpty {
                                KFImage(URL(string: image)!)
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                    }
                }
                .tabViewStyle(.page)
                .frame(height: 200)
                .clipped()
                Spacer().frame(height: 20)
                HStack {
                    Text(saleModelName)
                        .bold()
                    Spacer()
                }
                Spacer().frame(height: 10)
                HStack {
                    Text(saleModelDesc)
                        .foregroundStyle(AppTheme.colors.fontSecondary)
                        .font(.system(size: 13))
                    Spacer()
                }
            }
        }
    }
}

struct VehicleOrderDetailPage_Intro_Previews: PreviewProvider {
    static var previews: some View {
        VehicleOrderDetailPage.Intro(
            saleModelImages: [
                "https://pic.imgdb.cn/item/67065b68d29ded1a8c999b62.png",
                "https://pic.imgdb.cn/item/670685e4d29ded1a8cb9c55f.png"
            ],
            saleModelName: "寒01七座版",
            saleModelDesc: "寒01七座版 | 有备胎 | 翡翠绿车漆 | 21寸轮毂(四季胎)高亮黑 | 乌木黑内饰 | 高阶智驾"
        )
        .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
