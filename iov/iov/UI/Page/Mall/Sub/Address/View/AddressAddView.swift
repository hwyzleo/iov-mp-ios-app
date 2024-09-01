//
//  AddressAddView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct AddressAddView: View {
    let intent: AddressIntentProtocol
    let state: AddressModelStateProtocol
    @State var name = ""
    @State var mobile = ""
    @State private var isToggleOn = false
    
    var body: some View {
        VStack {
            TopBackTitleBar(title: "新建地址")
            VStack {
                HStack {
                    Text("收货人")
                    Spacer()
                    TextField("请填写收货人姓名", text: $name)
                        .frame(width: 260)
                }
                .padding(.bottom, 15)
                .modifier(BottomLineModifier())
                HStack {
                    Text("手机号")
                    Spacer()
                    TextField("请填写收货人手机号", text: $mobile)
                        .frame(width: 260)
                }
                .padding(.top, 12)
                .padding(.bottom, 15)
                .modifier(BottomLineModifier())
                HStack {
                    Text("所在地区")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding(.top, 12)
                .padding(.bottom, 15)
                .modifier(BottomLineModifier())
                HStack {
                    Text("详细地址")
                    Spacer()
                    TextField("街道/楼牌号等", text: $mobile)
                        .frame(width: 260)
                }
                .padding(.top, 12)
                .padding(.bottom, 15)
                .modifier(BottomLineModifier())
                HStack {
                    Toggle(isOn: $isToggleOn) {
                        Text("设为默认地址")
                    }
                }
                .padding(.top, 12)
                Spacer()
                Button(action: {
                    intent.onTapSaveAddressButton()
                }) {
                    Text("保存并使用")
                        .font(.system(size: 16))
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.white)
                .background(Color.black)
                .cornerRadius(22.5)
            }
            .padding(20)
        }
        .modifier(AddressRouter(
            subjects: state.routerSubject,
            intent: intent
        ))
    }
}

struct AddressAddView_Previews: PreviewProvider {
    static var previews: some View {
        AddressView.buildAddressAdd()
    }
}
