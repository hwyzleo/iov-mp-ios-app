//
//  CommunityArticleView.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
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
        .appBackground()
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
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                AvatarImage(avatar: article.avatar ?? "", width: 44)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(article.username)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(AppTheme.colors.fontPrimary)
                                    HStack {
                                        Text(tsDisplay(ts: article.ts))
                                        Text("·")
                                        Text("\(article.views)次浏览")
                                        Text("·")
                                        Text(article.location ?? "")
                                    }
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.colors.fontSecondary)
                                }
                                Spacer()
                            }
                            
                            Text(article.title)
                                .font(AppTheme.fonts.title1)
                                .bold()
                                .foregroundColor(AppTheme.colors.fontPrimary)
                            
                            HStack(spacing: 8) {
                                ForEach(article.tags, id: \.self) { tag in
                                    Text("# \(tag)")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppTheme.colors.brandMain)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(AppTheme.layout.radiusSmall)
                                }
                            }
                            
                            Text(article.content)
                                .font(AppTheme.fonts.body)
                                .foregroundColor(AppTheme.colors.fontPrimary)
                                .lineSpacing(6)
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            Text("评论")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.colors.fontPrimary)
                            
                            CommunityArticleView_Comment(comments: article.comments)
                        }
                        .padding(AppTheme.layout.margin)
                    }
                    .scrollIndicators(.hidden)
                    .ignoresSafeArea()
                    
                    // 底部交互栏
                    HStack(spacing: 20) {
                        TextField("说点什么吧", text: $comment)
                            .padding(12)
                            .background(AppTheme.colors.cardBackground)
                            .cornerRadius(AppTheme.layout.radiusSmall)
                        
                        InteractionButton(icon: "bubble", count: "\(article.comments.count)")
                        
                        Button(action: {
                            tapLikeAction?()
                            if liked { likeCount -= 1 } else { likeCount += 1 }
                            liked.toggle()
                        }) {
                            InteractionButton(icon: liked ? "hand.thumbsup.fill" : "hand.thumbsup", count: "\(likeCount)", active: liked)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: { showShare = true }) {
                            InteractionButton(icon: "square.and.arrow.up", count: "\(article.shareCount)")
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, AppTheme.layout.margin)
                    .padding(.vertical, 12)
                    .background(AppTheme.colors.background)
                }
                .sheet(isPresented: $showShare) {
                    CommunityArticleView.Share(showShare: $showShare)
                        .padding(20)
                        .presentationDetents([.height(250)])
                        .preferredColorScheme(.dark)
                }
                
                TopBackTitleBar()
                    .background(AppTheme.colors.background)
                    .opacity(showHiddenBar ? 1 : 0)
                
                TopBackTitleBar(color: .white)
                    .opacity(showHiddenBar ? 0 : 1)
            }
        }
    }
}

private struct InteractionButton: View {
    var icon: String
    var count: String
    var active: Bool = false
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(active ? AppTheme.colors.brandMain : AppTheme.colors.fontPrimary)
            Text(count)
                .font(.system(size: 10))
                .foregroundColor(AppTheme.colors.fontSecondary)
        }
    }
}

struct CommunityArticleView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityArticleView.Content(article: mockArticle())
    }
}
