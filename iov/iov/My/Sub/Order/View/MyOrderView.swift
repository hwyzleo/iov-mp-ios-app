//
//  MyOrderView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct MyOrderView: View {
    
    @StateObject var container: MviContainer<MyOrderIntentProtocol, MyOrderModelStateProtocol>
    private var intent: MyOrderIntentProtocol { container.intent }
    private var state: MyOrderModelStateProtocol { container.model }
    @EnvironmentObject var appGlobalState: AppGlobalState
    
    var body: some View {
        VStack {
            TopBackTitleBar(title: "我的订单")
            VStack {
                ContentList(title: "购车订单", content: "0")
                ContentList(title: "商品订单", content: "0")
                ContentList(title: "服务订单", content: "0")
            }
            .padding(20)
            Spacer()
        }
        .onAppear {
            appGlobalState.currentView = "MyOrder"
        }
    }
    
}

struct MyOrderView_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState()
    static var previews: some View {
        MyOrderView(container: MyOrderView.buildContainer())
            .environmentObject(appGlobalState)
    }
}
