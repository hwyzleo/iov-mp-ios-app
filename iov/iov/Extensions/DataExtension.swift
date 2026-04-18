//
//  DataExtension.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import Foundation

extension Data {
    /// 16进制转字符串
    func hexToStr() -> String {
        return map { String(format: "%02x", $0) }
            .joined(separator: "")
    }
}
