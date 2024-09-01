//
//  GenderPicker.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

//enum Gender: String, CaseIterable, Identifiable {
//    case Male = "MALE"
//    case Female = "FEMALE"
//    case Unknown = "UNKNOWN"
//    var id: String { self.rawValue }
//}

struct GenderPicker: View {
    @Binding var selectedGender: String
    var title: String = "标题"
    var buttonName: String = "保存"
    var action: (() -> Void)?
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack {
            Text(title)
            Picker("Select a color", selection: $selectedGender) {
                ForEach(Gender.allCases) { gender in
                    Text(genderStr(gender.rawValue)).tag(gender)
                }
            }
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
            Spacer()
        }
    }
}

struct GenderPickerItem_Previews: PreviewProvider {
    @State static var selectedGender = "UNKNOWN"
    static var previews: some View {
        GenderPicker(selectedGender: $selectedGender)
    }
}
