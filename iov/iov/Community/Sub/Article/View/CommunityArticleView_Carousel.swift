//
//  CommunityArticleView_Carousel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import Kingfisher

extension CommunityArticleView {
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
            .frame(height: 400)
        }
    }
}


struct CommunityArticleView_Carousel_Previews: PreviewProvider {
    static var images: [String] = [
        "https://pic.imgdb.cn/item/65df360f9f345e8d03ae3131.png",
        "https://pic.imgdb.cn/item/65e0201e9f345e8d03620461.png",
        "https://pic.imgdb.cn/item/65df4e159f345e8d0301a944.png",
        "https://pic.imgdb.cn/item/65df55069f345e8d0318a51c.png"
    ]
    
    static var previews: some View {
        CommunityArticleView.Carousel(images: images)
    }
}
