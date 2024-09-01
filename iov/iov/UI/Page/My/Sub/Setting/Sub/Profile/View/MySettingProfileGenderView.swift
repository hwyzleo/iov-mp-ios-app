//
//  MySettingProfileGenderView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct MySettingProfileGenderView: View {
    @Environment(\.dismiss) private var dismiss
    @State var selectedGender: String = ""
    @State var showMale = false
    @State var showFemale = false
    var action: ((_ gender: String)->Void)?
    
    var body: some View {
        VStack {
            TopBackTitleBar(title: "性别")
            VStack(alignment: .center) {
                Button(action: {
                    showMale = true
                    showFemale = false
                    selectedGender = "MALE"
                }) {
                    VStack {
                        HStack {
                            Text("男")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 10)
                            if showMale {
                                Image("tick")
                            }
                        }
                        .padding(.bottom, 30)
                        .padding(.top, 20)
                        .modifier(BottomLineModifier())
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Button(action: {
                    showFemale = true
                    showMale = false
                    selectedGender = "FEMALE"
                }) {
                    VStack {
                        HStack {
                            Text("女")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 10)
                            if showFemale {
                                Image("tick")
                            }
                        }
                        .padding(.bottom, 30)
                        .padding(.top, 20)
                        .modifier(BottomLineModifier())
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Button(action: {
                    action?(selectedGender)
                    dismiss()
                }) {
                    Text("保存")
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color.white)
                        .background(Color.black)
                        .contentShape(Rectangle())
                        .cornerRadius(22.5)
                }
                .padding(.top, 20)
                Spacer()
            }
            .padding(20)
        }
        .onAppear(perform: {
            if selectedGender == "MALE" {
                showMale = true
                showFemale = false
            } else {
                showFemale = true
                showMale = false
            }
        })
    }
}

struct MySettingProfileGenderView_Previews: PreviewProvider {
    static var previews: some View {
        MySettingProfileGenderView()
    }
}
