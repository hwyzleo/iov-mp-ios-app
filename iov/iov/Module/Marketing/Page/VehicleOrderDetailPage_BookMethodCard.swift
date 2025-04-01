//
//  VehicleOrderDetailPage_BookMethodCard.swift
//  iov
//
//  Created by 叶荣杰 on 2025/4/1.
//

import SwiftUICore

struct BookMethodCard: View {
    let isSelected: Bool
    let tagText: String
    let tagColor: Color
    let title: LocalizedStringKey
    let price: Decimal
    let benefits: String
    let action: () -> Void
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(isSelected ? Color.orange : Color.gray.opacity(0.3), lineWidth: 1)
            .frame(height: 130)
            .overlay(
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        RoundedCornerButton(
                            name: tagText,
                            color: .white,
                            bgColor: tagColor,
                            borderColor: tagColor,
                            height: 20,
                            fontSize: 11
                        ) {}
                        .frame(width: 80)
                        
                        Text(title)
                            .font(.system(size: 14))
                        
                        Text("￥\(price.formatted())")
                            .font(.system(size: 14))
                        
                        Spacer()
                        
                        Text(LocalizedStringKey("view_benefits_detail"))
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    Text(benefits)
                        .font(.system(size: 13))
                        .lineSpacing(6)
                        .foregroundColor(.gray)
                }
                .padding(16)
            )
            .contentShape(Rectangle())
            .onTapGesture(perform: action)
    }
}
