//
//  CommunitySubjectView_Articles.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension CommunitySubjectView {
    
    struct Articles: View {
        var baseContents: [BaseContent]
        var action: ((_ id: String, _ type: String) -> Void)?
        
        var body: some View {
            VStack {
                ForEach(baseContents, id:\.id) { baseContent in
                    CommunityView.Article(baseContent: baseContent) { id, type in
                        action?(id, type)
                    }
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
