//
//  CommunityView_Topic.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI
import Kingfisher

extension CommunityPage {
    struct Topic: View {
        var contentBlock: ContentBlock
        var action: ((_ id: String, _ type: String) -> Void)?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(contentBlock.title ?? "")
                        .font(AppTheme.fonts.title1)
                        .bold()
                        .foregroundColor(AppTheme.colors.fontPrimary)
                    Spacer()
                    Button(action: {
                        action?(contentBlock.id, "topic")
                    }) {
                        HStack(spacing: 4) {
                            Text("查看更多")
                                .font(.system(size: 14))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(AppTheme.colors.fontSecondary)
                    }
                    .buttonStyle(.plain)
                }
                
                if contentBlock.data.count > 0 {
                    // 使用 2 列等分网格，间距 12pt
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 16) {
                        ForEach(contentBlock.data.prefix(4), id: \.id) { item in
                            Button(action: {
                                action?(item.id, item.type)
                            }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    if !item.images.isEmpty {
                                        KFImage(URL(string: item.images[0])!)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                            .frame(height: 110) // 强制固定高度防止重叠
                                            .cornerRadius(AppTheme.layout.radiusMedium)
                                            .clipped()
                                    }
                                    
                                    Text(item.title)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppTheme.colors.fontPrimary)
                                        .lineLimit(1)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .appCardStyle()
        }
    }
}


struct CommunityView_Topic_Previews: PreviewProvider {
    static var contentBlock: ContentBlock = ContentBlock.init(id: "1", type: "topic", title: "北境之旅，开源出发", data: [
        BaseContent.init(id: "1", type: "article", title: "首批车主用车心声", images: ["https://pic.imgdb.cn/item/65e012a79f345e8d03444608.png"], ts: 1709182971760),
        BaseContent.init(id: "2", type: "article", title: "沉浸式露营", images: ["https://pic.imgdb.cn/item/65df12989f345e8d033afff7.png"], ts: 1709182971760),
        BaseContent.init(id: "3", type: "article", title: "内饰揭秘", images: ["https://pic.imgdb.cn/item/65df13639f345e8d033d11fb.png"], ts: 1709182971760),
        BaseContent.init(id: "4", type: "article", title: "城市穿越", images: ["https://pic.imgdb.cn/item/65df13699f345e8d033d24f6.png"], ts: 1709182971760)
    ])
    static var previews: some View {
        CommunityPage.Topic(contentBlock: contentBlock)
    }
}
