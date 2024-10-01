//
//  CommunityArticleView_Comment.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct CommunityArticleView_Comment: View {
    var comments: [ArticleComment] = []
    
    var body: some View {
        VStack {
            ForEach(comments, id: \.id) { comment in
                HStack(alignment: .top) {
                    if comment.id != comment.parentId {
                        Spacer()
                            .frame(width: 60)
                    }
                    AvatarImage(avatar: comment.avatar, width: 40)
                    Spacer()
                        .frame(width: 20)
                    VStack(alignment: .leading) {
                        Spacer()
                            .frame(height: 13)
                        HStack {
                            Text(comment.username)
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                            Spacer()
                            Image(systemName: "ellipsis")
                        }
                        Spacer()
                            .frame(height: 20)
                        HStack {
                            if let replyer = comment.replyer {
                                Text("回复\(replyer):")
                                    .bold()
                                    .font(.system(size: 14))
                            }
                            Text(comment.comment)
                                .font(.system(size: 14))
                        }
                        Spacer()
                            .frame(height: 10)
                        HStack {
                            Text(tsDisplay(ts: comment.ts))
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Text(comment.location ?? "")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        
    }
}

struct CommunityArticleView_Comment_Previews: PreviewProvider {
    static var comments: [ArticleComment] = [
        ArticleComment.init(id: "1", parentId: "1", comment: "测试评论1", ts: 1709261044490, username: "测试用户1", location: "江苏省"),
        ArticleComment.init(id: "3", parentId: "1", comment: "测试评论3", replyer: "测试用户1", ts: 1709261044490, username: "测试用户3", location: "上海市"),
        ArticleComment.init(id: "2", parentId: "2", comment: "测试评论2", ts: 1709261044490, username: "测试用户2", location: "山东省")
    ]
    
    static var previews: some View {
        CommunityArticleView_Comment(comments: comments)
    }
}
