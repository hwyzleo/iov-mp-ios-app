//
//  LabelTabView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct LabelTabView: View {
    var tabs: [String]
    var tabSize: CGFloat = 16
    var views: [AnyView]
    @State private var selector = 0
    
    var body: some View {
        VStack{
            ZStack {
                Text("")
                    .frame(maxWidth: .infinity)
                    .frame(height: 24)
                    .modifier(BottomLineModifier())
                HStack{
                    ForEach(tabs, id: \.self) { name in
                        Button(action: {
                            if let index = tabs.firstIndex(of: name){
                                withAnimation {
                                    selector = index
                                }
                            }
                        }, label: {
                            if selector == tabs.firstIndex(of: name){
                                Text(name)
                                    .font(.system(size: tabSize, weight: .bold))
                                    .overlay(Rectangle().frame(height: 3).offset(y: 4) ,alignment: .bottom)
                                    .foregroundColor(.black)
                            }else{
                                Text(name)
                                    .font(.system(size: tabSize))
                                    .foregroundColor(.gray)
                            }
                        })
                        .padding(.trailing, 10)
                    }
                    Spacer()
                }
            }
            ScrollView{
                views[selector]
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
            .updating($gesturePanOffset){ lastestGestureValue, gesturePan, animation in
                gesturePan = lastestGestureValue.translation //gesturePan的更新会影响$gesturePanOffset的值变化
                animation.animation = .easeInOut//拖动的动画处理
            }
            //手势结束后的操作(循环切换分段View)
            .onEnded{ value in
                let moveOffset = UIScreen.main.bounds.width / 2 //超过屏幕宽度（计算后的值）才发生偏移
                let lastIndex = tabs.endIndex - 1//数组最后一个索引值
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

struct LabelTabView_Previews: PreviewProvider {
    static var previews: some View {
        LabelTabView(tabs: ["标签1", "标签2"], views: [AnyView(EmptyView()), AnyView(EmptyView())])
    }
}
