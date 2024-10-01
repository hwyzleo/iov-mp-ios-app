//
//  CommunitySubjectView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import Kingfisher

struct CommunitySubjectView: View {
    @StateObject var container: MviContainer<CommunitySubjectIntentProtocol, CommunitySubjectModelStateProtocol>
    private var intent: CommunitySubjectIntentProtocol { container.intent }
    private var state: CommunitySubjectModelStateProtocol { container.model }
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
                    subject: state.subject,
                    refreshAction: {
                        if appGlobalState.parameters.keys.contains("id") {
                            intent.viewOnAppear(id: appGlobalState.parameters["id"] as! String)
                        }
                    },
                    tapContentAction: { id, type in
                        appGlobalState.parameters["id"] = id
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
            appGlobalState.currentView = "CommunitySubject"
        }
        .modifier(CommunitySubjectRouter(
            subjects: state.routerSubject,
            intent: intent
        ))
    }
}

extension CommunitySubjectView {
    struct Content: View {
        var subject: Subject
        var refreshAction: (() -> Void)?
        var tapContentAction: ((_ id: String, _ type: String) -> Void)?
        @State var isRefresh = false
        @State var isMore = false
        
        var body: some View {
            VStack {
                RefreshScrollView(offDown: 500.0, listH: ScreenH - kNavHeight - kBottomSafeHeight, refreshing: $isRefresh, isMore: $isMore) {
                    // 下拉刷新触发
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                        // 刷新完成，关闭刷新
                        refreshAction?()
                        isRefresh = false
                    })
                } moreTrigger: {
                    // 上拉加载更多触发
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                        // 加载完成，关闭加载
                        isMore = false
                    })
                } content: {
                    ZStack(alignment: .top) {
                        if let image = subject.image {
                            KFImage(URL(string: image)!)
                                .resizable()
                                .frame(height: 300)
                                .scaledToFit()
                        }
                        TopBackTitleBar(title: "话题", color: .white)
                            .padding(.top, 60)
                        VStack {
                            VStack(alignment: .leading) {
                                Spacer()
                                    .frame(height: 10)
                                HStack {
                                    Text("# \(subject.title)")
                                        .font(.system(size: 20))
                                        .bold()
                                    Spacer()
                                }
                                .padding(10)
                                Spacer()
                                    .frame(height: 10)
                                Text(subject.content ?? "")
                                    .padding(10)
                                Spacer()
                                    .frame(height: 10)
                                HStack {
                                    ZStack(alignment: .leading) {
                                        AvatarImage(avatar: "https://img1.doubanio.com/icon/ul173067863-19.jpg", width: 25)
                                            .padding(0)
                                        AvatarImage(avatar: "https://profile-photo.s3.cn-north-1.amazonaws.com.cn/files/avatar/50531/MTAxMDYzNDY0Nzd4d2h2cWFt/avatar.png?v=c4af49f3cbedbc00f76256a03298b663", width: 25)
                                            .padding(0)
                                            .padding(.leading, 12)
                                        AvatarImage(avatar: "https://img2.doubanio.com/icon/ul151927045-1.jpg", width: 25)
                                            .padding(0)
                                            .padding(.leading, 24)
                                    }
                                    Text("\(subject.userCount)人参与 | \(subject.articleCount)条内容")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                                .padding(10)
                                HStack {
                                    if let endTs = subject.endTs {
                                        Text("剩余")
                                        Text(calCountDown(endTs: endTs))
                                    }
                                    Spacer()
                                    Text("查看奖品>")
                                }
                                .padding(10)
                                .font(.system(size: 15))
                                .foregroundColor(Color(hex: 0x5c2123))
                                .background(Color(hex: 0xf2eceb))
                            }
                            .frame(maxWidth: .infinity)
                            .background(.white)
                            .cornerRadius(5)
                            .shadow(color: Color.gray, radius: 0.5, x: 0, y: 0)
                        }
                        .padding(20)
                        .padding(.top, 200)
                    }
                    LabelTabView(tabs: ["默认", "最新"], views: [
                        AnyView(CommunitySubjectView.Articles(baseContents: subject.defaultContent) { id, type in
                            tapContentAction?(id, type)
                        }),
                        AnyView(CommunitySubjectView.Articles(baseContents: subject.latestContent) { id, type in
                            tapContentAction?(id, type)
                        })
                    ])
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                }
                .scrollIndicators(.hidden)
                .ignoresSafeArea()
            }
        }
    }
}

struct CommunitySubjectView_Previews: PreviewProvider {
    static var subject: Subject = Subject.init(
        id: "1",
        title: "测试标题",
        content: "本期话题：测试内容",
        image: "https://pic.imgdb.cn/item/65df049a9f345e8d031861c3.png",
        endTs: 1709827199000,
        userCount: 0,
        articleCount: 0,
        defaultContent: [
            BaseContent.init(id: "1", type: "article", title: "测试标题1", intro: "测试内容1测试内容1测试内容1测试内容1测试内容1测试内容1测试内容1", images: [
                "https://pic.imgdb.cn/item/65df360f9f345e8d03ae3131.png",
                "https://pic.imgdb.cn/item/65df360f9f345e8d03ae3131.png"
            ], ts: 1709275436479, location: "上海市"),
            BaseContent.init(id: "2", type: "article", title: "测试标题2", intro: "测试内容2测试内容2测试内容2测试内容2测试内容2测试内容2测试内容2测试内容2测试内容2测试内容2", images: [
                "https://pic.imgdb.cn/item/65df360f9f345e8d03ae3131.png",
                "https://pic.imgdb.cn/item/65df360f9f345e8d03ae3131.png"
            ], ts: 1709275436479, location: "上海市")
        ],
        latestContent: []
    )
    static var previews: some View {
        CommunitySubjectView.Content(subject: subject)
    }
}
