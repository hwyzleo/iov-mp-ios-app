//
//  DataExtension.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import Foundation

extension Data {
    /// 16进制转字符串
    func hexToStr() -> String {
        return map { String(format: "%02x", $0) }
            .joined(separator: "")
    }
}
