//
//  CommunityView.swift
//  IOV
//
//  Created by 叶荣杰 on 2024/8/31.
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
        
        var body: some View {
            VStack {
                RefreshScrollView(offDown: CGFloat(state.contentBlocks.count) * 100.0, listH: ScreenH - kNavHeight - kBottomSafeHeight, refreshing: $isRefresh, isMore: $isMore) {
                    // 下拉刷新触发
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                        // 刷新完成，关闭刷新
                        intent.viewOnAppear()
                        isRefresh = false
                    })
                } moreTrigger: {
                    // 上拉加载更多触发
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                        // 加载完成，关闭加载
                        isMore = false
                    })
                } content: {
                    Content(intent: intent, contentBlocks: state.contentBlocks)
                }
                .scrollIndicators(.hidden)
                .ignoresSafeArea()
            }
        }
    }
    
    struct Content: View {
        let intent: CommunityIntentProtocol
        var contentBlocks: [ContentBlock] = []
        @EnvironmentObject var appGlobalState: AppGlobalState
        
        var body: some View {
            VStack {
                ForEach(contentBlocks, id: \.id) { contentBlock in
                    switch contentBlock.type {
                    case "carousel":
                        CommunityPage.Carousel(baseContents: contentBlock.data) { id, type in
                            appGlobalState.parameters["id"] = id
                            intent.onTapContent(type: type)
                        }
                    case "navigation":
                        CommunityPage.Navi(title: contentBlock.title, baseContents: contentBlock.data) { id, type in
                            appGlobalState.parameters["id"] = id
                            intent.onTapContent(type: type)
                        }
                        Divider()
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                    case "topic":
                        CommunityPage.Topic(contentBlock: contentBlock) { id, type in
                            appGlobalState.parameters["id"] = id
                            intent.onTapContent(type: type)
                        }
                        Divider()
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                    case "article":
                        CommunityPage.Article(baseContent: contentBlock.data[0]) { id, type in
                            appGlobalState.parameters["id"] = id
                            intent.onTapContent(type: type)
                        }
                        Divider()
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                    default:
                        EmptyView()
                    }
                }
                Spacer()
                    .frame(height: 100)
            }
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

