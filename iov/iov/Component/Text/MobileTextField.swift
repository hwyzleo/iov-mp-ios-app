//
//  MobileTextField.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

/// 手机文本框
struct MobileTextField: View {
    
    @Binding var mobile: String
    @State private var previousMobile: String = ""
    
    var body: some View {
        TextField(L10n.input_mobile, text: $mobile)
            .foregroundColor(AppTheme.colors.fontPrimary)
            .font(.system(size: 18))
            .keyboardType(.numberPad)
            .textContentType(.telephoneNumber)
            .disableAutocorrection(true)
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
