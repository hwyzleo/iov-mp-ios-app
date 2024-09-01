//
//  ProductView_Carousel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import Kingfisher

extension ProductView {
    struct Carousel: View {
        var images: [String] = []

        var body: some View {
            TabView {
                ForEach(Array(images.enumerated()), id: \.0) { index, banner in
                    ZStack {
                        KFImage(URL(string: images[index])!)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(maxWidth: .infinity)
            .frame(height: 300)
        }
    }
}

#Preview {
    ProductView.Carousel(images: [
        "https://pic.imgdb.cn/item/65e9b3879f345e8d036bff96.png",
        "https://pic.imgdb.cn/item/65e9b3939f345e8d036c2633.png",
        "https://pic.imgdb.cn/item/65e9b39f9f345e8d036c4a0a.png"
    ])
}
