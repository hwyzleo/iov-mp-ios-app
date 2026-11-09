//
//  AppConfig.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-001 on 2026/11/9.
//

import Foundation

/// 构建配置读取（IOS-APP-DSN-CR-001 §6.2）
/// X-Client-Id 必须来自构建配置，且与 CIAM 客户端允许清单一致。
struct AppConfig {

    /// TSP 客户端标识的默认值，保持与当前已上线行为一致
    static let defaultTspClientId = "iphone-capp"

    /// Info.plist 中的客户端标识（由构建配置 TSP_CLIENT_ID 注入）
    static var tspClientId: String {
        if let value = Bundle.main.object(forInfoDictionaryKey: "TSPServerClientId") as? String,
           !value.isEmpty,
           !value.hasPrefix("$(") {
            return value
        }
        return defaultTspClientId
    }
}
