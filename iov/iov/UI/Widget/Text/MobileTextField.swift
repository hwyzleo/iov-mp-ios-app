//
//  MobileTextField.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

/// 手机文本框
struct MobileTextField: View {
    
    @Binding var mobile: String
    @State private var previousMobile: String = ""
    
    var body: some View {
        TextField("请输入手机号", text: $mobile)
            .foregroundColor(Color(hex: 0x333333))
            .font(.system(size: 18))
            .keyboardType(.phonePad)
            .modifier(ClearButton(text: $mobile))
            .onChange(of: mobile) { newMobile in
                if(newMobile.count > previousMobile.count) {
                    if(newMobile.count == 3 || newMobile.count == 8) {
                        mobile.append(" ")
                    }
                } else if(newMobile.count < previousMobile.count) {
                    if newMobile.last == " " {
                        mobile.removeLast()
                    }
                }
                if(newMobile.count > 13) {
                    mobile = String(newMobile.prefix(13))
                }
                previousMobile = mobile
            }
    }
}

struct MobileTextField_Previews: PreviewProvider {
    @State static var mobile = ""
    static var previews: some View {
        MobileTextField(mobile: $mobile)
    }
}
