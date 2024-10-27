//
//  VehicleIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

class LicenseAreaIntent: MviIntentProtocol {
    private weak var modelAction: LicenseAreaModelActionProtocol?
    private weak var modelRouter: LicenseAreaModelRouterProtocol?
    
    init(model: LicenseAreaModelActionProtocol & LicenseAreaModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    func viewOnAppear() {
        TspApi.getLicenseArea() { (result: Result<TspResponse<[LicenseArea]>, Error>) in
            switch result {
            case .success(let res):
                if res.code == 0 {
                    self.modelAction?.displayProvince(licenseAreaList: res.data!)
                } else {
                    self.modelAction?.displayError(text: res.message ?? "请求异常")
                }
            case .failure(_):
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
}

extension LicenseAreaIntent: LicenseAreaIntentProtocol {
    func onTapLicenseArea(provinceCode: String, cityCode: String, displayName: String) {
        if cityCode.isEmpty {
            self.modelAction?.displayCity(provinceCode: provinceCode)
        } else {
            AppGlobalState.shared.parameters["licenseCityCode"] = cityCode
            AppGlobalState.shared.parameters["licenseCityName"] = displayName
            AppGlobalState.shared.backRefresh = true
            self.modelRouter?.closeScreen()
        }
    }
}
