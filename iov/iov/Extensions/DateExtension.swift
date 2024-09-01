//
//  DateExtension.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import Foundation

extension Date {
    
    func timestamp() -> Int64 {
        return Int64(self.timeIntervalSince1970*1000)
    }
}
