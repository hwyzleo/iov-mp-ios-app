//
//  MySettingUserProtocolView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import WebKit

struct MySettingUserProtocolView: View {
    @EnvironmentObject var appGlobalState: AppGlobalState
    
    var body: some View {
        VStack {
            TopBackTitleBar(title: "用户协议")
            if let url = URL(string: "https://baidu.com") {
                WebView(url: url)
            }
            Spacer()
        }
        .onAppear {
            appGlobalState.currentView = "MySettingUserProtocol"
        }
    }
}

struct MySettingUserProtocolView_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState.shared
    static var previews: some View {
        MySettingUserProtocolView.build()
            .environmentObject(appGlobalState)
    }
}
