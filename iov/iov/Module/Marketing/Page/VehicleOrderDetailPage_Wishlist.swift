//
//  VehicleWishlistPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/13.
//

import SwiftUI
import Kingfisher

/// 车辆订单详情 - 心愿单
extension VehicleOrderDetailPage {
    struct Wishlist: View {
        @EnvironmentObject var globalState: AppGlobalState
        @StateObject var container: MviContainer<VehicleOrderDetailIntentProtocol, VehicleOrderDetailModelStateProtocol>
        private var intent: VehicleOrderDetailIntentProtocol { container.intent }
        var saleModelImages: [String]
        var saleModelName: String
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
                ZStack {
                    TopBackTitleBar(titleLocal: LocalizedStringKey("wishlist"))
                    HStack {
                        Spacer()
                        Button(action: {
                            intent.onTapDelete()
                        }) {
                            Image("icon_setting")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                    }
                }
                .frame(height: 50)
                ScrollView {
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
                            Button(action: { intent.onTapModifySaleModel() }) {
                                HStack {
                                    Image("icon_modify")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                    Text(LocalizedStringKey("modify_model_config"))
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer().frame(height: 10)
                        Divider()
                        Spacer().frame(height: 10)
                        HStack {
                            Text(LocalizedStringKey("retail_price"))
                            Spacer()
                            Text("￥\(saleModelPrice.formatted())")
                        }
                        Spacer().frame(height: 10)
                        HStack {
                            Text(saleSpareTireName)
                            Spacer()
                            if saleSpareTirePrice == 0 {
                                Text(LocalizedStringKey("included"))
                            } else {
                                Text("￥\(saleSpareTirePrice.formatted())")
                            }
                        }
                        Spacer().frame(height: 10)
                        HStack {
                            Text(saleExteriorName)
                            Spacer()
                            if saleExteriorPrice == 0 {
                                Text(LocalizedStringKey("included"))
                            } else {
                                Text("￥\(saleExteriorPrice.formatted())")
                            }
                        }
                        Spacer().frame(height: 10)
                        HStack {
                            Text(saleWheelName)
                            Spacer()
                            if saleWheelPrice == 0 {
                                Text(LocalizedStringKey("included"))
                            } else {
                                Text("￥\(saleWheelPrice.formatted())")
                            }
                        }
                        Spacer().frame(height: 10)
                        HStack {
                            Text(saleInteriorName)
                            Spacer()
                            if saleInteriorPrice == 0 {
                                Text(LocalizedStringKey("included"))
                            } else {
                                Text("￥\(saleInteriorPrice.formatted())")
                            }
                        }
                        Spacer().frame(height: 10)
                        HStack {
                            Text(saleAdasName)
                            Spacer()
                            if saleAdasPrice == 0 {
                                Text(LocalizedStringKey("included"))
                            } else {
                                Text("￥\(saleAdasPrice.formatted())")
                            }
                        }
                        Spacer().frame(height: 10)
                        Divider()
                        Spacer().frame(height: 20)
                        HStack {
                            Text(LocalizedStringKey("total_price"))
                            Spacer()
                            Text("￥\(totalPrice.formatted())")
                        }
                    }
                }
                .scrollIndicators(.hidden)
                RoundedCornerButton(
                    nameLocal: LocalizedStringKey("order_now"),
                    color: Color.white,
                    bgColor: Color.black
                ) {
                    intent.onTapOrder()
                }
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .onChange(of: globalState.backRefresh) { _ in
                if globalState.backRefresh {
                    globalState.backRefresh = false
                    intent.viewOnAppear()
                }
            }
        }
    }
}

struct VehicleOrderDetailPage_Wishlist_Previews: PreviewProvider {
    static var previews: some View {
        VehicleOrderDetailPage.Wishlist(
            container: VehicleOrderDetailPage.buildContainer(),
            saleModelImages: [
                "https://pic.imgdb.cn/item/67065b68d29ded1a8c999b62.png",
                "https://pic.imgdb.cn/item/670685e4d29ded1a8cb9c55f.png"
            ],
            saleModelName: "寒01七座版",
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
