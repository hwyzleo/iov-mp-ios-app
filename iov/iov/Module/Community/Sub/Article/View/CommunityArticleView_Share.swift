//
//  CommunityArticleView_Share.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension CommunityArticleView {
    struct Share: View {
        @Binding var showShare: Bool
        
        var body: some View {
            VStack(spacing: 32) {
                HStack {
                    Text("分享至")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.colors.fontPrimary)
                    Spacer()
                }
                
                HStack(spacing: 0) {
                    ShareItem(icon: "wechat_c", label: "微信")
                    ShareItem(icon: "wechat.moments_c", label: "朋友圈")
                    ShareItem(systemIcon: "link", label: "复制链接")
                    ShareItem(systemIcon: "exclamationmark.triangle", label: "举报")
                }
                
                Button(action: { showShare = false }) {
                    Text("取消")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.colors.fontPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(AppTheme.layout.radiusMedium)
                }
                .buttonStyle(.plain)
            }
            .padding(AppTheme.layout.cardPadding)
            .background(AppTheme.colors.cardBackground)
        }
    }
}

private struct ShareItem: View {
    var icon: String?
    var systemIcon: String?
    var label: String
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 56, height: 56)
                
                if let icon = icon {
                    Image(icon)
                        .resizable()
                        .frame(width: 32, height: 32)
                } else if let systemIcon = systemIcon {
                    Image(systemName: systemIcon)
                        .font(.system(size: 24))
                        .foregroundColor(AppTheme.colors.brandMain)
                }
            }
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.colors.fontSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CommunityArticleView_Share_Previews: PreviewProvider {
    static var previews: some View {
        CommunityArticleView.Share(showShare: .constant(false))
    }
}
