//
//  LanguageSettingView.swift
//  iov
//
//  Created by Gemini on 2026/3/25.
//

import SwiftUI

struct LanguageSettingView: View {
    @EnvironmentObject var appGlobalState: AppGlobalState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: kStatusBarHeight)
            TopBackTitleBar(titleLocal: LocalizedStringKey("multi_language"))
            ScrollView {
                VStack(spacing: AppTheme.layout.spacing) {
                    VStack(spacing: 0) {
                        LanguageItem(title: "simplified_chinese", isSelected: appGlobalState.appLocale.identifier.starts(with: "zh")) {
                            appGlobalState.setLanguage("zh-Hans")
                        }
                        LanguageItem(title: "english", isSelected: appGlobalState.appLocale.identifier.starts(with: "en"), isLast: true) {
                            appGlobalState.setLanguage("en")
                        }
                    }
                    .appCardStyle()
                    .padding(.horizontal, AppTheme.layout.margin)
                }
                .padding(.top, 20)
            }
        }
        .appBackground()
        .onAppear {
            appGlobalState.currentView = "LanguageSetting"
        }
    }
}

extension LanguageSettingView {
    static func build() -> some View {
        LanguageSettingView()
    }
}

struct LanguageItem: View {
    var title: String
    var isSelected: Bool
    var isLast: Bool = false
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                HStack {
                    Text(LocalizedStringKey(title))
                        .font(AppTheme.fonts.body)
                        .foregroundColor(AppTheme.colors.fontPrimary)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark")
                            .foregroundColor(AppTheme.colors.brandMain)
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                .padding(.vertical, 20)
                .contentShape(Rectangle()) // 关键修复：确保整行可点击
                
                if !isLast {
                    Divider()
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct LanguageSettingView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var appGlobalState = AppGlobalState.shared
        LanguageSettingView()
            .environmentObject(appGlobalState)
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
