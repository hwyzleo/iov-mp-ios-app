//
//  MySettingCommunityConventionView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import WebKit

struct MySettingCommunityConventionView: View {
    @EnvironmentObject var appGlobalState: AppGlobalState
    
    var body: some View {
        VStack {
            TopBackTitleBar(title: "社区公约")
            if let url = URL(string: "https://www.bing.com") {
                WebView(url: url)
            }
            Spacer()
        }
        .onAppear {
            appGlobalState.currentView = "MySettingCommunityConvention"
        }
    }
}

struct MySettingCommunityConventionView_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState()
    static var previews: some View {
        MySettingCommunityConventionView.build()
            .environmentObject(appGlobalState)
    }
}
