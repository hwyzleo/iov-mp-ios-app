//
//  MyAccountQrcodeModel.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

final class MyAccountQrcodeModel: ObservableObject, MyAccountQrcodeModelStateProtocol {
    @Published var contentState: MyAccountQrcodeTypes.Model.ContentState = .loading
    @Published var qrcode: String = ""
}

// MARK: - Action Protocol

extension MyAccountQrcodeModel: MyAccountQrcodeModelActionProtocol {
    func displayLoading() {
        contentState = .loading
    }
    
    func displayContent(qrcode: String) {
        self.qrcode = qrcode
        contentState = .content
    }
    
    func displayError(text: String) {
        contentState = .error(text: text)
    }
}
