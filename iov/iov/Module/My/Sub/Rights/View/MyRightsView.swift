//
//  MyRightsView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct MyRightsView: View {
    
    @StateObject var container: MviContainer<MyRightsIntentProtocol, MyRightsModelStateProtocol>
    private var intent: MyRightsIntentProtocol { container.intent }
    private var state: MyRightsModelStateProtocol { container.model }
    @EnvironmentObject var appGlobalState: AppGlobalState
    
    var body: some View {
        VStack {
            TopBackTitleBar(title: "我的权益")
            VStack {
                Spacer()
                    .frame(height: 300)
                Text("暂无权益")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                    .padding(10)
            }
            Spacer()
        }
        .onAppear {
            appGlobalState.currentView = "MyRights"
        }
    }
    
}

struct MyRightsView_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState.shared
    static var previews: some View {
        MyRightsView(container: MyRightsView.buildContainer())
            .environmentObject(appGlobalState)
    }
}
