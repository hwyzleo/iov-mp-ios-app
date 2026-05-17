//
//  DownPaymentPayTypes.swift
//  iov
//
//  Created on 2026/5/16.
//

import Foundation

enum DownPaymentPayTypes {
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