//
//  VehicleOrderPage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

import SwiftUI

/// 车辆车型配置页
struct VehicleModelConfigPage: View {
    @StateObject var container: MviContainer<VehicleModelConfigIntentProtocol, VehicleModelConfigModelStateProtocol>
    private var intent: VehicleModelConfigIntentProtocol { container.intent }
    private var state: VehicleModelConfigModelStateProtocol { container.model }

    var body: some View {
        ZStack {
            switch state.contentState {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(2)
            case .content:
                Content(container: container)
            case let .error(text):
                Content(container: container)
                ErrorTip(text: text)
            }
        }
        .appBackground()
        .onAppear {
            intent.viewOnAppear()
        }
        .modifier(MarketingRouter(subjects: state.routerSubject))
    }
}

extension VehicleModelConfigPage {
    struct TabItem: Identifiable {
        let id: Int
        let name: String
        let view: AnyView
    }

    struct Content: View {
        @StateObject var container: MviContainer<VehicleModelConfigIntentProtocol, VehicleModelConfigModelStateProtocol>
        private var intent: VehicleModelConfigIntentProtocol { container.intent }
        private var state: VehicleModelConfigModelStateProtocol { container.model }
        @State private var selectedTab = 0
        
        private var visibleTabs: [TabItem] {
            var tabs: [TabItem] = []
            if !state.models.isEmpty {
                tabs.append(TabItem(id: 0, name: "vehicle_model", view: AnyView(VehicleModelConfigPage.Model(container: container))))
            }
            if !state.spareTires.isEmpty {
                tabs.append(TabItem(id: 1, name: "spare_tire", view: AnyView(VehicleModelConfigPage.SpareTire(container: container))))
            }
            if !state.exteriors.isEmpty {
                tabs.append(TabItem(id: 2, name: "exterior", view: AnyView(VehicleModelConfigPage.Exterior(container: container))))
            }
            if !state.wheels.isEmpty {
                tabs.append(TabItem(id: 3, name: "wheel", view: AnyView(VehicleModelConfigPage.Wheel(container: container))))
            }
            if !state.interiors.isEmpty {
                tabs.append(TabItem(id: 4, name: "interior", view: AnyView(VehicleModelConfigPage.Interior(container: container))))
            }
            if !state.adases.isEmpty {
                tabs.append(TabItem(id: 5, name: "adas", view: AnyView(VehicleModelConfigPage.Adas(container: container))))
            }
            return tabs
        }
        
        var body: some View {
            VStack(spacing: 0) {
                Spacer().frame(height: kStatusBarHeight)
                TopBackTitleBar(titleLocal: LocalizedStringKey("choose_vehicle"))
                
                // 二级导航 - 极简药丸样式
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(visibleTabs) { tab in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedTab = tab.id
                                    }
                                }) {
                                    Text(LocalizedStringKey(tab.name))
                                        .font(AppTheme.fonts.subtext)
                                        .fontWeight(selectedTab == tab.id ? .bold : .regular)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            ZStack {
                                                if selectedTab == tab.id {
                                                    Capsule()
                                                        .fill(AppTheme.colors.brandMain.opacity(0.15))
                                                    Capsule()
                                                        .stroke(AppTheme.colors.brandMain, lineWidth: 1)
                                                } else {
                                                    Capsule()
                                                        .fill(Color.white.opacity(0.05))
                                                }
                                            }
                                        )
                                        .foregroundColor(selectedTab == tab.id ? AppTheme.colors.brandMain : AppTheme.colors.fontSecondary)
                                }
                                .id(tab.id)
                            }
                        }
                        .padding(.horizontal, AppTheme.layout.margin)
                    }
                    .padding(.vertical, 16)
                    .onChange(of: selectedTab) { newValue in
                        withAnimation { proxy.scrollTo(newValue, anchor: .center) }
                    }
                }
                
                // 主内容区 - 增加背景光效
                ZStack {
                    // 背景装饰光晕
                    Circle()
                        .fill(AppTheme.colors.brandMain.opacity(0.05))
                        .frame(width: 400, height: 400)
                        .blur(radius: 60)
                        .offset(y: -100)
                    
                    TabView(selection: $selectedTab) {
                        ForEach(visibleTabs) { tab in
                            tab.view.tag(tab.id)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
                
                // 底部操作栏 - 悬浮质感
                VStack(spacing: 0) {
                    LinearGradient(
                        gradient: Gradient(colors: [Color.clear, AppTheme.colors.background]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 20)
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("￥\(state.totalPrice.formatted())")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.colors.fontPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                            Text(LocalizedStringKey("total_price"))
                                .font(AppTheme.fonts.subtext)
                                .foregroundColor(AppTheme.colors.fontTertiary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                handleAction {
                                    intent.onTapSaveWishlist(saleCode: state.saleCode, modelCode: state.selectModel, modelName: state.selectModelName, spareTireCode: state.selectSpareTire, exteriorCode: state.selectExterior, wheelCode: state.selectWheel, interiorCode: state.selectInterior, adasCode: state.selectAdas)
                                }
                            }) {
                                Text(LocalizedStringKey("save_wishlist"))
                                    .font(AppTheme.fonts.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppTheme.colors.fontPrimary)
                                    .frame(width: 100, height: 48)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(AppTheme.layout.radiusMedium)
                            }
                            
                            Button(action: {
                                handleAction {
                                    intent.onTapOrder(saleCode: state.saleCode, modelCode: state.selectModel, modelName: state.selectModelName, spareTireCode: state.selectSpareTire, exteriorCode: state.selectExterior, wheelCode: state.selectWheel, interiorCode: state.selectInterior, adasCode: state.selectAdas)
                                }
                            }) {
                                Text(LocalizedStringKey("order_now"))
                                    .font(AppTheme.fonts.body)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                    .frame(width: 100, height: 48)
                                    .background(AppTheme.colors.brandMain)
                                    .cornerRadius(AppTheme.layout.radiusMedium)
                                    .shadow(color: AppTheme.colors.brandMain.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.layout.margin)
                    .padding(.bottom, 34) // 适配全面屏底部
                    .background(AppTheme.colors.background)
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .onAppear {
                if let firstTab = visibleTabs.first {
                    selectedTab = firstTab.id
                }
            }
        }
        
        private func handleAction(completion: () -> Void) {
            if !state.models.isEmpty && state.selectModel == "" { 
                if let tab = visibleTabs.first(where: { $0.id == 0 }) { withAnimation { selectedTab = tab.id } }; return 
            }
            if !state.spareTires.isEmpty && state.selectSpareTire == "" { 
                if let tab = visibleTabs.first(where: { $0.id == 1 }) { withAnimation { selectedTab = tab.id } }; return 
            }
            if !state.exteriors.isEmpty && state.selectExterior == "" { 
                if let tab = visibleTabs.first(where: { $0.id == 2 }) { withAnimation { selectedTab = tab.id } }; return 
            }
            if !state.wheels.isEmpty && state.selectWheel == "" { 
                if let tab = visibleTabs.first(where: { $0.id == 3 }) { withAnimation { selectedTab = tab.id } }; return 
            }
            if !state.interiors.isEmpty && state.selectInterior == "" { 
                if let tab = visibleTabs.first(where: { $0.id == 4 }) { withAnimation { selectedTab = tab.id } }; return 
            }
            if !state.adases.isEmpty && state.selectAdas == "" { 
                if let tab = visibleTabs.first(where: { $0.id == 5 }) { withAnimation { selectedTab = tab.id } }; return 
            }
            completion()
        }
    }
}
