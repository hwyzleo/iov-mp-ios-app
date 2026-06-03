//
//  ContentView.swift
//  iov
//
//  Created by hwyz_leo on 2024/8/31.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var globalState: AppGlobalState
    @StateObject private var appRouter = AppRouter.shared
    
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
        NavigationStack(path: $appRouter.path) {
            if globalState.needShowLoginPage {
                LoginPage.buildMobileLogin()
                    .onAppear {
                        globalState.parameters.removeAll()
                    }
                    .onDisappear {
                        globalState.needShowLoginPage = false
                        globalState.refreshLoginStatus()
                    }
            } else {
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
        }
        .navigationDestination(for: AppRoute.self) { route in
            destinationView(for: route)
        }
        .sheet(item: $appRouter.presentedItem) { route in
            destinationView(for: route)
        }
        .fullScreenCover(item: $appRouter.fullScreenItem) { route in
            destinationView(for: route)
        }
        .preferredColorScheme(.dark)
        .background(AppTheme.colors.background.ignoresSafeArea())
        .onChange(of: globalState.needRefresh) { _ in
            if globalState.needRefresh {
                globalState.needRefresh = false
            }
        }
    }
    
    @ViewBuilder
    func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .marketing(let marketingRoute):
            marketingDestination(for: marketingRoute)
        case .community(let communityRoute):
            communityDestination(for: communityRoute)
        case .service(let serviceRoute):
            serviceDestination(for: serviceRoute)
        case .mall(let mallRoute):
            mallDestination(for: mallRoute)
        case .my(let myRoute):
            myDestination(for: myRoute)
        case .login:
            LoginPage.buildMobileLogin()
        }
    }
    
    @ViewBuilder
    func marketingDestination(for route: MarketingRoute) -> some View {
        switch route {
        case .index:
            MarketingIndexPage.build()
        case .modelVariantSelection(let saleModelCode):
            AppGlobalState.shared.parameters["saleModelCode"] = saleModelCode
            ModelVariantSelectionPage.build()
        case .modelConfig(let saleModelCode):
            AppGlobalState.shared.parameters["saleModelCode"] = saleModelCode
            VehicleModelConfigPage.build()
        case .orderDetail(let orderNo):
            AppGlobalState.shared.parameters["orderNum"] = orderNo
            VehicleOrderDetailPage.build()
        case .licenseArea:
            LicenseAreaPage.build()
        case .dealership:
            DealershipPage.build()
        case .deliveryCenter:
            DeliveryCenterPage.build()
        }
    }
    
    @ViewBuilder
    func communityDestination(for route: CommunityRoute) -> some View {
        switch route {
        case .index:
            CommunityPage.build()
        }
    }
    
    @ViewBuilder
    func serviceDestination(for route: ServiceRoute) -> some View {
        switch route {
        case .index:
            ServicePage.build()
        }
    }
    
    @ViewBuilder
    func mallDestination(for route: MallRoute) -> some View {
        switch route {
        case .index:
            MallPage.build()
        }
    }
    
    @ViewBuilder
    func myDestination(for route: MyRoute) -> some View {
        switch route {
        case .index:
            MyPage.build()
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
