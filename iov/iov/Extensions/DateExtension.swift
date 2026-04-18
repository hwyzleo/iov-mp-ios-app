//
//  DateExtension.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import Foundation

extension Date {
    
    func timestamp() -> Int64 {
        return Int64(self.timeIntervalSince1970*1000)
    }
}
