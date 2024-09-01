//
//  RouterAlertModifier.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import Combine

protocol RouterAlertScreenProtocol {}

struct RouterAlertModifier<ScreenType> where ScreenType: RouterAlertScreenProtocol {
    
    // MARK: Public
    
    let publisher: AnyPublisher<ScreenType, Never>
    let alert: (ScreenType) -> Alert

    // MARK: Private
    
    @State private var screenType: ScreenType?
}

// MARK: - ViewModifier

extension RouterAlertModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .onReceive(publisher) { screenType = $0 }
            .alert(
                isPresented: .init(get: { screenType != nil },
                                   set: { if !$0 { screenType = nil } }),
                content: {
                    if let type = screenType {
                        return alert(type)
                    } else {
                        return Alert(title: Text("Something went wrong"),
                                     message: nil,
                                     dismissButton: .cancel())
                    }
                })
    }
}
