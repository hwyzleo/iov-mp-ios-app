//
//  CommunityTopicView_Article.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import Kingfisher

extension CommunityTopicView {
    
    struct Article: View {
        var baseContent: BaseContent
        
        var body: some View {
            HStack(alignment: .top) {
                if baseContent.images.count > 0 {
                    KFImage(URL(string: baseContent.images[0])!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipped()
                        .cornerRadius(5)
                }
                Spacer()
                    .frame(width: 15)
                VStack(alignment: .leading) {
                    Text(baseContent.title)
                        .bold()
                        .foregroundColor(.black)
                    Spacer()
                        .frame(height: 60)
                    HStack {
                        AvatarImage(avatar: baseContent.avatar, width: 25)
                        Text(baseContent.username ?? "")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    }
                }
                Spacer()
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.bottom, 10)
        }
    }
}


struct CommunityTopicView_Topic_Previews: PreviewProvider {
    static var baseContent: BaseContent = BaseContent.init(
        id: "1", type: "article",
        title: "一键舒享的航空座椅",
        images: ["https://pic.imgdb.cn/item/65df13639f345e8d033d11fb.png"],
        ts: 1709285053159
    )
    static var previews: some View {
        CommunityTopicView.Article(baseContent: baseContent)
    }
}
