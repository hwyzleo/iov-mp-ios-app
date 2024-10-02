//
//  OrderPayView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct OrderPayView: View {
    @State private var isToggleOn = false
    
    var body: some View {
        VStack {
            TopBackTitleBar(title: "收银台")
            VStack {
                ScrollView {
                    Spacer()
                        .frame(height: 100)
                    HStack {
                        Spacer()
                        Text("支付金额")
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Text("¥0.01")
                            .font(.system(size: 40))
                        Spacer()
                    }
                    Spacer()
                        .frame(height: 100)
                    HStack {
                        Text("支付方式")
                        Spacer()
                    }
                    Spacer()
                        .frame(height: 20)
                    HStack {
                        Text("微信支付")
                            .bold()
                        Spacer()
                        Image(systemName: "checkmark.circle")
                    }
                    Spacer()
                        .frame(height: 20)
                    HStack {
                        Text("支付宝支付")
                            .bold()
                        Spacer()
                        Image(systemName: "circle")
                    }
                    Spacer()
                        .frame(height: 20)
                    HStack {
                        Text("银联支付")
                            .bold()
                        Spacer()
                        Image(systemName: "circle")
                    }
                    Spacer()
                        .frame(height: 40)
                    Rectangle()
                        .frame(height: 0.5)
                        .modifier(BottomLineModifier())
                    Spacer()
                        .frame(height: 20)
                    HStack {
                        Text("付款说明")
                            .bold()
                        Spacer()
                    }
                    Spacer()
                        .frame(height: 20)
                    Text("1.若您选择“银联支付”，请确保手机上已提前安装好需支付的对应银行APP；\n2.对于各银行的线上支付限额，您可致电对应银行的官方客服进行咨询；")
                        .lineSpacing(5)
                }
                Button(action: {

                }) {
                    Text("立即支付")
                        .font(.system(size: 16))
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.white)
                .background(Color.black)
                .cornerRadius(22.5)
            }
            .padding(20)
        }
    }
}

struct OrderPayView_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState.shared
    static var previews: some View {
        OrderPayView()
    }
}
