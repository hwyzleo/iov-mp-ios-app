//
//  AppRoute.swift
//  iov
//
//  Created by iov on 2026/6/3.
//

import SwiftUI

/// 全局路由枚举
enum AppRoute: Hashable, Identifiable {
    case marketing(MarketingRoute)
    case community(CommunityRoute)
    case service(ServiceRoute)
    case mall(MallRoute)
    case my(MyRoute)
    case login
    
    var id: String {
        switch self {
        case .marketing(let route): return "marketing_\(route)"
        case .community(let route): return "community_\(route)"
        case .service(let route): return "service_\(route)"
        case .mall(let route): return "mall_\(route)"
        case .my(let route): return "my_\(route)"
        case .login: return "login"
        }
    }
}

/// Community模块路由枚举
enum CommunityRoute: Hashable {
    case index
}

/// Service模块路由枚举
enum ServiceRoute: Hashable {
    case index
}

/// Mall模块路由枚举
enum MallRoute: Hashable {
    case index
}

/// My模块路由枚举
enum MyRoute: Hashable {
    case index
}
