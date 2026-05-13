//
//  EarnestMoneyPayTypes.swift
//  iov
//
//  Created on 2026/5/13.
//

import Foundation

enum EarnestMoneyPayTypes {
    enum Model {
        enum ContentState: Equatable {
            case loading
            case ready
            case paying
            case success
            case failed(text: String)
            case expired
        }
    }
}