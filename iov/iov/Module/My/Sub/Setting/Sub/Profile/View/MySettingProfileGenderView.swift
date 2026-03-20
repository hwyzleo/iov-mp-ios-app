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
    @State var showUnknown = false
    var action: ((_ gender: String)->Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: kStatusBarHeight)
            TopBackTitleBar(title: "性别")
            VStack(alignment: .center, spacing: AppTheme.layout.spacing) {
                VStack(spacing: 0) {
                    Button(action: {
                        showMale = true
                        showFemale = false
                        showUnknown = false
                        selectedGender = "MALE"
                    }) {
                        HStack {
                            Text("男")
                                .font(AppTheme.fonts.body)
                                .foregroundColor(AppTheme.colors.fontPrimary)
                            Spacer()
                            if showMale {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppTheme.colors.brandMain)
                            }
                        }
                        .padding(.vertical, 20)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                    
                    Button(action: {
                        showFemale = true
                        showMale = false
                        showUnknown = false
                        selectedGender = "FEMALE"
                    }) {
                        HStack {
                            Text("女")
                                .font(AppTheme.fonts.body)
                                .foregroundColor(AppTheme.colors.fontPrimary)
                            Spacer()
                            if showFemale {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppTheme.colors.brandMain)
                            }
                        }
                        .padding(.vertical, 20)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                    
                    Button(action: {
                        showUnknown = true
                        showMale = false
                        showFemale = false
                        selectedGender = "UNKNOWN"
                    }) {
                        HStack {
                            Text("未知")
                                .font(AppTheme.fonts.body)
                                .foregroundColor(AppTheme.colors.fontPrimary)
                            Spacer()
                            if showUnknown {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppTheme.colors.brandMain)
                            }
                        }
                        .padding(.vertical, 20)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .appCardStyle()
                
                RoundedCornerButton(nameLocal: LocalizedStringKey("confirm"), color: .black, bgColor: AppTheme.colors.brandMain) {
                    action?(selectedGender)
                    dismiss()
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding(AppTheme.layout.margin)
        }
        .appBackground()
        .onAppear(perform: {
            if selectedGender == "MALE" {
                showMale = true
                showFemale = false
                showUnknown = false
            } else if selectedGender == "FEMALE" {
                showFemale = true
                showMale = false
                showUnknown = false
            } else {
                showUnknown = true
                showMale = false
                showFemale = false
            }
        })
    }
}

struct MySettingProfileGenderView_Previews: PreviewProvider {
    static var previews: some View {
        MySettingProfileGenderView()
    }
}
