//
//  TestDriveReportView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct TestDriveReportView: View {
    
    @StateObject var container: MviContainer<TestDriveReportIntentProtocol, TestDriveReportModelStateProtocol>
    private var intent: TestDriveReportIntentProtocol { container.intent }
    private var state: TestDriveReportModelStateProtocol { container.model }
    @EnvironmentObject var appGlobalState: AppGlobalState
    @Environment(\.dismiss) private var dismiss
    @State private var showStack = false
    
    var body: some View {
        VStack {
            TopBackTitleBar(title: "试驾报告")
            Image("test-drive-report-banner")
                .resizable()
                .scaledToFit()
            VStack {
                HStack {
                    Text("试驾报告")
                        .foregroundColor(.black)
                        .font(.system(size: 18))
                        .bold()
                    Spacer()
                }
                Spacer()
                    .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                Text("暂无试驾记录，快去预约试驾吧")
                    .foregroundColor(.black)
                    .font(.system(size: 14))
                Spacer()
                    .frame(height: 50)
                Button("预约试驾") {

                }
                .padding(8)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .foregroundColor(Color.white)
                .background(Color.black)
                .cornerRadius(22.5)
            }
            .padding(20)
            Spacer()
        }
    }
    
}

private extension TestDriveReportView {
    
    /// 菜单项
    struct TabMenu: View {
        private let segmented = ["邀请中","已完成"]
        @State private var selector = 0
        
        var body: some View{
            VStack{
                ZStack {
                    HStack{
                        ForEach(segmented, id: \.self) { name in
                            Button(action: {
                                if let index = segmented.firstIndex(of: name){
                                    withAnimation {
                                        selector = index
                                    }
                                }
                            }, label: {
                                if selector == segmented.firstIndex(of: name){
                                    Text(name)
                                        .font(.system(size: 14, weight: .bold))
                                        .overlay(Rectangle().frame(height: 2).offset(y: 4) ,alignment: .bottom)
                                        .foregroundColor(.black)
                                }else{
                                    Text(name)
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                            })
                            .padding(.trailing, 10)
                        }
                        Spacer()
                    }
                    Text("")
                        .frame(maxWidth: .infinity)
                        .frame(height: 24)
                        .modifier(BottomLineModifier())
                }
                
                //根据selector分段切换视图
                ScrollView{
                    switch selector{
                    case 0:
                        Inviting()
                    case 1:
                        Inviting()
                    default:
                        Inviting()
                    }
                }
                .offset(x:gesturePanOffset.width)
                .gesture(panGesture())//拖动手势(切换View)
    //            .transition(.slide)
    //            .animation(.easeInOut)
                .navigationBarHidden(true) //隐藏包括标题和返回键在内的所有系统导航栏
                .navigationBarBackButtonHidden(true)//只隐藏系统导航栏中的返回键
            }
        }
        
        //平移手势
        @GestureState private var gesturePanOffset:CGSize = .zero //手势结束会恢复初值
        //手势定义
        private func panGesture() -> some Gesture{
            DragGesture()
                //有空仔细学一下updating到底在做什么
                .updating($gesturePanOffset){ lastestGestureValue, gesturePan, animation in
                    gesturePan = lastestGestureValue.translation //gesturePan的更新会影响$gesturePanOffset的值变化
                    animation.animation = .easeInOut//拖动的动画处理
                }
                //手势结束后的操作(循环切换分段View)
                .onEnded{ value in
                    let moveOffset = UIScreen.main.bounds.width / 2 //超过屏幕宽度（计算后的值）才发生偏移
                    let lastIndex = segmented.endIndex - 1//数组最后一个索引值
                    //向右拖动
                    if value.translation.width > moveOffset{
                        if selector <= 0{
                            selector = lastIndex
                        }else{
                            selector -= 1
                        }
                    }
                    //向左拖动
                    if -value.translation.width > moveOffset{
                        if selector >= lastIndex {
                            selector = 0
                        }else{
                            selector += 1
                        }
                    }
                }
        }
    }
    
    /// 邀请中
    struct Inviting: View {
        
        var body: some View {
            Spacer()
                .frame(height: 20)
            VStack(alignment: .leading) {
                HStack {
                    Text("微信用户")
                        .bold()
                        .font(.system(size: 14))
                    Spacer()
                    Text("已邀请")
                        .foregroundColor(.brown)
                        .bold()
                        .font(.system(size: 14))
                }
                .padding(.bottom, 5)
                Text("13xxxxxxxxx")
                    .font(.system(size: 14))
                HStack {
                    ZStack(alignment: .top) {
                        Text("")
                            .frame(maxWidth: .infinity)
                            .frame(height: 2)
                            .modifier(BottomLineModifier())
                            .padding(.leading, 35)
                            .padding(.trailing, 35)
                            .padding(.top, 13)
                        HStack(alignment: .top) {
                            VStack {
                                Circle()
                                    .foregroundColor(.brown)
                                    .frame(width: 10, height: 10)
                                    .padding(.bottom, 5)
                                Text("邀请")
                                    .font(.system(size: 12))
                                    .foregroundColor(.brown)
                                    .padding(.bottom, 2)
                                Text("2023/08/22")
                                    .frame(width: 80)
                                    .foregroundColor(.brown)
                                    .font(.system(size: 10))
                            }
                            Spacer()
                            VStack {
                                Circle()
                                    .foregroundColor(.gray)
                                    .frame(width: 10, height: 10)
                                    .padding(.bottom, 5)
                                Text("试驾")
                                    .font(.system(size: 12))
                                    .padding(.bottom, 2)
                                Text("")
                                    .frame(width: 80)
                                    .font(.system(size: 10))
                            }
                            Spacer()
                            VStack {
                                Circle()
                                    .foregroundColor(.gray)
                                    .frame(width: 10, height: 10)
                                    .padding(.bottom, 5)
                                Text("订购")
                                    .font(.system(size: 12))
                                    .padding(.bottom, 2)
                                Text("")
                                    .frame(width: 80)
                                    .font(.system(size: 10))
                            }
                            Spacer()
                            VStack {
                                Circle()
                                    .foregroundColor(.gray)
                                    .frame(width: 10, height: 10)
                                    .padding(.bottom, 5)
                                Text("支付")
                                    .font(.system(size: 12))
                                    .padding(.bottom, 2)
                                Text("")
                                    .frame(width: 80)
                                    .font(.system(size: 10))
                            }
                        }
                        .padding(.top, 10)
                    }
                }
                Text("")
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .modifier(BottomLineModifier())
                    .padding(.top, 15)
                    .padding(.bottom, 15)
                Text("您的好友已接受邀请，好友完成试驾或提车后您可以获得积分奖励。")
                    .font(.system(size: 13))
            }
            .padding(10)
            .foregroundColor(.black)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        
    }
}

struct TestDriveReportView_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState.shared
    static var previews: some View {
        TestDriveReportView(container: TestDriveReportView.buildContainer())
            .environmentObject(appGlobalState)
    }
}
