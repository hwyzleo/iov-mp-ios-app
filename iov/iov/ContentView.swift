//
//  ContentView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/8/31.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var globalState: AppGlobalState
    
    var body: some View {
        NavigationStack {
            ZStack {
                TabView(selection: $globalState.selectedTab) {
                    CommunityView.build()
                        .tabItem {
                            if globalState.selectedTab == 0 {
                                Image("icon_explore_fill")
                            } else {
                                Image("icon_explore")
                            }
                            Text("探索")
                        }
                        .tag(0)
                    ServiceView.build()
                        .tabItem {
                            if globalState.selectedTab == 1 {
                                Image("icon_service_fill")
                            } else {
                                Image("icon_service")
                            }
                            Text("服务")
                        }
                        .tag(1)
                    VehicleView.build()
                        .tabItem {
                            if globalState.selectedTab == 2 {
                                Image("icon_vehicle_fill")
                            } else {
                                Image("icon_vehicle")
                            }
                            Text("爱车")
                        }
                        .tag(2)
                    MallView.build()
                        .tabItem {
                            if globalState.selectedTab == 3 {
                                Image("icon_mall_fill")
                            } else {
                                Image("icon_mall")
                            }
                            Text("商城")
                        }
                        .tag(3)
                    MyView.build()
                        .tabItem {
                            if globalState.selectedTab == 4 {
                                Image("icon_person_fill")
                            } else {
                                Image("icon_person")
                            }
                            Text("我的")
                        }
                        .tag(4)
                }
                .accentColor(Color.black)
            }
            .disableAutocorrection(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState()
    static var previews: some View {
        ContentView()
            .environmentObject(appGlobalState)
    }
}
