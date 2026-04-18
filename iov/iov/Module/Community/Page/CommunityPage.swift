//
//  CommunityView.swift
//  IOV
//
//  Created by hwyz_leo on 2024/8/31.
//

import SwiftUI

struct CommunityPage: View {
    
    @StateObject var container: MviContainer<CommunityIntentProtocol, CommunityModelStateProtocol>
    private var intent: CommunityIntentProtocol { container.intent }
    private var state: CommunityModelStateProtocol { container.model }
    
    var body: some View {
        ZStack {
            switch state.contentState {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(2)
            case .content:
                RefreshContent(intent: intent, state: state)
            case let .error(text):
                ErrorTip(text: text)
            }
        }
        .background(AppTheme.colors.background) // 使用不忽略安全区的背景
        .onAppear {
            if state.contentBlocks.count == 0 {
                intent.viewOnAppear()
            }
        }
        .modifier(CommunityRouter(
            subjects: state.routerSubject,
            intent: intent
        ))
    }
}

extension CommunityPage {
    struct RefreshContent: View {
        let intent: CommunityIntentProtocol
        let state: CommunityModelStateProtocol
        @State var isRefresh = false
        @State var isMore = false
        @State private var searchText = ""
        @State private var selectedMenu = 0
        
        var body: some View {
            VStack(spacing: 0) {
                // 1. 顶部搜索区
                HStack(spacing: 16) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppTheme.colors.fontTertiary)
                        TextField(LocalizedStringKey("search_explore_placeholder"), text: $searchText)
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.colors.fontPrimary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppTheme.colors.cardBackground)
                    .cornerRadius(AppTheme.layout.radiusSmall)
                    
                    Button(action: { /* 发布逻辑 */ }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                            .foregroundColor(AppTheme.colors.brandMain)
                            .shadow(color: AppTheme.colors.brandMain.opacity(0.3), radius: 5)
                    }
                }
                .padding(.horizontal, AppTheme.layout.margin)
                .padding(.top, 10) // 这里的 padding 会在安全区域之后累加
                .padding(.bottom, 16)
                
                // 2. 二级导航菜单
                HStack(spacing: 32) {
                    MenuItem(title: "推荐", isSelected: selectedMenu == 0) { selectedMenu = 0 }
                    MenuItem(title: "活动", isSelected: selectedMenu == 1) { selectedMenu = 1 }
                    MenuItem(title: "此地", isSelected: selectedMenu == 2) { selectedMenu = 2 }
                    Spacer()
                }
                .padding(.horizontal, AppTheme.layout.margin)
                .padding(.bottom, 12)
                
