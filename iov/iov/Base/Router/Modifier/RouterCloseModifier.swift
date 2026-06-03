//
//  RouterCloseModifier.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI
import Combine

struct RouterCloseModifier: ViewModifier {
    
    // MARK: Public
    
    let publisher: AnyPublisher<Void, Never>
    
    // MARK: Private
    
    @Environment(\.presentationMode) private var presentationMode
    
    // MARK: Life cycle
    
    func body(content: Content) -> some View {
        content
            .onReceive(publisher) { _ in
                presentationMode.wrappedValue.dismiss()
            }
    }
}
