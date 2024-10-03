//
//  CommunityView_Topic.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import Kingfisher

extension CommunityPage {
    struct Topic: View {
        var contentBlock: ContentBlock
        var action: ((_ id: String, _ type: String) -> Void)?
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text(contentBlock.title ?? "")
                        .font(.system(size: 18))
                        .bold()
                    Spacer()
                    Button(action: {
                        action?(contentBlock.id, "topic")
                    }) {
                        Text("查看更多")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                if contentBlock.data.count > 0 {
                    HStack {
                        Spacer()
                        Button(action: {
                            action?(contentBlock.data[0].id, contentBlock.data[0].type)
                        }) {
                            VStack(alignment: .leading) {
                                KFImage(URL(string: contentBlock.data[0].images[0])!)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 175, height: 175)
                                    .clipped()
                                Text(contentBlock.data[0].title)
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                            }
                        }
                        .buttonStyle(.plain)
                        Spacer()
                        if contentBlock.data.count > 1 {
                            Button(action: {
                                action?(contentBlock.data[1].id, contentBlock.data[1].type)
                            }) {
                                VStack(alignment: .leading) {
                                    KFImage(URL(string: contentBlock.data[1].images[0])!)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 175, height: 175)
                                        .clipped()
                                    Text(contentBlock.data[1].title)
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                }
                            }
                            .buttonStyle(.plain)
                            Spacer()
                        }
                    }
                    if contentBlock.data.count > 2 {
                        HStack {
                            Spacer()
                            Button(action: {
                                action?(contentBlock.data[2].id, contentBlock.data[2].type)
                            }) {
                                VStack(alignment: .leading) {
                                    KFImage(URL(string: contentBlock.data[2].images[0])!)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 175, height: 175)
                                        .clipped()
                                    Text(contentBlock.data[2].title)
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                }
                            }
                            .buttonStyle(.plain)
                            Spacer()
                            if contentBlock.data.count > 3 {
                                Button(action: {
                                    action?(contentBlock.data[3].id, contentBlock.data[3].type)
                                }) {
                                    VStack(alignment: .leading) {
                                        KFImage(URL(string: contentBlock.data[3].images[0])!)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 175, height: 175)
                                            .clipped()
                                        Text(contentBlock.data[3].title)
                                            .font(.system(size: 16))
                                            .foregroundColor(.black)
                                    }
                                }
                                .buttonStyle(.plain)
                                Spacer()
                            }
                        }
                    }
                }
            }
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
