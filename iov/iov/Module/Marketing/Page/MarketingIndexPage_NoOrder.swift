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
            ZStack(alignment: .bottom) {
                SaleModelImageSlider(
                    saleModelList: state.saleModelList,
                    selectedIndex: state.selectedSaleModelIndex,
                    onIndexChange: { index in intent.onTapSelectSaleModel(index: index) }
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    if state.saleModelList.count > 1 {
                        SaleModelTabBar(
                            saleModelList: state.saleModelList,
                            selectedIndex: state.selectedSaleModelIndex,
                            onTap: { index in intent.onTapSelectSaleModel(index: index) }
                        )
                        .padding(.top, kStatusBarHeight)
                    }
                    
                    Spacer()
                    
                    RoundedCornerButton(nameLocal: LocalizedStringKey("order_now")) {
                        intent.onTapModelConfig()
                    }
                    .frame(width: 300)
                    .padding(.bottom, 50)
                }
            }
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
                Group {
                    if let images = model.images, !images.isEmpty {
                        KFImage(URL(string: images.first ?? ""))
                            .resizable()
                            .scaledToFill()
                    } else {
                        Color.clear
                    }
                }
                .ignoresSafeArea()
                .tag(modelIndex)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

struct MarketingIndexPage_NoOrder_Previews: PreviewProvider {
    static var previews: some View {
        MarketingIndexPage.NoOrder(container: MarketingIndexPage.buildContainer())
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}