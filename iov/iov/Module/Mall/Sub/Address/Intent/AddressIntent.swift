//
//  AddressIntent.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

class AddressIntent: MviIntentProtocol {
    private weak var modelAction: AddressModelActionProtocol?
    private weak var modelRouter: AddressModelRouterProtocol?
    
    init(model: AddressModelActionProtocol & AddressModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    func viewOnAppear() {}
}

extension AddressIntent: AddressIntentProtocol {
    func onTapSaveAddressButton() {
        modelRouter?.closeScreen()
        modelRouter?.closeScreen()
    }
}
