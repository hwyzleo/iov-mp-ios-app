//
//  MallView.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI
import Kingfisher

struct MallPage: View {
    
    @StateObject var container: MviContainer<MallIntentProtocol, MallModelStateProtocol>
    private var intent: MallIntentProtocol { container.intent }
    private var state: MallModelStateProtocol { container.model }
    
    var body: some View {
        ZStack {
            switch state.contentState {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(2)
            case .content:
                RefreshContent(intent: intent, state: state)
            case let .error(text):
                ErrorTip(text: text)
            }
        }
        .onAppear {
            if state.recommendedProducts.count == 0 {
                intent.viewOnAppear()
            }
        }
        .modifier(MallRouter(
            subjects: state.routerSubject,
            intent: intent
        ))
    }
}

extension MallPage {
    struct RefreshContent: View {
        var intent: MallIntentProtocol
        var state: MallModelStateProtocol
        @State var isRefresh = false
        @State private var searchText = ""
        @State private var selectedCategory = 0
        private let categories = ["推荐", "服饰", "家居", "户外", "科技", "潮玩"]
        
        var body: some View {
            VStack(spacing: 0) {
                // 1. 顶部搜索栏
                HStack {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppTheme.colors.fontTertiary)
                        TextField(LocalizedStringKey("search_mall_placeholder"), text: $searchText)
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.colors.fontPrimary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppTheme.colors.cardBackground)
                    .cornerRadius(AppTheme.layout.radiusSmall)
                }
                .padding(.horizontal, AppTheme.layout.margin)
                .padding(.vertical, 10)
                
                // 2. 二级分类菜单 (横向滚动)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach(0..<categories.count, id: \.self) { index in
                            CategoryMenuItem(title: categories[index], isSelected: selectedCategory == index) {
                                selectedCategory = index
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.layout.margin)
                }
                .padding(.bottom, 12)
                
                // 3. 内容滚动区
                RefreshScrollView(offDown: 100.0, listH: ScreenH - kNavHeight - kBottomSafeHeight - 100, refreshing: $isRefresh) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                        intent.viewOnAppear()
                        isRefresh = false
                    })
                } content: {
                    Content(intent: intent, recommendedProducts: state.recommendedProducts, categories: state.categories, zones: state.zones)
                }
                .scrollIndicators(.hidden)
            }
            .background(AppTheme.colors.background)
        }
    }
    
    private struct CategoryMenuItem: View {
        var title: String
        var isSelected: Bool
        var action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 15, weight: isSelected ? .bold : .regular))
                        .foregroundColor(isSelected ? AppTheme.colors.fontPrimary : AppTheme.colors.fontSecondary)
                    
                    if isSelected {
                        Capsule()
                            .fill(AppTheme.colors.brandMain)
                            .frame(width: 12, height: 3)
                    } else {
                        Capsule().fill(Color.clear).frame(width: 12, height: 3)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    struct Content: View {
        var intent: MallIntentProtocol
        var recommendedProducts: [Product]
        var categories: [String:[Product]]
        var zones: [MallZone]
        @EnvironmentObject var appGlobalState: AppGlobalState
        
        var body: some View {
            VStack(spacing: AppTheme.layout.spacing) {
                MallPage.Carousel(products: recommendedProducts, action: { id in
                    appGlobalState.parameters["id"] = id
                    intent.onTapProduct(id: id)
                })
                
                // 专区
                ForEach(zones, id: \.title) { zone in
                    VStack(alignment: .leading, spacing: 0) {
                        ZStack(alignment: .bottomLeading) {
                            KFImage(URL(string: zone.cover ?? "")!)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .clipped()
                            
                            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(alignment: .lastTextBaseline) {
                                    Text(zone.title)
                                        .font(.system(size: 24, weight: .black))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("探索更多 >")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                if let subtitle = zone.subtitle {
                                    Text(subtitle)
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .padding(20)
                        }
                        .cornerRadius(AppTheme.layout.radiusLarge, corners: [.topLeft, .topRight])
                        
                        VStack(spacing: 1) {
                            ForEach(Array(zone.products.enumerated()), id: \.offset) { index, product in
                                Button(action: {
                                    appGlobalState.parameters["id"] = product.id
                                    intent.onTapProduct(id: product.id)
                                }) {
                                    HStack(spacing: 16) {
                                        KFImage(URL(string: product.recommendedCover ?? (product.cover ?? "")))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 70, height: 70)
                                            .cornerRadius(AppTheme.layout.radiusSmall)
                                            .clipped()
                                        
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(product.name)
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(AppTheme.colors.fontPrimary)
                                            Text(product.intro ?? "官方精品系列装备")
                                                .font(.system(size: 12))
                                                .foregroundColor(AppTheme.colors.fontSecondary)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 4) {
                                            if let price = product.price {
                                                Text("￥\(price)")
                                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                                    .foregroundColor(AppTheme.colors.brandMain)
                                            }
                                            Text("立即购买")
                                                .font(.system(size: 10))
                                                .foregroundColor(AppTheme.colors.brandMain.opacity(0.8))
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(AppTheme.colors.brandMain.opacity(0.1))
                                                .cornerRadius(4)
                                        }
                                    }
                                    .padding(16)
                                    .background(AppTheme.colors.cardBackground)
                                }
                                .buttonStyle(.plain)
                                
                                if index < zone.products.count - 1 {
                                    Divider().background(Color.white.opacity(0.05)).padding(.horizontal, 16)
                                }
                            }
                        }
                        .background(AppTheme.colors.cardBackground)
                        .cornerRadius(AppTheme.layout.radiusLarge, corners: [.bottomLeft, .bottomRight])
                    }
                    .padding(.horizontal, AppTheme.layout.margin)
                }
                
                // 动态分类列表
                VStack(spacing: AppTheme.layout.spacing) {
                    let displayCategories = ["服饰", "家居", "户外", "科技", "潮玩"]
                    ForEach(displayCategories, id: \.self) { title in
                        if let products = categories[title], !products.isEmpty {
                            MallPage.Category(title: title, products: products, action: { id in
                                appGlobalState.parameters["id"] = id
                                intent.onTapProduct(id: id)
                            })
                            .padding(.horizontal, AppTheme.layout.margin)
                        }
                    }
                }
                
                Spacer().frame(height: 120)
            }
        }
    }
}

struct MallView_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState.shared
    static var previews: some View {
        let container = MallPage.buildContainer()
        let mallIndex = mockMallIndex()
        ScrollView {
            MallPage.Content(intent: container.intent, recommendedProducts: mallIndex.recommendedProducts, categories: mallIndex.categories, zones: mallIndex.zones ?? [])
                .environmentObject(appGlobalState)
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea()
    }
}
