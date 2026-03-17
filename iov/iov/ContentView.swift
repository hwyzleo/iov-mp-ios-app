//
//  ContentView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/8/31.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var globalState: AppGlobalState
    
    init() {
        // 设置 TabBar 的外观以适配深色主题
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppTheme.colors.background)
        
        // 设置未选中项颜色
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppTheme.colors.fontTertiary)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(AppTheme.colors.fontTertiary)]
        
        // 设置选中项颜色
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppTheme.colors.brandMain)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(AppTheme.colors.brandMain)]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $globalState.selectedTab) {
                CommunityPage.build()
                    .tabItem {
                        Image(globalState.selectedTab == 0 ? "icon_explore_active_60" : "icon_explore_60")
                            .renderingMode(.template)
                        Text(LocalizedStringKey("explore"))
                    }
                    .tag(0)
                
                ServicePage.build()
                    .tabItem {
                        Image(globalState.selectedTab == 1 ? "icon_service_active_60" : "icon_service_60").renderingMode(.template)
                        Text(LocalizedStringKey("service"))
                    }
                    .tag(1)
                
                if VehicleManager.shared.hasVehicle() {
                    VehiclePage.build()
                        .tabItem {
                            Image(globalState.selectedTab == 2 ? "icon_hwyz_active_60" : "icon_hwyz_60").renderingMode(.template)
                            Text(LocalizedStringKey("my_vehicle"))
                        }
                        .tag(2)
                } else {
                    MarketingIndexPage.build()
                        .tabItem {
                            Image(globalState.selectedTab == 2 ? "icon_hwyz_active_60" : "icon_hwyz_60").renderingMode(.template)
                            Text(LocalizedStringKey("buy_vehicle"))
                        }
                        .tag(2)
                }
                
                MallPage.build()
                    .tabItem {
                        Image(globalState.selectedTab == 3 ? "icon_mall_active_60" : "icon_mall_60").renderingMode(.template)
                        Text(LocalizedStringKey("mall"))
                    }
                    .tag(3)
                
                MyPage.build()
                    .tabItem {
                        Image(globalState.selectedTab == 4 ? "icon_mine_active_60" : "icon_mine_60").renderingMode(.template)
                        Text(LocalizedStringKey("my"))
                    }
                    .tag(4)
            }
            .accentColor(AppTheme.colors.brandMain)
        }
        .preferredColorScheme(.dark) // 强制深色模式
        .background(AppTheme.colors.background.ignoresSafeArea())
        .showMockIndicator()
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
