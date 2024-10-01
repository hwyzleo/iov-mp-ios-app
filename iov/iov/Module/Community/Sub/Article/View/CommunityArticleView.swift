//
//  CommunityArticleView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct CommunityArticleView: View {
    @StateObject var container: MviContainer<CommunityArticleIntentProtocol, CommunityArticleModelStateProtocol>
    private var intent: CommunityArticleIntentProtocol { container.intent }
    private var state: CommunityArticleModelStateProtocol { container.model }
    @EnvironmentObject var appGlobalState: AppGlobalState
    
    var body: some View {
        ZStack {
            switch state.contentState {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(2)
            case .content:
                Content(
                    article: state.article,
                    likeCount: state.article.likeCount,
                    liked: state.article.liked,
                    refreshAction: {
                        if appGlobalState.parameters.keys.contains("id") {
                            intent.viewOnAppear(id: appGlobalState.parameters["id"] as! String)
                        }
                    },
                    tapLikeAction: {
                        intent.onTapLike(id: state.article.id, liked: !state.article.liked)
                    }
                )
            case let .error(text):
                ErrorTip(text: text)
            }
        }
        .onAppear {
            if appGlobalState.parameters.keys.contains("id") {
                intent.viewOnAppear(id: appGlobalState.parameters["id"] as! String)
            }
            appGlobalState.currentView = "CommunityArticle"
        }
        .modifier(CommunityArticleRouter(
            subjects: state.routerSubject,
            intent: intent
        ))
    }
}

extension CommunityArticleView {
    struct Content: View {
        var article: Article
        @State var comment: String = ""
        @State var likeCount: Int64 = 0
        @State var liked: Bool = false
        var refreshAction: (() -> Void)?
        var tapLikeAction: (() -> Void)?
        @State private var showShare = false
        @State private var showHiddenBar = false
        @State var isRefresh = false
        @State var isMore = false
        
        var body: some View {
            ZStack(alignment: .top) {
                VStack {
                    RefreshScrollView(offDown: 500.0, listH: ScreenH - kNavHeight - kBottomSafeHeight, refreshing: $isRefresh, isMore: $isMore) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                            refreshAction?()
                            isRefresh = false
                        })
                    } moreTrigger: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                            isMore = false
                        })
                    } content: {
                        ZStack(alignment: .top) {
                            GeometryReader { geometry in
                                Color.clear
                                    .onChange(of: geometry.frame(in: .global).minY) { value in
                                        showHiddenBar = value < 0
                                    }
                            }
                            .frame(height: 0)
                            CommunityArticleView.Carousel(images: article.images)
                        }
                        VStack(alignment: .leading) {
                            HStack {
                                AvatarImage(avatar: article.avatar ?? "")
                                Spacer()
                                    .frame(width: 10)
                                VStack(alignment: .leading) {
                                    Text(article.username)
                                    Spacer()
                                        .frame(height: 10)
                                    HStack {
                                        Text(tsDisplay(ts: article.ts))
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                        Text("\(article.views)次浏览")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                        Text(article.location ?? "")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                }
                                Spacer()
                            }
                            Spacer()
                                .frame(height: 20)
                            HStack {
                                Text(article.title)
                                    .font(.system(size: 18))
                                    .bold()
                            }
                            HStack {
                                ForEach(Array(article.tags.enumerated()), id: \.0) { index, tag in
                                    Text("# \(tag)")
                                        .font(.system(size: 12))
                                }
                            }
                            .padding(5)
                            .background(Color(hex: 0xf2f2f2))
                            .cornerRadius(10)
                            Text(article.content)
                            Spacer()
                                .frame(height: 50)
                            Text("评论")
                                .bold()
                            Spacer()
                                .frame(height: 20)
                            CommunityArticleView_Comment(comments: article.comments)
                        }
                        .padding(20)
                    }
                    .scrollIndicators(.hidden)
                    .ignoresSafeArea()
                    HStack {
                        TextField("说点什么吧", text: $comment)
                        VStack {
                            Image(systemName: "bubble")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                            Text("\(article.comments.count)")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                        }
                        Spacer()
                            .frame(width: 40)
                        Button(action: {
                            tapLikeAction?()
                            if(liked) {
                                likeCount -= 1
                            } else {
                                likeCount += 1
                            }
                            liked = !liked
                        }) {
                            VStack {
                                if liked {
                                    Image(systemName: "hand.thumbsup.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.black)
                                } else {
                                    Image(systemName: "hand.thumbsup")
                                        .font(.system(size: 14))
                                        .foregroundColor(.black)
                                }
                                Text("\(likeCount)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                            }
                        }
                        .buttonStyle(.plain)
                        Spacer()
                            .frame(width: 40)
                        Button(action: { showShare = true }) {
                            VStack {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                Text("\(article.shareCount)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(.top, 10)
                }
                .sheet(isPresented: $showShare) {
                    CommunityArticleView.Share(showShare: $showShare)
                        .padding(20)
                        .presentationDetents([.height(250)])
                }
                TopBackTitleBar()
                    .background(.white)
                    .opacity(showHiddenBar ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5), value: showHiddenBar)
                TopBackTitleBar(color: .white)
                    .opacity(showHiddenBar ? 0 : 1)
                    .animation(.easeInOut(duration: 0.5), value: showHiddenBar)
            }
        }
    }
}

struct CommunityArticleView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityArticleView.Content(article: mockArticle())
    }
}
