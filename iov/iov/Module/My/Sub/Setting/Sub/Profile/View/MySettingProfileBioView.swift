//
//  MySettingProfileBioView.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

struct MySettingProfileBioView: View {
    @Environment(\.dismiss) private var dismiss
    @State var bio: String = ""
    var action: ((_ bio: String)->Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: kStatusBarHeight)
            TopBackTitleBar(title: "签名")
            VStack(alignment: .leading, spacing: 0) {
                VStack(spacing: 0) {
                    TextField("请输入签名", text: $bio)
                        .frame(height: 50)
                        .textFieldStyle(.plain)
                        .foregroundColor(AppTheme.colors.fontPrimary)
                        .font(AppTheme.fonts.body)
                        .onChange(of: bio) { newBio in
                            if(newBio.count > 30) {
                                bio = String(newBio.prefix(30))
                            }
                        }
                    Rectangle()
                        .foregroundColor(AppTheme.colors.fontTertiary.opacity(0.3))
                        .frame(height: 1)
                }
                
                Text("签名最多30个字符")
                    .foregroundColor(AppTheme.colors.fontSecondary)
                    .font(AppTheme.fonts.subtext)
                    .padding(.top, 12)
                
                RoundedCornerButton(nameLocal: LocalizedStringKey("confirm"), color: .black, bgColor: AppTheme.colors.brandMain) {
                    action?(bio)
                    dismiss()
                }
                .padding(.top, 40)
                
                Spacer()
            }
            .padding(AppTheme.layout.margin)
        }
        .appBackground()
    }
}

struct MySettingProfileBioView_Previews: PreviewProvider {
    static var previews: some View {
        MySettingProfileBioView()
    }
}
