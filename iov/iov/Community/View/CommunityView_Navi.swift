//
//  CommunityView_Navi.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import Kingfisher

extension CommunityView {
    struct Navi: View {
        var title: String?
        var baseContents: [BaseContent]
        var action: ((_ id: String, _ type: String) -> Void)?
        
        var body: some View {
            VStack {
                if let unwrapedTitle = title {
                    HStack {
                        Spacer()
                            .frame(width: 20)
                        Text(unwrapedTitle)
                            .bold()
                        Spacer()
                    }
                }
                HStack {
                    Spacer()
                    ForEach(baseContents, id: \.id) { baseContent in
                        Button(action: {
                            action?(baseContent.id, baseContent.type)
                        }) {
                            ZStack {
                                KFImage(URL(string: baseContent.images[0])!)
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(5)
                                Text(baseContent.title)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .padding(.top, 70)
                            }
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 20)
        }
    }
}


struct CommunityView_Navi_Previews: PreviewProvider {
    static var baseContents: [BaseContent] = [
        BaseContent.init(id: "1", type: "article", title: "最新活动", images: ["https://pic.imgdb.cn/item/65df202d9f345e8d03619d29.png"], ts: 1709121879408),
        BaseContent.init(id: "2", type: "article", title: "预约试驾", images: ["https://pic.imgdb.cn/item/65df254c9f345e8d0372105c.png"], ts: 1709122924212),
        BaseContent.init(id: "3", type: "article", title: "产品解读", images: ["https://pic.imgdb.cn/item/65df27319f345e8d03780cb0.png"], ts: 1709123418329)
    ]
    
    static var previews: some View {
        CommunityView.Navi(title: "进一步了解", baseContents: baseContents)
    }
}
