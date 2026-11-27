//
//  ExploreWebPolicy.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-012 on 2026/11/26.
//

import Foundation

enum ExploreWebNavigationDecision: Equatable {
    case allowInWebView
    case openExternally
    case block
}

/// H5 与官方文章 HTML 的统一导航策略。
enum ExploreWebPolicy {

    /// H5 目标只接受绝对 HTTPS URL
    static func isAllowedH5URL(_ url: URL) -> Bool {
        return isAbsoluteHTTPS(url) && url.user == nil && url.password == nil
    }

    static func isAbsoluteHTTPS(_ url: URL) -> Bool {
        guard url.scheme?.lowercased() == "https" else { return false }
        guard let host = url.host, !host.isEmpty else { return false }
        return true
    }

    /// 受管 H5：仅允许 HTTPS 在 WebView 内继续导航，其余协议一律拦截
    static func h5NavigationDecision(for url: URL) -> ExploreWebNavigationDecision {
        return isAbsoluteHTTPS(url) ? .allowInWebView : .block
    }

    /// 官方文章：空白初始页允许加载；HTTPS 链接交给系统浏览器；其余协议拦截
    static func articleNavigationDecision(for url: URL) -> ExploreWebNavigationDecision {
        if url.scheme?.lowercased() == "about" {
            return .allowInWebView
        }
        if isAbsoluteHTTPS(url) {
            return .openExternally
        }
        return .block
    }
}
