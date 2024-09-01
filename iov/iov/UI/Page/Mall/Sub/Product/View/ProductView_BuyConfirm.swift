//
//  ProductView_BuyConfirm.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import Kingfisher
extension ProductView {
    
    struct BuyConfirm: View {
        @Environment(\.dismiss) private var dismiss
        @Binding var buyCount: Int
        var cover: String?
        var price: Int?
        var buyAction: (() -> Void)?
        
        var body: some View {
            VStack {
                VStack(alignment: .leading) {
                    HStack {
                        if let c = cover {
                            KFImage(URL(string: c)!)
                                .resizable()
                                .frame(width: 100, height: 100)
                        }
                        VStack(alignment: .leading) {
                            if let p = price {
                                Text("¥ \(p)")
                                    .font(.system(size: 20))
                                    .padding(.bottom, 50)
                            }
                            HStack {
                                Text("已选")
                                    .font(.system(size: 14))
                                Text("x\(buyCount)")
                                    .font(.system(size: 14))
                            }
                        }
                    }
                    Text("数量")
                        .font(.system(size: 14))
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                    HStack {
                        Button(action: {
                            if buyCount > 1 {
                                buyCount = buyCount - 1
                            }
                        }) {
                            Image(systemName: "minus.circle")
                        }
                        .buttonStyle(.plain)
                        Text("\(buyCount)")
                        Button(action: {
                            buyCount = buyCount + 1
                        }) {
                            Image(systemName: "plus.circle")
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                    Button(action: {
                        dismiss()
                        buyAction?()
                    }) {
                        Text("立即购买")
                            .font(.system(size: 12))
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color.white)
                            .background(Color.black)
                            .cornerRadius(22.5)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
    }
}


struct ProductView_BuyConfirm_Previews: PreviewProvider {
    static var previews: some View {
        ProductView.BuyConfirm(buyCount: .constant(1), cover: "https://pic.imgdb.cn/item/65e9b3879f345e8d036bff96.png", price: 1000)
    }
}
