//
//  MallView_Carousel.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI
import Kingfisher

extension MallPage {
    struct Carousel: View {
        var products: [Product] = []
        var action: ((_ id: String) -> Void)?
        
        @State private var currentIndex = 0
        private let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()

        var body: some View {
            VStack(spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    TabView(selection: $currentIndex) {
                        ForEach(0..<products.count, id: \.self) { index in
                            Button(action: {
                                action?(products[index].id)
                            }) {
                                ZStack(alignment: .bottomLeading) {
                                    if let recommendedCover = products[index].recommendedCover {
                                        KFImage(URL(string: recommendedCover))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 200)
                                            .clipped()
                                    }
                                    
                                    // 渐变蒙层
                                    LinearGradient(
                                        gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    
                                    Text(products[index].name)
                                        .font(AppTheme.fonts.title1)
                                        .foregroundColor(.white)
                                        .padding(16)
                                        .padding(.bottom, 10)
                                }
                            }
                            .buttonStyle(.plain)
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never)) // 隐藏原生指示器
                    .frame(height: 200)
                    .cornerRadius(AppTheme.layout.radiusMedium)
                    
                    // 自定义精致指示器
                    HStack(spacing: 6) {
                        ForEach(0..<products.count, id: \.self) { index in
                            Capsule()
                                .fill(currentIndex == index ? AppTheme.colors.brandMain : Color.white.opacity(0.3))
                                .frame(width: currentIndex == index ? 16 : 6, height: 4)
                                .animation(.spring(), value: currentIndex)
                        }
                    }
                    .padding(.leading, 16)
                    .padding(.bottom, 12)
                }
            }
            .padding(.horizontal, AppTheme.layout.margin)
            .onReceive(timer) { _ in
                withAnimation {
                    currentIndex = (currentIndex + 1) % (products.count > 0 ? products.count : 1)
                }
            }
        }
    }
}

#Preview {
    MallPage.Carousel(products: [
        Product.init(id: "1", name: "车载无人机", recommendedCover: "https://pic.imgdb.cn/item/65e9b3879f345e8d036bff96.png"),
        Product.init(id: "2", name: "露营帐篷", recommendedCover: "https://pic.imgdb.cn/item/65e9b3939f345e8d036c2633.png"),
        Product.init(id: "3", name: "车辆模型", recommendedCover: "https://pic.imgdb.cn/item/65e9b39f9f345e8d036c4a0a.png")
    ])
}
