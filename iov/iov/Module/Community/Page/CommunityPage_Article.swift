//
//  CommunityView_Article.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import Kingfisher

extension CommunityPage {
    
    struct Article: View {
        var baseContent: BaseContent
        var action: ((_ id: String, _ type: String) -> Void)?
        
        var body: some View {
            VStack(alignment: .leading) {
                VStack {
                    HStack(alignment: .top) {
                        AvatarImage(avatar: baseContent.avatar ?? "", width: 50)
                        VStack(alignment: .leading) {
                            Text(baseContent.username ?? "")
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                            Spacer()
                                .frame(height: 5)
                            Text(tsDisplay(ts: baseContent.ts))
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    Button(action: {
                        action?(baseContent.id, baseContent.type)
                    }) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(baseContent.title)
                                    .bold()
                                    .font(.system(size: 18))
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            Spacer()
                                .frame(height: 10)
                            Text(baseContent.intro ?? "")
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .lineSpacing(5)
                        }
                    }
                    .buttonStyle(.plain)
                    Spacer()
                        .frame(height: 10)
                    if let tags = baseContent.tags {
                        HStack {
                            VStack {
                                ForEach(Array(tags.enumerated()), id: \.0) { index, tag in
                                    Text("# \(tag)")
                                        .font(.system(size: 12))
                                }
                            }
                            .padding(5)
                            .background(Color(hex: 0xf2f2f2))
                            .cornerRadius(10)
                            Spacer()
                        }
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                Spacer()
                    .frame(height: 10)
                if baseContent.images.count > 0 {
                    HStack {
                        if baseContent.images.count == 1 {
                            Spacer()
                            KFImage(URL(string: baseContent.images[0])!)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(width: 350, height: 200)
                                .clipped()
                            Spacer()
                        } else if baseContent.images.count > 1 {
                            Spacer()
                            KFImage(URL(string: baseContent.images[0])!)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 175, height: 175)
                                .clipped()
                            Spacer()
                            KFImage(URL(string: baseContent.images[1])!)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(width: 175, height: 175)
                                .clipped()
                            Spacer()
                        }
                    }
                    if baseContent.images.count > 2 {
                        HStack {
                            if baseContent.images.count == 3 {
                                Spacer()
                                KFImage(URL(string: baseContent.images[2])!)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(width: 350, height: 200)
                                    .clipped()
                                Spacer()
                            } else if baseContent.images.count > 3 {
                                Spacer()
                                KFImage(URL(string: baseContent.images[2])!)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 175, height: 175)
                                    .clipped()
                                Spacer()
                                KFImage(URL(string: baseContent.images[3])!)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 175, height: 175)
                                    .clipped()
                                Spacer()
                            }
                        }
                    }
                    Spacer()
                        .frame(height: 10)
                }
                HStack {
                    Button(action: {
                        action?(baseContent.id, baseContent.type)
                    }) {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.gray)
                        Text(baseContent.location ?? "")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    Button(action: {
                        action?(baseContent.id, baseContent.type)
                    }) {
                        Image(systemName: "bubble")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                        Text("\(baseContent.commentCount ?? 0)")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    }
                    Spacer()
                        .frame(width: 20)
                    Image(systemName: "hand.thumbsup")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                    Text("\(baseContent.likeCount ?? 0)")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
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
