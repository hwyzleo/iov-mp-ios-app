//
//  VehicleOrderDetailPage_BookMethodCard.swift
//  iov
//
//  Created by hwyz_leo on 2025/4/1.
//

import SwiftUI

struct BookMethodCard: View {
    let isSelected: Bool
    let tagText: String
    let tagColor: Color
    let title: LocalizedStringKey
    let price: Decimal
    let benefits: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(AppTheme.fonts.title1)
                            .foregroundColor(AppTheme.colors.fontPrimary)
                        
                        Text(tagText)
                            .font(.system(size: 11))
                            .foregroundColor(tagColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(tagColor.opacity(0.1))
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("￥\(price.formatted())")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.colors.brandMain)
                        
                        Text(LocalizedStringKey("view_benefits_detail"))
                            .font(AppTheme.fonts.subtext)
                            .foregroundColor(AppTheme.colors.fontTertiary)
                    }
                }
                
                if !benefits.isEmpty {
                    Divider().background(Color.white.opacity(0.05))
                    
                    Text(benefits)
                        .font(AppTheme.fonts.subtext)
                        .foregroundColor(AppTheme.colors.fontSecondary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(AppTheme.layout.cardPadding)
            .background(AppTheme.colors.cardBackground)
            .cornerRadius(AppTheme.layout.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.layout.radiusMedium)
                    .stroke(isSelected ? AppTheme.colors.brandMain : Color.clear, lineWidth: 2)
            )
            .shadow(color: isSelected ? AppTheme.colors.brandMain.opacity(0.1) : Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}
