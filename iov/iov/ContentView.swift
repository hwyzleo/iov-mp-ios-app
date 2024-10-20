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
                    CommunityPage.build()
                        .tabItem {
                            if globalState.selectedTab == 0 {
                                Image("icon_explore_fill")
                            } else {
                                Image("icon_explore")
                            }
                            Text(LocalizedStringKey("explore"))
                        }
                        .tag(0)
                    ServicePage.build()
                        .tabItem {
                            if globalState.selectedTab == 1 {
                                Image("icon_service_fill")
                            } else {
                                Image("icon_service")
                            }
                            Text(LocalizedStringKey("service"))
                        }
                        .tag(1)
                    if VehicleManager.shared.hasVehicle() {
                        VehiclePage.build()
                            .tabItem {
                                if globalState.selectedTab == 2 {
                                    Image("icon_vehicle_fill")
                                } else {
                                    Image("icon_vehicle")
                                }
                                Text(LocalizedStringKey("my_vehicle"))
                            }
                            .tag(2)
                    } else {
                        MarketingIndexPage.build()
                            .tabItem {
                                if globalState.selectedTab == 2 {
                                    Image("icon_vehicle_fill")
                                } else {
                                    Image("icon_vehicle")
                                }
                                Text(LocalizedStringKey("buy_vehicle"))
                            }
                            .tag(2)
                    }
                    MallPage.build()
                        .tabItem {
                            if globalState.selectedTab == 3 {
                                Image("icon_mall_fill")
                            } else {
                                Image("icon_mall")
                            }
                            Text(LocalizedStringKey("mall"))
                        }
                        .tag(3)
                    MyPage.build()
                        .tabItem {
                            if globalState.selectedTab == 4 {
                                Image("icon_person_fill")
                            } else {
                                Image("icon_person")
                            }
                            Text(LocalizedStringKey("my"))
                        }
                        .tag(4)
                }
                .accentColor(Color.black)
            }
            .disableAutocorrection(true)
        }
        .onChange(of: globalState.needRefresh) { _ in
            if globalState.needRefresh {
                globalState.needRefresh = false
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState.shared
    static var previews: some View {
        ContentView()
            .environmentObject(appGlobalState)
    }
}
