//
//  MySettingProfileNicknameView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct MySettingProfileNicknameView: View {
    @Environment(\.dismiss) private var dismiss
    @State var nickname: String = ""
    var action: ((_ nickname: String)->Void)?
    
    var body: some View {
        VStack {
            TopBackTitleBar(title: "昵称")
            VStack(alignment: .leading) {
                TextField("", text: $nickname)
                    .frame(height: 35)
                    .textFieldStyle(.plain)
                    .onChange(of: nickname) { newNickname in
                        if(newNickname.count > 15) {
                            nickname = String(newNickname.prefix(15))
                        }
                    }
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(height: 0.5)
                Text("昵称最多15个字符")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                    .padding(.top, 10)
                Button(action: {
                    action?(nickname)
                    dismiss()
                }) {
                    Text("保存")
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color.white)
                        .background(Color.black)
                        .cornerRadius(22.5)
                        .contentShape(Rectangle())
                }
                .padding(.top, 20)
                Spacer()
            }
            .padding(20)
        }
    }
}

struct MySettingProfileNicknameView_Previews: PreviewProvider {
    static var previews: some View {
        MySettingProfileNicknameView()
    }
}