                // 3. 内容滚动区
                RefreshScrollView(offDown: CGFloat(state.contentBlocks.count) * 100.0, listH: ScreenH - kNavHeight - kBottomSafeHeight - 100, refreshing: $isRefresh, isMore: $isMore) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                        intent.viewOnAppear()
                        isRefresh = false
                    })
                } moreTrigger: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                        isMore = false
                    })
                } content: {
                    Content(intent: intent, contentBlocks: state.contentBlocks)
                }
                .scrollIndicators(.hidden)
            }
            .background(AppTheme.colors.background) // 不使用 .appBackground() 以免忽略安全区
        }
    }
    
    private struct MenuItem: View {
        var title: String
        var isSelected: Bool
        var action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                        .foregroundColor(isSelected ? AppTheme.colors.fontPrimary : AppTheme.colors.fontSecondary)
                    
                    if isSelected {
                        Capsule()
                            .fill(AppTheme.colors.brandMain)
                            .frame(width: 16, height: 3)
                    } else {
                        Capsule().fill(Color.clear).frame(width: 16, height: 3)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    struct Content: View {
        let intent: CommunityIntentProtocol
        var contentBlocks: [ContentBlock] = []
        @EnvironmentObject var appGlobalState: AppGlobalState
        
        var body: some View {
            VStack(spacing: AppTheme.layout.spacing) {
                ForEach(contentBlocks, id: \.id) { contentBlock in
                    switch contentBlock.type {
                    case "carousel":
                        CommunityPage.Carousel(baseContents: contentBlock.data) { id, type in
                            appGlobalState.parameters["id"] = id
                            intent.onTapContent(type: type)
                        }
                        .padding(.horizontal, AppTheme.layout.margin)
                    case "navigation":
                        CommunityPage.Navi(title: contentBlock.title, baseContents: contentBlock.data) { id, type in
                            appGlobalState.parameters["id"] = id
                            intent.onTapContent(type: type)
                        }
                        .padding(.horizontal, AppTheme.layout.margin)
                    case "topic":
                        CommunityPage.Topic(contentBlock: contentBlock) { id, type in
                            appGlobalState.parameters["id"] = id
                            intent.onTapContent(type: type)
                        }
                        .padding(.horizontal, AppTheme.layout.margin)
                    case "article":
                        CommunityPage.Article(baseContent: contentBlock.data[0]) { id, type in
                            appGlobalState.parameters["id"] = id
                            intent.onTapContent(type: type)
                        }
                        .padding(.horizontal, AppTheme.layout.margin)
                    default:
                        EmptyView()
                    }
                }
                Spacer()
                    .frame(height: 120)
            }
            .padding(.top, 20)
        }
    }
}

struct CommunityView_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState.shared
    static var data: [ContentBlock] = [
        ContentBlock.init(id: "1", type: "carousel", data: [
            BaseContent.init(id: "1", type: "article", title: "尽享雪地之美", intro: "", images: ["https://pic.imgdb.cn/item/65df049a9f345e8d031861c3.png"], ts: 1709114457603),
            BaseContent.init(id: "2", type: "", title: "露营最佳伴侣", intro: "", images: ["https://pic.imgdb.cn/item/65df12989f345e8d033afff7.png"], ts: 1709114457603),
            BaseContent.init(id: "4", type: "", title: "霸气尽显", intro: "", images: ["https://pic.imgdb.cn/item/65df13699f345e8d033d24f6.png"], ts: 1709114457603)
        ]),
        ContentBlock.init(id: "2", type: "navigation", data: [
            BaseContent.init(id: "1", type: "topic", title: "最新活动", images: ["https://pic.imgdb.cn/item/65df202d9f345e8d03619d29.png"], ts: 1709121879408),
            BaseContent.init(id: "2", type: "article", title: "预约试驾", images: ["https://pic.imgdb.cn/item/65df254c9f345e8d0372105c.png"], ts: 1709122924212),
            BaseContent.init(id: "3", type: "subject", title: "产品解读", images: ["https://pic.imgdb.cn/item/65df27319f345e8d03780cb0.png"], ts: 1709123418329)
        ]),
        ContentBlock.init(id: "3", type: "article", data: [
            BaseContent.init(
                id: "1", type: "article", title: "开源汽车——旅途的最佳伴侣!",
                intro: "趁春节假期，一家四口回了趟四川老家，途径乐山、石棉、泸定、康定、宜宾等地，总……",
                images: [
                    "https://pic.imgdb.cn/item/65df360f9f345e8d03ae3131.png",
                    "https://pic.imgdb.cn/item/65e0201e9f345e8d03620461.png",
                    "https://pic.imgdb.cn/item/65df4e159f345e8d0301a944.png",
                    "https://pic.imgdb.cn/item/65df55069f345e8d0318a51c.png"
                ],
                ts: 1709124212841, username: "hwyz_leo",
                avatar: "https://profile-photo.s3.cn-north-1.amazonaws.com.cn/files/avatar/50531/MTAxMDYzNDY0Nzd4d2h2cWFt/avatar.png?v=c4af49f3cbedbc00f76256a03298b663",
                location: "万达广场",
                commentCount: 3,
                likeCount: 13
            )
        ]),
        ContentBlock.init(id: "4", type: "topic", title: "北境之旅，开源出发", data: [
            BaseContent.init(id: "1", type: "article", title: "首批车主用车心声", images: ["https://pic.imgdb.cn/item/65e012a79f345e8d03444608.png"], ts: 1709182971760),
            BaseContent.init(id: "2", type: "article", title: "沉浸式露营", images: ["https://pic.imgdb.cn/item/65df12989f345e8d033afff7.png"], ts: 1709182971760),
            BaseContent.init(id: "3", type: "article", title: "内饰揭秘", images: ["https://pic.imgdb.cn/item/65df13639f345e8d033d11fb.png"], ts: 1709182971760),
            BaseContent.init(id: "4", type: "article", title: "城市穿越", images: ["https://pic.imgdb.cn/item/65df13699f345e8d033d24f6.png"], ts: 1709182971760)
        ])
    ]
    static var previews: some View {
        let container = CommunityPage.buildContainer()
        ScrollView {
            CommunityPage.Content(intent: container.intent, contentBlocks: data)
                .environmentObject(appGlobalState)
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea()
    }
}

