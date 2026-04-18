//
//  MyAccountQrcodeTypes.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import Foundation

enum MyAccountQrcodeTypes {
    enum Model {
        enum ContentState {
            case loading
            case content
            case error(text: String)
        }
    }
}
