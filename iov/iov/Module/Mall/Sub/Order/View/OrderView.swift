//
//  OrderView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import Kingfisher

struct OrderView: View {
    
    @StateObject var container: MviContainer<OrderIntentProtocol, OrderModelStateProtocol>
    private var intent: OrderIntentProtocol { container.intent }
    private var state: OrderModelStateProtocol { container.model }
    @EnvironmentObject var appGlobalState: AppGlobalState
    
    var body: some View {
        ZStack {
            switch state.contentState {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(2)
            case .content:
                Content(intent: intent, order: state.productOrder)
            case let .error(text):
                ErrorTip(text: text)
            }
        }
        .onAppear {
            if appGlobalState.parameters.keys.contains("id") {
                intent.viewOnAppear(
                    id: appGlobalState.parameters["id"] as! String,
                    buyCount: appGlobalState.parameters["buyCount"] as! Int
                )
            }
        }
        .modifier(OrderRouter(
            subjects: state.routerSubject,
            intent: intent
        ))
    }
}

extension OrderView {
    
    struct Content: View {
        var intent: OrderIntentProtocol
        var order: ProductOrder
        @State private var text: String = ""
        
        var body: some View {
            VStack {
                TopBackTitleBar(title: "确认订单")
                ScrollView {
                    VStack {
                        Button(action: {
                            intent.onTapAddress()
                        }) {
                            HStack {
                                Text("请添加收货地址")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding(.bottom, 20)
                            .padding(.top, 10)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        Divider()
                        Spacer()
                            .frame(height: 30)
                        HStack {
                            Text("商品信息")
                            Spacer()
                        }
                        HStack {
                            if let cover = order.product.cover {
                                KFImage(URL(string: cover)!)
                                    .resizable()
                                    .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 100)
                            }
                            VStack(alignment: .leading) {
                                Text(order.product.name)
                                Spacer()
                                    .frame(height: 50)
                                HStack {
                                    if let price = order.product.price {
                                        Text("¥ \(price)")
                                    }
                                    Spacer()
                                    Text("x\(order.buyCount)")
                                }
                            }
                            Spacer()
                        }
                        Spacer()
                            .frame(height: 20)
                        HStack {
                            Text("商品总额")
                            Spacer()
                            Text("¥ \(order.totalPrice)")
                        }
                        Spacer()
                            .frame(height: 20)
                        HStack {
                            Text("运费")
                            Spacer()
                            Text("¥ \(order.freight)")
                        }
                        Spacer()
                            .frame(height: 20)
                        HStack {
                            Text("优惠券")
                            Spacer()
                            Text("暂无优惠券")
                            Image(systemName: "chevron.right")
                        }
                        Spacer()
                            .frame(height: 20)
                        Divider()
                        Spacer()
                            .frame(height: 20)
                        HStack {
                            Text("支付方式")
                            Spacer()
                            Text("积分余额 \(order.remainingPoints)")
                        }
                        Spacer()
                            .frame(height: 20)
                        Button(action: {
                            
                        }) {
                            HStack {
                                Text("现金支付")
                                Spacer()
                                Text("¥ \(order.totalPrice)")
                            }
                            .padding(10)
                            .foregroundColor(.black)
                            .background(Color.white)
                            .cornerRadius(5)
                            .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                            .frame(height: 20)
                        Button(action: {
                            
                        }) {
                            HStack {
                                Text("积分支付")
                                Spacer()
                                Image("diamond")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                Text("10")
                            }
                            .padding(10)
                            .foregroundColor(.black)
                            .background(Color.white)
                            .cornerRadius(5)
                            .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                            .frame(height: 20)
                        Divider()
                        Spacer()
                            .frame(height: 20)
                        HStack {
                            Text("备注")
                            Spacer()
                        }
                        TextEditor(text: $text)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(height: 100)
                            .foregroundColor(.black)
                            .background(Color.white)
                            .cornerRadius(5)
                            .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                    }
                    .padding(20)
                }
                .font(.system(size: 16))
                HStack {
                    Text("¥ \(order.totalPrice)")
                        .font(.system(size: 18))
                        .bold()
                    Spacer()
                    NavigationLink(destination: OrderPayView().navigationBarBackButtonHidden(true)) {
                        Text("确认购买")
                            .font(.system(size: 12))
                            .padding(8)
                            .frame(width: 150)
                            .foregroundColor(Color.white)
                            .background(Color.black)
                            .cornerRadius(22.5)
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.top, 5)
            }
        }
    }
    
}

struct OrderView_Previews: PreviewProvider {
    static var previews: some View {
        let container = OrderView.buildContainer()
        let productOrder = mockProductOrder()
        OrderView.Content(intent: container.intent, order: productOrder)
    }
}
