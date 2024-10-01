//
//  CommunityArticleView_Share.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension CommunityArticleView {
    struct Share: View {
        @Binding var showShare: Bool
        
        var body: some View {
            VStack {
                HStack {
                    Text("分享至")
                        .bold()
                    Spacer()
                }
                .padding(.bottom, 30)
                HStack {
                    Spacer()
                    VStack {
                        HStack {
                            Image("wechat_c")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                        .frame(width: 50, height: 50)
                        .background(Color.white)
                        .clipShape(.circle)
                        .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                        Text("微信")
                            .font(.system(size: 14))
                            .padding(.top, 5)
                    }
                    Spacer()
                    VStack {
                        HStack {
                            Image("wechat.moments_c")
                                .resizable()
                                .frame(width: 35, height: 35)
                        }
                        .frame(width: 50, height: 50)
                        .background(Color.white)
                        .clipShape(.circle)
                        .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                        Text("朋友圈")
                            .font(.system(size: 14))
                            .padding(.top, 5)
                    }
                    Spacer()
                    VStack {
                        HStack {
                            Image(systemName: "link")
                                .resizable()
                                .frame(width: 25, height: 25)
                        }
                        .frame(width: 50, height: 50)
                        .background(Color.white)
                        .clipShape(.circle)
                        .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                        Text("复制链接")
                            .font(.system(size: 14))
                            .padding(.top, 5)
                    }
                    Spacer()
                    VStack {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .resizable()
                                .frame(width: 25, height: 25)
                        }
                        .frame(width: 50, height: 50)
                        .background(Color.white)
                        .clipShape(.circle)
                        .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                        Text("举报")
                            .font(.system(size: 14))
                            .padding(.top, 5)
                    }
                    Spacer()
                }
                .padding(.bottom, 30)
                Button(action: { showShare = false }) {
                    Text("取消")
                        .background(.white)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct CommunityArticleView_Share_Previews: PreviewProvider {
    static var previews: some View {
        CommunityArticleView.Share(showShare: .constant(false))
    }
}
