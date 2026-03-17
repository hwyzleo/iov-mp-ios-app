//
//  CommunityView_Carousel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import Kingfisher

extension CommunityPage {
    struct Carousel: View {
        var baseContents: [BaseContent] = []
        var action: ((_ id: String, _ type: String) -> Void)?
        
        @State private var currentIndex = 0
        private let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
        
        var body: some View {
            VStack(spacing: 12) {
                ZStack(alignment: .bottomLeading) {
                    TabView(selection: $currentIndex) {
                        ForEach(0..<baseContents.count, id: \.self) { index in
                            Button(action: {
                                action?(baseContents[index].id, baseContents[index].type)
                            }) {
                                ZStack(alignment: .bottomLeading) {
                                    if !baseContents[index].images.isEmpty {
                                        KFImage(URL(string: baseContents[index].images[0])!)
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
                                    
                                    Text(baseContents[index].title)
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
                        ForEach(0..<baseContents.count, id: \.self) { index in
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
            .onReceive(timer) { _ in
                withAnimation {
                    currentIndex = (currentIndex + 1) % (baseContents.count > 0 ? baseContents.count : 1)
                }
            }
        }
    }
}

struct CommunityPage_Carousel_Previews: PreviewProvider {
    static var baseContents: [BaseContent] = [
        BaseContent.init(id: "1", type: "article", title: "测试标题1", images: ["https://pic.imgdb.cn/item/65df049a9f345e8d031861c3.png"], ts: 1709117949996),
        BaseContent.init(id: "2", type: "article", title: "测试标题2", images: ["https://pic.imgdb.cn/item/65df12989f345e8d033afff7.png"], ts: 1709117949996)
    ]
    static var intent = CommunityPage.buildContainer().intent
    
    static var previews: some View {
        CommunityPage.Carousel(baseContents: baseContents)
    }
}
