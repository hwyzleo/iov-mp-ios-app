//
//  CommunityView_Article.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI
import Kingfisher

extension CommunityPage {
    
    struct Article: View {
        var baseContent: BaseContent
        var action: ((_ id: String, _ type: String) -> Void)?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                // 用户信息
                HStack(alignment: .center, spacing: 12) {
                    AvatarImage(avatar: baseContent.avatar ?? "", width: 44)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(baseContent.username ?? "")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(AppTheme.colors.fontPrimary)
                        Text(tsDisplay(ts: baseContent.ts))
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.colors.fontSecondary)
                    }
                    Spacer()
                }
                
                // 内容点击区域
                Button(action: {
                    action?(baseContent.id, baseContent.type)
                }) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(baseContent.title)
                            .font(AppTheme.fonts.title1)
                            .bold()
                            .foregroundColor(AppTheme.colors.fontPrimary)
                        
                        Text(baseContent.intro ?? "")
                            .font(AppTheme.fonts.body)
                            .foregroundColor(AppTheme.colors.fontSecondary)
                            .lineLimit(3)
                            .lineSpacing(4)
                    }
                }
                .buttonStyle(.plain)
                
                // 标签展示
                if let tags = baseContent.tags, !tags.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(tags, id: \.self) { tag in
                            Text("# \(tag)")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.colors.brandMain)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(AppTheme.layout.radiusSmall)
                        }
                    }
                }
                
                // 图片展示
                if baseContent.images.count > 0 {
                    ImageGrid(images: baseContent.images)
                }
                
                // 底部交互
                HStack(spacing: 24) {
                    LabelItem(icon: "mappin.and.ellipse", text: baseContent.location ?? "")
                    Spacer()
                    LabelItem(icon: "bubble", text: "\(baseContent.commentCount ?? 0)")
                    LabelItem(icon: "hand.thumbsup", text: "\(baseContent.likeCount ?? 0)")
                }
                .padding(.top, 8)
            }
            .appCardStyle()
        }
    }
}

// MARK: - 辅助子组件
private struct ImageGrid: View {
    var images: [String]
    
    var body: some View {
        let displayImages = Array(images.prefix(4))
        
        Group {
            if displayImages.count == 1 {
                // 1张图：全宽
                KFImage(URL(string: displayImages[0])!)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(AppTheme.layout.radiusMedium)
                    .clipped()
            } else if displayImages.count == 2 {
                // 2张图：并排
                HStack(spacing: 8) {
                    ForEach(displayImages, id: \.self) { url in
                        KFImage(URL(string: url)!)
                            .resizable()
                            .scaledToFill()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 120)
                            .cornerRadius(AppTheme.layout.radiusMedium)
                            .clipped()
                    }
                }
            } else {
                // 3-4张图：2x2 田字格
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                    ForEach(displayImages, id: \.self) { url in
                        KFImage(URL(string: url)!)
                            .resizable()
                            .scaledToFill()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 100)
                            .cornerRadius(AppTheme.layout.radiusMedium)
                            .clipped()
                    }
                }
            }
        }
    }
}

private struct LabelItem: View {
    var icon: String
    var text: String
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
            Text(text)
                .font(.system(size: 13))
        }
        .foregroundColor(AppTheme.colors.fontSecondary)
    }
}


struct CommunityView_Article_Previews: PreviewProvider {
    static var baseContent: BaseContent = BaseContent.init(
        id: "1", type: "article",
        title: "测试标题",
        intro: "测试简介测试简介测试简介测试简介测试简介测试简介测试简介测试简介测试简介测试简介……",
        images: [
            "https://pic.imgdb.cn/item/65df360f9f345e8d03ae3131.png",
            "https://pic.imgdb.cn/item/65df360f9f345e8d03ae3131.png",
            "https://pic.imgdb.cn/item/65df360f9f345e8d03ae3131.png",
            "https://pic.imgdb.cn/item/65df360f9f345e8d03ae3131.png"
        ],
        ts: 1709124212841, username: "hwyz_leo",
        avatar: "https://profile-photo.s3.cn-north-1.amazonaws.com.cn/files/avatar/50531/MTAxMDYzNDY0Nzd4d2h2cWFt/avatar.png?v=c4af49f3cbedbc00f76256a03298b663",
        location: "测试定位",
        tags: ["测试标签"],
        commentCount: 4,
        likeCount: 12
    )
    
    static var previews: some View {
        CommunityPage.Article(baseContent: baseContent)
    }
}
