//
//  VehicleOrderPage.swift
//  iov
//
//  Created by hwyz_leo on 2024/10/6.
//

import SwiftUI

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
        let id: String
        let name: String
        let view: AnyView
    }

    struct Content: View {
        @StateObject var container: MviContainer<VehicleModelConfigIntentProtocol, VehicleModelConfigModelStateProtocol>
        private var intent: VehicleModelConfigIntentProtocol { container.intent }
        private var state: VehicleModelConfigModelStateProtocol { container.model }
        @State private var selectedTabId: String = ""
        
        private var visibleTabs: [TabItem] {
            state.featureRanges.map { range in
                TabItem(
                    id: range.familyCode,
                    name: range.familyName,
                    view: AnyView(FeatureConfigView(
                        container: container,
                        featureRange: range,
                        selectedFeature: Binding(
                            get: { state.selections[range.familyCode] },
                            set: { _ in }
                        )
                    ))
                )
            }
        }
        
        var body: some View {
            VStack(spacing: 0) {
                Spacer().frame(height: kStatusBarHeight)
                TopBackTitleBar(titleLocal: LocalizedStringKey("choose_vehicle"))
                
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(visibleTabs) { tab in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedTabId = tab.id
                                    }
                                }) {
                                    Text(tab.name)
                                        .font(AppTheme.fonts.subtext)
                                        .fontWeight(selectedTabId == tab.id ? .bold : .regular)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            ZStack {
                                                if selectedTabId == tab.id {
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
                                        .foregroundColor(selectedTabId == tab.id ? AppTheme.colors.brandMain : AppTheme.colors.fontSecondary)
                                }
                                .id(tab.id)
                            }
                        }
                        .padding(.horizontal, AppTheme.layout.margin)
                    }
                    .padding(.vertical, 16)
                    .onChange(of: selectedTabId) { newValue in
                        withAnimation { proxy.scrollTo(newValue, anchor: .center) }
                    }
                }
                
                ZStack {
                    Circle()
                        .fill(AppTheme.colors.brandMain.opacity(0.05))
                        .frame(width: 400, height: 400)
                        .blur(radius: 60)
                        .offset(y: -100)
                    
                    TabView(selection: $selectedTabId) {
                        ForEach(visibleTabs) { tab in
                            tab.view.tag(tab.id)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
                
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
                                    intent.onTapSaveWishlist()
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
                                    intent.onTapOrder()
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
                    .padding(.bottom, 34)
                    .background(AppTheme.colors.background)
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .onAppear {
                if let firstTab = visibleTabs.first {
                    selectedTabId = firstTab.id
                }
            }
        }
        
        private func handleAction(completion: () -> Void) {
            for range in state.featureRanges {
                if state.selections[range.familyCode] == nil {
                    if let firstUnselectedTab = visibleTabs.first(where: { $0.id == range.familyCode }) {
                        withAnimation { selectedTabId = firstUnselectedTab.id }
                    }
                    return
                }
            }
            completion()
        }
    }
}