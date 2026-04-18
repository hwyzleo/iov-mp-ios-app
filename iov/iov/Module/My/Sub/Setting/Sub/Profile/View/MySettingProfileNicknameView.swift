//
//  MySettingProfileNicknameView.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

struct MySettingProfileNicknameView: View {
    @Environment(\.dismiss) private var dismiss
    @State var nickname: String = ""
    var action: ((_ nickname: String)->Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: kStatusBarHeight)
            TopBackTitleBar(title: "昵称")
            VStack(alignment: .leading, spacing: 0) {
                VStack(spacing: 0) {
                    TextField("", text: $nickname)
                        .frame(height: 50)
                        .textFieldStyle(.plain)
                        .foregroundColor(AppTheme.colors.fontPrimary)
                        .font(AppTheme.fonts.body)
                        .onChange(of: nickname) { newNickname in
                            if(newNickname.count > 15) {
                                nickname = String(newNickname.prefix(15))
                            }
                        }
                    Rectangle()
                        .foregroundColor(AppTheme.colors.fontTertiary.opacity(0.3))
                        .frame(height: 1)
                }
                
                Text("昵称最多15个字符")
                    .foregroundColor(AppTheme.colors.fontSecondary)
                    .font(AppTheme.fonts.subtext)
                    .padding(.top, 12)
                
                RoundedCornerButton(nameLocal: LocalizedStringKey("confirm"), color: .black, bgColor: AppTheme.colors.brandMain) {
                    action?(nickname)
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

struct MySettingProfileNicknameView_Previews: PreviewProvider {
    static var previews: some View {
        MySettingProfileNicknameView()
    }
}
