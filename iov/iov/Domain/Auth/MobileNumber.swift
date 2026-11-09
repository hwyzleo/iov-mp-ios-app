//
//  MobileNumber.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-001 on 2026/11/9.
//

import Foundation

/// 手机号格式化与校验（IOS-APP-DSN-CR-001 §5.1）
enum MobileNumber {
    static let mainlandLength = 11

    /// 去除分隔符与空白，仅保留数字
    static func normalized(_ raw: String) -> String {
        raw.filter { $0.isNumber }
    }

    /// 是否为可用的大陆手机号（11 位且以 1 开头）
    static func isValidMainlandMobile(_ raw: String) -> Bool {
        let digits = normalized(raw)
        return digits.count == mainlandLength && digits.hasPrefix("1")
    }

    /// 展示用格式化：3-4-4
    static func formatted(_ raw: String) -> String {
        let digits = normalized(raw)
        guard digits.count > 3 else { return digits }
        if digits.count <= 7 {
            return "\(digits.prefix(3)) \(digits.dropFirst(3))"
        }
        let prefix = digits.prefix(3)
        let middle = digits.dropFirst(3).prefix(4)
        let suffix = digits.dropFirst(7).prefix(4)
        return "\(prefix) \(middle) \(suffix)"
    }

    /// 日志脱敏：仅保留前 3 位与后 2 位
    static func masked(_ raw: String) -> String {
        let digits = normalized(raw)
        guard digits.count > 5 else { return "***" }
        return "\(digits.prefix(3))****\(digits.suffix(2))"
    }
}
