//
//  MyIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

class MyIntent: MviIntentProtocol {
    private weak var modelAction: MyModelActionProtocol?
    private weak var modelRouter: MyModelRouterProtocol?
    
    init(model: MyModelActionProtocol & MyModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    func viewOnAppear() {
        modelAction?.displayLoading()
        if UserManager.isLogin() {
            modelAction?.displayLogin()
        } else {
            modelAction?.displayNotLogin()
        }
    }
}

extension MyIntent: MyIntentProtocol {
    func onTapLogin() {
        modelRouter?.routeToLogin()
    }
    func onTapMessage() {
        modelRouter?.routeToMessage()
    }
    func onTapSetting() {
        modelRouter?.routeToSetting()
    }
    func onTapProfile() {
        modelRouter?.routeToProfile()
    }
    func onTapMyArticle() {
        modelRouter?.routeToMyArticle()
    }
    func onTapMyPoints() {
        modelRouter?.routeToMyPoints()
    }
    func onTapMyRights() {
        modelRouter?.routeToMyRights()
    }
    func onTapMyOrder() {
        modelRouter?.routeToMyOrder()
    }
    func onTapMyInvite() {
        modelRouter?.routeToMyInvite()
    }
    func onTapTestDriveReport() {
        modelRouter?.routeToTestDriveReport()
    }
    func onTapChargingPile() {
        modelRouter?.routeToChargingPile()
    }
}
