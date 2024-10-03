//
//  MallView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

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
        
        var body: some View {
            VStack {
                RefreshScrollView(offDown: 100.0, listH: ScreenH - kNavHeight - kBottomSafeHeight, refreshing: $isRefresh) {
                    // 下拉刷新触发
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                        // 刷新完成，关闭刷新
                        intent.viewOnAppear()
                        isRefresh = false
                    })
                } content: {
                    Content(intent: intent, recommendedProducts: state.recommendedProducts, categories: state.categories)
                }
                .scrollIndicators(.hidden)
                .ignoresSafeArea()
            }
        }
    }
    
    struct Content: View {
        var intent: MallIntentProtocol
        var recommendedProducts: [Product]
        var categories: [String:[Product]]
        @EnvironmentObject var appGlobalState: AppGlobalState
        
        var body: some View {
            VStack {
                MallPage.Carousel(products: recommendedProducts, action: { id in
                    appGlobalState.parameters["id"] = id
                    intent.onTapProduct(id: id)
                })
                ForEach(categories.sorted(by: {$0.key < $1.key}), id: \.key) { title, products in
                    MallPage.Category(title: title, products: products, action: { id in
                        appGlobalState.parameters["id"] = id
                        intent.onTapProduct(id: id)
                    })
                }
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
            MallPage.Content(intent: container.intent, recommendedProducts: mallIndex.recommendedProducts, categories: mallIndex.categories)
                .environmentObject(appGlobalState)
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea()
    }
}
