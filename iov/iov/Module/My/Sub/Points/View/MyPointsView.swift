//
//  MyPointsView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct MyPointsView: View {
    
    @StateObject var container: MviContainer<MyPointsIntentProtocol, MyPointsModelStateProtocol>
    private var intent: MyPointsIntentProtocol { container.intent }
    private var state: MyPointsModelStateProtocol { container.model }
    @EnvironmentObject var appGlobalState: AppGlobalState
    
    var body: some View {
        VStack {
            TopBackTitleBar(title: "我的积分")
            VStack {
                Spacer()
                    .frame(height: 50)
                Text("我的积分")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                    .padding(10)
                Text("57")
                    .foregroundColor(.black)
                    .font(.system(size: 36))
                    .padding(.bottom, 30)
                Button("查看明细") {
                    
                }
                .font(.system(size: 14))
                .padding(8)
                .frame(width: 100)
                .foregroundColor(Color.black)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .scaleEffect(1)
            }
            VStack {
                ZStack {
                    HStack {
                        Text(" ")
                            .foregroundColor(.black)
                            .padding(.bottom, 10)
                            .font(.system(size: 14))
                        Spacer()
                    }
                    .modifier(BottomLineModifier())
                    HStack {
                        Text("积分任务")
                            .foregroundColor(.black)
                            .padding(.bottom, 10)
                            .modifier(BottomLineModifier(color: .black, height: 1))
                            .font(.system(size: 15))
                        Spacer()
                    }
                }
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("分享内容")
                                .foregroundColor(.black)
                                .font(.system(size: 15))
                            Text("分享社区文章（笔记）给微信好友，微信好友要阅读才会加分")
                                .foregroundColor(.gray)
                                .padding(.top, 1)
                                .font(.system(size: 12))
                            Text("积分 +1")
                                .foregroundColor(.black)
                                .padding(.top, 1)
                                .font(.system(size: 12))
                        }
                        Spacer()
                        Button("去完成") {

                        }
                        .padding(8)
                        .frame(width: 80)
                        .foregroundColor(Color.white)
                        .background(Color.black)
                        .cornerRadius(22.5)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
                .modifier(BottomLineModifier())
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("首次阅读内容")
                                .foregroundColor(.black)
                                .font(.system(size: 15))
                            Text("完成阅读内容并浏览至末尾")
                                .foregroundColor(.gray)
                                .padding(.top, 1)
                                .font(.system(size: 12))
                            Text("积分 +5")
                                .foregroundColor(.black)
                                .padding(.top, 1)
                                .font(.system(size: 12))
                        }
                        Spacer()
                        Button("已完成") {

                        }
                        .padding(8)
                        .frame(width: 80)
                        .foregroundColor(Color.white)
                        .background(Color.gray)
                        .cornerRadius(22.5)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
                .modifier(BottomLineModifier())
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("绑定微信")
                                .foregroundColor(.black)
                                .font(.system(size: 15))
                            Text("首次绑定微信账号")
                                .foregroundColor(.gray)
                                .padding(.top, 1)
                                .font(.system(size: 12))
                            Text("积分 +10")
                                .foregroundColor(.black)
                                .padding(.top, 1)
                                .font(.system(size: 12))
                        }
                        Spacer()
                        Button("已完成") {

                        }
                        .padding(8)
                        .frame(width: 80)
                        .foregroundColor(Color.white)
                        .background(Color.gray)
                        .cornerRadius(22.5)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
                .modifier(BottomLineModifier())
            }
            .padding(20)
            Spacer()
        }
        .onAppear {
            appGlobalState.currentView = "MyPoints"
        }
    }
    
}

struct MyPointsView_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState.shared
    static var previews: some View {
        MyPointsView(container: MyPointsView.buildContainer())
            .environmentObject(appGlobalState)
    }
}
