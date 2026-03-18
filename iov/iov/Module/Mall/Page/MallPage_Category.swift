//
//  MallView_Category.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import Kingfisher

extension MallPage {
    struct Category: View {
        var title: String = "类别"
        var products: [Product] = []
        var action: ((_ id: String) -> Void)?
        let gridItems = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(title)
                        .font(AppTheme.fonts.title1)
                        .bold()
                        .foregroundColor(AppTheme.colors.fontPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.colors.fontSecondary)
                }
                .padding(.horizontal, 4)
                
                LazyVGrid(columns: gridItems, spacing: 20) {
                    ForEach(products.prefix(4), id: \.id) { product in
                        Button(action: {
                            action?(product.id)
                        }) {
                            VStack(alignment: .leading, spacing: 12) {
                                ZStack(alignment: .topLeading) {
                                    if let cover = product.cover {
                                        KFImage(URL(string: cover))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                            .frame(height: 120) // 强制固定高度，防止重叠
                                            .cornerRadius(AppTheme.layout.radiusMedium)
                                            .clipped()
                                    }
                                    
                                    // 商品标签
                                    Text("新品")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(AppTheme.colors.brandMain)
                                        .cornerRadius(4)
                                        .padding(8)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(product.name)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppTheme.colors.fontPrimary)
                                        .lineLimit(1)
                                    
                                    if let price = product.price {
                                        Text("￥\(price.formatted())")
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundColor(AppTheme.colors.brandMain)
                                    }
                                }
                                .padding(.horizontal, 4)
                                .padding(.bottom, 4)
                            }
                            .background(Color.white.opacity(0.02)) // 增加微弱背景色提升边界感
                            .cornerRadius(AppTheme.layout.radiusMedium)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .appCardStyle()
        }
    }
}


#Preview {
    ForEach(mockMallIndex().categories.sorted(by: {$0.key < $1.key}), id:\.key) { title, products in
        MallPage.Category(title: title, products: products)
    }
}
