//
//  MySettingAccountChangeView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct MySettingAccountChangeView: View {
    @StateObject var container: MviContainer<MySettingAccountChangeIntentProtocol, MySettingAccountChangeModelStateProtocol>
    private var intent: MySettingAccountChangeIntentProtocol { container.intent }
    private var state: MySettingAccountChangeModelStateProtocol { container.model }
    
    var body: some View {
        ZStack {
            switch state.contentState {
            case .loading:
                LoadingTip()
            case .content:
                Content(intent: intent, state: state)
            case let .error(text):
                ErrorTip(text: text)
            }
        }
        .onAppear(perform: intent.viewOnAppear)
        .modifier(MySettingAccountChangeRouter(
            subjects: state.routerSubject,
            intent: intent
        ))
    }
}

// MARK: - Views

private extension MySettingAccountChangeView {
    
    private struct Content: View {
        let intent: MySettingAccountChangeIntentProtocol
        let state: MySettingAccountChangeModelStateProtocol
        @Environment(\.dismiss) private var dismiss
        @State private var image: Image? = nil
        @State private var showBirthday = false
        @State private var selectedDate = Date()
        @EnvironmentObject var appGlobalState: AppGlobalState
        @State private var isToggleOn = false
        
        var body: some View {
            VStack {
                ZStack {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image("back")
                                .resizable()
                                .frame(width: 20, height: 20, alignment: .leading)
                                .padding(.leading, 20)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    HStack {
                        HStack {
                            Text("选择车辆")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .bold()
                        }
                    }
                    HStack {
                        HStack {
                            Text("变更记录")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .font(.system(size: 14))
                                .padding(.trailing, 20)
                        }
                    }
                }
                Spacer()
                    .frame(height: 10)
                VStack {
                    Text("如需申请成为其他车辆的认证车主，请通过在线服务或拨打电话进行申请。")
                        .foregroundColor(.black)
                        .font(.system(size: 12))
                        .padding(10)
                }
                .background(Color(hex: 0xf2eded))
                Spacer()
            }
            .onAppear {
                appGlobalState.currentView = "MySettingAccountChange"
            }
        }
    }
    
}


struct MySettingAccountChangeView_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState()
    static var previews: some View {
        MySettingAccountChangeView(container: MySettingAccountChangeView.buildContainer())
            .environmentObject(appGlobalState)
    }
}
