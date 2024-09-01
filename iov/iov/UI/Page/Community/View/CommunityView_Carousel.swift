//
//  CommunityView_Carousel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import Kingfisher

extension CommunityView {
    struct Carousel: View {
        var baseContents: [BaseContent] = []
        var action: ((_ id: String, _ type: String) -> Void)?
        
        var body: some View {
            TabView {
                ForEach(baseContents, id: \.id) { baseContent in
                    ZStack {
                        if !baseContent.images.isEmpty {
                            Button(action: {
                                action?(baseContent.id, baseContent.type)
                            }) {
                                KFImage(URL(string: baseContent.images[0])!)
                                    .resizable()
                                    .scaledToFill()
                            }
                            .buttonStyle(.plain)
                        }
                        HStack {
                            Spacer()
                            Text(baseContent.title)
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                                .bold()
                            Spacer()
                        }
                        .offset(x: -80, y: 120)
                    }
                }
            }
            .tabViewStyle(.page)
            .frame(height: 400)
            .clipped()
        }
    }
}

struct CommunityView_Carousel_Previews: PreviewProvider {
    static var baseContents: [BaseContent] = [
        BaseContent.init(id: "1", type: "article", title: "测试标题1", images: ["https://pic.imgdb.cn/item/65df049a9f345e8d031861c3.png"], ts: 1709117949996),
        BaseContent.init(id: "2", type: "article", title: "测试标题2", images: ["https://pic.imgdb.cn/item/65df12989f345e8d033afff7.png"], ts: 1709117949996)
    ]
    static var intent = CommunityView.buildContainer().intent
    
    static var previews: some View {
        CommunityView.Carousel(baseContents: baseContents)
    }
}
