//
//  CommunityTopicView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import Kingfisher

struct CommunityTopicView: View {
    @StateObject var container: MviContainer<CommunityTopicIntentProtocol, CommunityTopicModelStateProtocol>
    private var intent: CommunityTopicIntentProtocol { container.intent }
    private var state: CommunityTopicModelStateProtocol { container.model }
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
                    topic: state.topic,
                    refreshAction: {
                        if appGlobalState.parameters.keys.contains("id") {
                            intent.viewOnAppear(id: appGlobalState.parameters["id"] as! String)
                        }
                    },
                    tapContentAction: { type in
                        intent.onTapContent(type: type)
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
            appGlobalState.currentView = "CommunityTopic"
        }
        .modifier(CommunityTopicRouter(
            subjects: state.routerSubject,
            intent: intent
        ))
    }
}

extension CommunityTopicView {
    
    struct Content: View {
        var topic: Topic
        var refreshAction: (() -> Void)?
        var tapContentAction: ((_ type: String) -> Void)?
        @EnvironmentObject var appGlobalState: AppGlobalState
        @State var isRefresh = false
        
        var body: some View {
            VStack {
                RefreshScrollView(offDown: 300.0 + CGFloat(topic.contents.count * 100), listH: ScreenH - kNavHeight - kBottomSafeHeight, refreshing: $isRefresh) {
                    // 下拉刷新触发
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                        // 刷新完成，关闭刷新
                        refreshAction?()
                        isRefresh = false
                    })
                } content: {
                    ZStack(alignment: .top) {
                        if let image = topic.image {
                            KFImage(URL(string: image)!)
                                .resizable()
                                .scaledToFit()
                        }
                        TopBackTitleBar(title: "", color: .white)
                            .padding(.top, 60)
                    }
                    VStack {
                        HStack {
                            Text(topic.title)
                                .bold()
                            Spacer()
                        }
                        .padding(20)
                        ForEach(topic.contents, id: \.id) { content in
                            Button(action: {
                                appGlobalState.parameters["id"] = content.id
                                tapContentAction?(content.type)
                            }) {
                                CommunityTopicView.Article(baseContent: content)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .ignoresSafeArea()
            }
        }
    }
}

// MARK: - Error View

private struct ErrorContent: View {
    let text: String

    var body: some View {
        ZStack {
            Color.white
            Text(text)
        }
    }
}

struct CommunityTopicView_Previews: PreviewProvider {
    static var topic: Topic = Topic.init(
        id: "1", title: "测试标题",
        image: "https://pic.imgdb.cn/item/65df4e159f345e8d0301a944.png",
        contents: [
            BaseContent.init(id: "1", type: "aritcle", title: "智能穿越助你探索山西", images: ["https://pic.imgdb.cn/item/65e012a79f345e8d03444608.png"], ts: 1709284625762, username: "hwyz_leo", avatar: "https://profile-photo.s3.cn-north-1.amazonaws.com.cn/files/avatar/50531/MTAxMDYzNDY0Nzd4d2h2cWFt/avatar.png?v=c4af49f3cbedbc00f76256a03298b663"),
            BaseContent.init(id: "2", type: "aritcle", title: "户外露营生活新选择", images: ["https://pic.imgdb.cn/item/65df3bb89f345e8d03c2306c.png"], ts: 1709284625762, username: "山高第九"),
            BaseContent.init(id: "3", type: "aritcle", title: "一键舒享的航空座椅", images: ["https://pic.imgdb.cn/item/65df13639f345e8d033d11fb.png"], ts: 1709284625762, username: "一起探索")
        ]
    )
    static var previews: some View {
        CommunityTopicView.Content(topic: topic)
    }
}
