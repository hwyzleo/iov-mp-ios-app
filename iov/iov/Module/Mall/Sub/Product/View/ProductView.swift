//
//  ProductView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct ProductView: View {
    
    @StateObject var container: MviContainer<ProductIntentProtocol, ProductModelStateProtocol>
    private var intent: ProductIntentProtocol { container.intent }
    private var state: ProductModelStateProtocol { container.model }
    @EnvironmentObject var appGlobalState: AppGlobalState
    
    var body: some View {
        ZStack {
            switch state.contentState {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(2)
            case .content:
                Content(intent: intent, product: state.product)
            case let .error(text):
                ErrorTip(text: text)
            }
        }
        .onAppear {
            if appGlobalState.parameters.keys.contains("id") {
                intent.viewOnAppear(id: appGlobalState.parameters["id"] as! String)
            }
        }
        .modifier(ProductRouter(
            subjects: state.routerSubject,
            intent: intent
        ))
    }
}

extension ProductView {
    
    struct Content: View {
        var intent: ProductIntentProtocol
        var product: Product
        @State var buyCount: Int = 1
        @State private var showBuyConfirm = false
        @State private var showHiddenBar = false
        @EnvironmentObject var appGlobalState: AppGlobalState
        
        var body: some View {
            ZStack(alignment: .top) {
                VStack {
                    ScrollView {
                        ZStack(alignment: .top) {
                            GeometryReader { geometry in
                                Color.clear
                                    .onChange(of: geometry.frame(in: .global).minY) { value in
                                        showHiddenBar = value < 0
                                    }
                            }
                            .frame(height: 0)
                            if let images = product.images {
                                ProductView.Carousel(images: images)
                            } else {
                                if let cover = product.cover {
                                    ProductView.Carousel(images: [cover])
                                }
                            }
                        }
                        VStack(alignment: .leading) {
                            HStack {
                                Text(product.name)
                                Spacer()
                            }
                            .padding(.bottom, 5)
                            HStack {
                                if let price = product.price {
                                    Text("¥ \(price)")
                                        .font(.system(size: 14))
                                        .bold()
                                        .padding(.trailing, 10)
                                }
                                if let points = product.points {
                                    Image("diamond")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                    Text("\(points)")
                                        .font(.system(size: 14))
                                        .bold()
                                }
                                Spacer()
                            }
                            .padding(.bottom, 10)
                            Divider()
                            Button(action: { showBuyConfirm = true }) {
                                HStack {
                                    Text("规格")
                                        .font(.system(size: 14))
                                    Spacer()
                                    Text("x\(buyCount)")
                                        .font(.system(size: 14))
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding(.top, 20)
                                .padding(.bottom, 20)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            Divider()
                            VStack {
                                Text("产品详情")
                                Image("MallBanner1")
                                    .resizable()
                                    .scaledToFill()
                                Image("MallBanner2")
                                    .resizable()
                                    .scaledToFill()
                                Image("MallBanner3")
                                    .resizable()
                                    .scaledToFill()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 20)
                            Divider()
                            HStack {
                                Text("服务说明")
                                    .font(.system(size: 14))
                                Spacer()
                                Text("查看更多")
                                    .font(.system(size: 14))
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 20)
                            .padding(.bottom, 20)
                            Divider()
                        }
                        .padding(20)
                    }
                    .ignoresSafeArea()
                    HStack {
                        Image(systemName: "ellipsis.message")
                        Spacer()
                        Button(action: {
                            showBuyConfirm = true
                        }) {
                            Text("立即购买")
                                .font(.system(size: 12))
                        }
                        .padding(8)
                        .frame(width: 150)
                        .foregroundColor(Color.white)
                        .background(Color.black)
                        .cornerRadius(22.5)
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(.top, 5)
                }
                .sheet(isPresented: $showBuyConfirm) {
                    TopCloseTitleBar(title: "") {
                        showBuyConfirm = false
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                    ProductView.BuyConfirm(buyCount: $buyCount, cover: product.cover, price: product.price, buyAction: {
                        appGlobalState.parameters["buyCount"] = buyCount
                        intent.onTapBuyButton()
                    })
                        .presentationDetents([.height(500)])
                }
                TopBackTitleBar()
                    .background(.white)
                    .opacity(showHiddenBar ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5), value: showHiddenBar)
                TopBackTitleBar(color: .white)
                    .opacity(showHiddenBar ? 0 : 1)
                    .animation(.easeInOut(duration: 0.5), value: showHiddenBar)
            }
        }
    }
}

struct ProductView_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState()
    static var previews: some View {
        let container = ProductView.buildContainer()
        let product = mockProduct()
        ProductView.Content(intent: container.intent, product: product)
            .environmentObject(appGlobalState)
    }
}
