//
//  MyAccountQrcodeModelProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

// MARK: - View State

protocol MyAccountQrcodeModelStateProtocol {
    var contentState: MyAccountQrcodeTypes.Model.ContentState { get }
    var qrcode: String { get }
}

// MARK: - Intent Action

protocol MyAccountQrcodeModelActionProtocol: MviModelActionProtocol {
    func displayContent(qrcode: String)
}
