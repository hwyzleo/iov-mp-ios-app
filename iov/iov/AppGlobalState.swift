//
//  AppGlobalState.swift
//  iov
//
//  Created by 叶荣杰 on 2024/8/31.
//

import Foundation

class AppGlobalState: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var isFirstActive: Bool = false
    @Published var isSecondActive: Bool = false
    @Published var currentView: String = ""
    @Published var productId: String = ""
    @Published var parameters: [String: Any] = [:]
}
