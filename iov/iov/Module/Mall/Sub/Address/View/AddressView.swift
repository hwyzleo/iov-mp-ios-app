//
//  AddressView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct AddressView: View {
    
    @StateObject var container: MviContainer<AddressIntentProtocol, AddressModelStateProtocol>
    private var intent: AddressIntentProtocol { container.intent }
    private var state: AddressModelStateProtocol { container.model }
    @EnvironmentObject var appGlobalState: AppGlobalState
    @State private var text: String = ""
    
    var body: some View {
        VStack {
            TopBackTitleBar(title: "地址管理")
            ScrollView {
                
            }
            HStack {
                NavigationLink(destination: AddressAddView(intent: intent, state: state).navigationBarBackButtonHidden(true)) {
                    Text("新建地址")
                        .font(.system(size: 14))
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color.white)
                        .background(Color.black)
                        .cornerRadius(22.5)
                }
                
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.top, 5)
        }
        .onAppear {
            intent.viewOnAppear()
            appGlobalState.currentView = "Address"
        }
        .modifier(AddressRouter(
            subjects: state.routerSubject,
            intent: intent
        ))
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

struct AddressView_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState.shared
    static var previews: some View {
        AddressView(container: AddressView.buildContainer())
            .environmentObject(appGlobalState)
    }
}
