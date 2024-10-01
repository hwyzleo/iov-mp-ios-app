//
//  MallView_Carousel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import Kingfisher

extension MallView {
    struct Carousel: View {
        var products: [Product] = []
        var action: ((_ id: String) -> Void)?

        var body: some View {
            TabView {
                ForEach(products, id: \.id) { product in
                    ZStack {
                        if let recommendedCover = product.recommendedCover {
                            Button(action: {
                                action?(product.id)
                            }) {
                                KFImage(URL(string: recommendedCover))
                                    .resizable()
                                    .scaledToFill()
                            }
                            .buttonStyle(.plain)
                        }
                        HStack {
                            Text(product.name)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.top, 180)
                        .padding(.leading, 20)
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle()) // 设置滚动样式
            .frame(maxWidth: .infinity)
            .frame(height: 300) // 设置轮播图高度
        }
    }
}

#Preview {
    MallView.Carousel(products: [
        Product.init(id: "1", name: "车载无人机", recommendedCover: "https://pic.imgdb.cn/item/65e9b3879f345e8d036bff96.png"),
        Product.init(id: "2", name: "露营帐篷", recommendedCover: "https://pic.imgdb.cn/item/65e9b3939f345e8d036c2633.png"),
        Product.init(id: "3", name: "车辆模型", recommendedCover: "https://pic.imgdb.cn/item/65e9b39f9f345e8d036c4a0a.png")
    ])
}
