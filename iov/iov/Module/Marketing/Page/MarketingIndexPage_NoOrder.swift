//
//  MarketingIndexPage_NoOrder.swift
//  iov
//
//  Created by hwyz_leo on 2024/10/6.
//

import SwiftUI
import Kingfisher

extension MarketingIndexPage {
    struct NoOrder: View {
        @StateObject var container: MviContainer<MarketingIndexIntentProtocol, MarketingIndexModelStateProtocol>
        private var intent: MarketingIndexIntentProtocol { container.intent }
        private var state: MarketingIndexModelStateProtocol { container.model }
        
        var body: some View {
            VStack(spacing: 0) {
                Spacer().frame(height: kStatusBarHeight)
                
                if state.saleModelList.count > 1 {
                    SaleModelTabBar(
                        saleModelList: state.saleModelList,
                        selectedIndex: state.selectedSaleModelIndex,
                        onTap: { index in intent.onTapSelectSaleModel(index: index) }
                    )
                }
                
                SaleModelImageSlider(
                    saleModelList: state.saleModelList,
                    selectedIndex: state.selectedSaleModelIndex,
                    onIndexChange: { index in intent.onTapSelectSaleModel(index: index) }
                )
                
                Spacer().frame(height: 650)
                
                RoundedCornerButton(nameLocal: LocalizedStringKey("order_now")) {
                    intent.onTapModelConfig()
                }
                .frame(width: 300)
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
}

struct SaleModelTabBar: View {
    var saleModelList: [SaleModelMp]
    var selectedIndex: Int
    var onTap: (Int) -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(0..<saleModelList.count, id: \.self) { index in
                Text(saleModelList[index].modelName)
                    .font(selectedIndex == index ? AppTheme.fonts.title1 : AppTheme.fonts.body)
                    .foregroundColor(selectedIndex == index ? AppTheme.colors.brandMain : AppTheme.colors.fontSecondary)
                    .onTapGesture { onTap(index) }
            }
        }
        .padding(.horizontal, AppTheme.layout.margin)
        .padding(.vertical, 12)
    }
}

struct SaleModelImageSlider: View {
    var saleModelList: [SaleModelMp]
    var selectedIndex: Int
    var onIndexChange: (Int) -> Void
    
    @State private var currentImageIndex: Int = 0
    
    var body: some View {
        TabView(selection: Binding(
            get: { selectedIndex },
            set: { onIndexChange($0) }
        )) {
            ForEach(0..<saleModelList.count, id: \.self) { modelIndex in
                let model = saleModelList[modelIndex]
                VStack {
                    if !model.images.isEmpty {
                        KFImage(URL(string: model.images.first ?? ""))
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                    }
                }
                .tag(modelIndex)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 300)
    }
}

struct MarketingIndexPage_NoOrder_Previews: PreviewProvider {
    static var previews: some View {
        MarketingIndexPage.NoOrder(container: MarketingIndexPage.buildContainer())
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}