//
//  CaptchaTextField.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension String {
    var digits: [Int] {
        var result = [Int]()
        for char in self {
            if let number = Int(String(char)) {
                result.append(number)
            }
        }
        return result
   }
}

extension Int {
    var numberString: String {
    guard self < 10 else { return "0" }
    return String(self)
   }
}

/// 验证码文本框
struct CaptchaTextField: View {
    var maxDigits: Int = 6
        @Binding var pin: String
        @State var showPin = true
        var handler: () -> Void
        
        var body: some View {
            VStack {
                ZStack {
                    pinDots
                    backgroundField
                }
            }
        }
        
        private var pinDots: some View {
            HStack {
                ForEach(0..<maxDigits) { index in
                    Text(self.getNumber(at: index))
                        .font(.system(size: 24).weight(.bold))
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50, alignment: .center)
                        .padding(EdgeInsets(top: 7, leading: 0, bottom: 7, trailing: 0))
                        .border((index == self.pin.count) ? Color.black : Color.gray, width: 0.5)
                }
            }
        }
        private func getNumber(at index: Int) -> String {
            
            if index == self.pin.count {
                return "_"
            }
            if index >= self.pin.count {
                return " "
            }
            if self.pin.count > maxDigits {
                self.showPin = false
            }
            if self.showPin {
                return self.pin.digits[index].numberString
            }
            return " "
        }
        private var backgroundField: some View {
            let boundPin = Binding<String>(get: { self.pin }, set: { newValue in
                self.pin = newValue
                self.submitPin()
            })
            
            return TextField("", text: boundPin, onCommit: submitPin)
                .accentColor(.clear)
                .foregroundColor(.clear)
                .keyboardType(.numberPad)
        }
        private func submitPin() {
            if pin.count > maxDigits {
                // 如果超出长度就忽略本次输入
                pin = String(pin.prefix(maxDigits))
            } else if pin.count == maxDigits {
                handler()
            }
        }
}

struct CaptchaTextField_Previews: PreviewProvider {
    static var previews: some View {
        CaptchaTextField(maxDigits: 6, pin: .constant(""), showPin: true) {}
    }
}
