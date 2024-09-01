//
//  TextIFieldtem.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct TextFieldItem: View {
    
    @Binding var value: String
    var title: String = "标题"
    var buttonName: String = "保存"
    var action: (() -> Void)?
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack {
            Text(title)
            TextField("", text: $value)
                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                .frame(height: 35)
                .border(.gray)
                .padding(.leading, 20)
                .padding(.trailing, 20)
            HStack {
                Button(action: {
                    self.action?()
                }) {
                    Text(buttonName)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 35)
                .foregroundColor(Color.white)
                .background(Color.gray)
                .cornerRadius(5)
            }.padding(.horizontal, 20)
        }
        Spacer()
    }
}

struct TextItem_Previews: PreviewProvider {
    @State static var value = ""
    static var previews: some View {
        TextFieldItem(value: $value)
    }
}
