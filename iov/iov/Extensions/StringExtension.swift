//
//  StringExtension.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import Foundation

extension String {
    /// 字符串转16进制Data
    func toHexData() -> Data {
        var data = Data(capacity: self.count / 2)

        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, options: [], range: NSRange(self.startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }

        return data
    }
}
