//
//  CommunitySubjectView_Articles.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI
import Kingfisher

extension CommunitySubjectView {
    
    struct Articles: View {
        var baseContents: [BaseContent]
        var action: ((_ id: String, _ type: String) -> Void)?
        
        var body: some View {
            VStack {
                ForEach(baseContents, id:\.id) { baseContent in
                    Button(action: { action?(baseContent.id, baseContent.type) }) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(baseContent.title)
                                .font(AppTheme.fonts.title1)
                                .foregroundColor(AppTheme.colors.fontPrimary)
                            if let intro = baseContent.intro, !intro.isEmpty {
                                Text(intro)
                                    .font(AppTheme.fonts.body)
                                    .foregroundColor(AppTheme.colors.fontSecondary)
                                    .lineLimit(3)
                            }
                            if let first = baseContent.images.first, let url = URL(string: first) {
                                KFImage(url)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 160)
                                    .clipped()
                                    .cornerRadius(AppTheme.layout.radiusMedium)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .appCardStyle()
                    Divider()
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                }
            }
            .padding(.top, 20)
        }
    }
}

struct CommunitySubjectView_Articles_Previews: PreviewProvider {
    static var baseContents: [BaseContent] = [
        BaseContent.init(id: "1", type: "article", title: "测试标题1", intro: "测试内容1测试内容1测试内容1测试内容1测试内容1测试内容1测试内容1", images: [
            "https://pic.imgdb.cn/item/65df360f9f345e8d03ae3131.png",
            "https://pic.imgdb.cn/item/65df360f9f345e8d03ae3131.png"
        ], ts: 1709275436479, location: "上海市"),
        BaseContent.init(id: "2", type: "article", title: "测试标题2", intro: "测试内容2测试内容2测试内容2测试内容2测试内容2测试内容2测试内容2测试内容2测试内容2测试内容2", images: [
            "https://pic.imgdb.cn/item/65df360f9f345e8d03ae3131.png",
            "https://pic.imgdb.cn/item/65df360f9f345e8d03ae3131.png"
        ], ts: 1709275436479, location: "上海市")
    ]
    static var previews: some View {
        CommunitySubjectView.Articles(baseContents: baseContents)
    }
}
