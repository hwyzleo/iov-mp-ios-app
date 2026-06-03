//
//  RouterCloseToRootModifier.swift
//  iov
//
//  Created by iov on 2026/6/3.
//

import SwiftUI
import Combine

struct RouterCloseToRootModifier: ViewModifier {
    
    // MARK: Public
    
    let publisher: AnyPublisher<Void, Never>
    
    // MARK: Private
    
    @Environment(\.dismiss) private var dismiss
    @State private var shouldDismiss = false
    
    // MARK: Life cycle
    
    func body(content: Content) -> some View {
        content
            .onReceive(publisher) { _ in
                // 触发多次dismiss以返回到根页面
                dismiss()
                // 延迟后再次dismiss，以确保返回到根页面
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    dismiss()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    dismiss()
                }
            }
    }
}
