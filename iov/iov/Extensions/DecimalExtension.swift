//
//  DecimalExtension.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/13.
//

import Foundation

extension Decimal {
    func formatted(minimumFractionDigits: Int = 2,
                   maximumFractionDigits: Int = 2,
                   roundingMode: NumberFormatter.RoundingMode = .halfUp,
                   usesGroupingSeparator: Bool = true) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = minimumFractionDigits
        formatter.maximumFractionDigits = maximumFractionDigits
        formatter.roundingMode = roundingMode
        formatter.usesGroupingSeparator = usesGroupingSeparator
        
        return formatter.string(from: self as NSNumber) ?? "\(self)"
    }
}
