//
//  CommunityTopicView_Article.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI
import Kingfisher

extension CommunityTopicView {
    
    struct Article: View {
        var baseContent: BaseContent
        
        var body: some View {
            HStack(alignment: .top, spacing: 16) {
                if baseContent.images.count > 0 {
                    KFImage(URL(string: baseContent.images[0])!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .cornerRadius(AppTheme.layout.radiusSmall)
                        .clipped()
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(baseContent.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(AppTheme.colors.fontPrimary)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        AvatarImage(avatar: baseContent.avatar, width: 20)
                        Text(baseContent.username ?? "")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.colors.fontSecondary)
                    }
                }
                Spacer()
            }
            .appCardStyle(radius: AppTheme.layout.radiusMedium)
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
