//
//  MyMessageView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct MyMessageView: View {
    
    @StateObject var container: MviContainer<MyMessageIntentProtocol, MyMessageModelStateProtocol>
    private var intent: MyMessageIntentProtocol { container.intent }
    private var state: MyMessageModelStateProtocol { container.model }
    
    var body: some View {
        ZStack {
            MyMessageView.Content(
                
            )
        }
        .modifier(MyMessageRouter(
            subjects: state.routerSubject,
            intent: intent
        ))
    }
    
}

extension MyMessageView {
    
    struct Content: View {
        @State private var showAlert = false
        var tapProfile: (()->Void)?
        var tapAccountChange: (()->Void)?
        var tapAccountSecurity: (()->Void)?
        var tapAccountBinding: (()->Void)?
        var tapPrivillegeAction: (()->Void)?
        var tapUserProtocolAction: (()->Void)?
        var tapCommunityConvention: (()->Void)?
        var tapPrivacyAgreement: (()->Void)?
        var loginAction: (()->Void)?
        var logoutAction: (()->Void)?
        
        var body: some View {
            VStack {
                TopBackTitleBar(title: "消息")
                ScrollView {
                    VStack {
                        MyMessageView.List(icon: "text.bubble", title: "通知") {

                        }
                        MyMessageView.List(icon: "car",title: "购车") {
                            
                        }
                        MyMessageView.List(icon: "steeringwheel",title: "爱车") {

                        }
                        MyMessageView.List(icon: "list.bullet.rectangle.portrait",title: "服务") {

                        }
                        MyMessageView.List(icon: "bag",title: "商城") {

                        }
                        MyMessageView.List(icon: "bubble.left.and.text.bubble.right",title: "互动") {

                        }
                    }
                    .padding(20)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}

struct MyMessageView_Previews: PreviewProvider {
    static var previews: some View {
        MyMessageView.Content()
    }
}
