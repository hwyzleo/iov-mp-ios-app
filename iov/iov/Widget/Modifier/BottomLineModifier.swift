//
//  BottomLineModifier.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import Foundation
import SwiftUI

/// 底部细线
struct BottomLineModifier: ViewModifier {
    var color: Color = .gray
    var height = 0.5
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .frame(height: height)
                    .foregroundColor(color),
                alignment: .bottom
            )
    }
}
