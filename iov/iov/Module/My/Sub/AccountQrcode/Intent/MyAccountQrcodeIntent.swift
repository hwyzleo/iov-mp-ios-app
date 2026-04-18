//
//  MyAccountQrcodeIntent.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

class MyAccountQrcodeIntent: MviIntentProtocol {
    private weak var modelAction: MyAccountQrcodeModelActionProtocol?
    
    init(model: MyAccountQrcodeModelActionProtocol) {
        self.modelAction = model
    }
    
    func viewOnAppear() {
        modelAction?.displayLoading()
        TspApi.getAccountQrcode { (result: Result<TspResponse<AccountQrcode>, Error>) in
            switch result {
            case .success(let response):
                if response.isSuccess {
                    self.modelAction?.displayContent(qrcode: response.data?.qrcode ?? "")
                } else {
                    self.modelAction?.displayError(text: response.message ?? "未知错误")
                }
            case .failure(let error):
                self.modelAction?.displayError(text: error.localizedDescription)
            }
        }
    }
}

extension MyAccountQrcodeIntent: MyAccountQrcodeIntentProtocol {
}
