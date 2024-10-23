//
//  AppGlobalState.swift
//  iov
//
//  Created by 叶荣杰 on 2024/8/31.
//

import Foundation

class AppGlobalState: ObservableObject {
    static let shared = AppGlobalState()
    
    @Published var selectedTab: Int = 0
    @Published var isFirstActive: Bool = false
    @Published var isSecondActive: Bool = false
    @Published var isMock: Bool = true
    @Published var mockOrderState: OrderState = .WISHLIST
    @Published var tspUrl: String = "http://192.168.2.223:8081"
    @Published var currentView: String = ""
    @Published var productId: String = ""
    @Published var parameters: [String: Any] = [:]
    @Published var needRefresh: Bool = false
    @Published var backRefresh: Bool = false
    
    private init() {}
}
