//
//  SafeLog.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-001 on 2026/11/9.
//

import Foundation

/// 日志脱敏边界（IOS-APP-DSN-CR-001 RD-001-8 / US-001-7）
/// 禁止输出原始 Access Token、Refresh Token、Authorization、验证码、完整手机号或完整登录响应。
enum SafeLog {

    private static let jsonSensitivePattern = "(?i)\"?(accessToken|refreshToken|refresh_token|access_token|token|authorization|password|code|mobile|phone)\"?\\s*[:=]\\s*\"?([^\",\\s\\)\\]\\}]+)\"?"
    private static let bearerPattern = "(?i)bearer\\s+[A-Za-z0-9._\\-]+"
    private static let mainlandMobilePattern = "\\b1[3-9]\\d{9}\\b"

    /// 脱敏任意日志文本
    static func sanitized(_ text: String) -> String {
        var result = text
        result = replace(pattern: bearerPattern, template: "Bearer ***", in: result)
        result = replace(pattern: jsonSensitivePattern, template: "$1=***", in: result)
        result = replaceMainlandMobile(in: result)
        return result
    }

    /// 脱敏请求参数
    static func redacted(parameters: [String: Any]?) -> String {
        guard let parameters = parameters else { return "nil" }
        return sanitized(String(describing: parameters))
    }

    /// 脱敏请求头
    static func redacted(headers: Any?) -> String {
        guard let headers = headers else { return "nil" }
        return sanitized(String(describing: headers))
    }

    /// 脱敏响应体
    static func redacted(responseBody: String) -> String {
        return sanitized(responseBody)
    }

    /// 输出脱敏日志
    static func log(_ items: Any...) {
        #if DEBUG
        let message = items.map { item -> String in
            if let text = item as? String {
                return sanitized(text)
            }
            return sanitized(String(describing: item))
        }.joined(separator: " ")
        print(message)
        #endif
    }

    // MARK: - Private

    private static func replace(pattern: String, template: String, in text: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return text
        }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: template)
    }

    private static func replaceMainlandMobile(in text: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: mainlandMobilePattern, options: []) else {
            return text
        }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        let matches = regex.matches(in: text, options: [], range: range)
        guard !matches.isEmpty else { return text }

        var result = text
        for match in matches.reversed() {
            guard let matchRange = Range(match.range, in: result) else { continue }
            result.replaceSubrange(matchRange, with: MobileNumber.masked(String(result[matchRange])))
        }
        return result
    }
}
