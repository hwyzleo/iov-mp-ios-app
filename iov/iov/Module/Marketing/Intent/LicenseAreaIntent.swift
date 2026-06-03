//
//  VehicleIntent.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
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
        AppGlobalState.shared.backRefresh = false
        modelAction?.displayLoading()
        ServiceContainer.marketingService.getLicenseArea { [weak self] (result: Result<TspResponse<[LicenseArea]>, Error>) in
            switch result {
            case .success(let res):
                if res.isSuccess {
                    guard let resData = res.data else {
                        self?.modelAction?.displayError(text: "数据异常")
                        return
                    }
                    self?.modelAction?.displayProvince(licenseAreaList: resData)
                } else {
                    self?.modelAction?.displayError(text: res.message ?? "请求异常")
                }
            case .failure(_):
                self?.modelAction?.displayError(text: "请求异常")
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
            let fullDisplayName = buildFullDisplayName(provinceCode: provinceCode, cityCode: cityCode, displayName: displayName)
            AppGlobalState.shared.parameters["licenseCityName"] = fullDisplayName
            AppGlobalState.shared.backRefresh = true
            AppRouter.shared.pop()
        }
    }
    
    private func buildFullDisplayName(provinceCode: String, cityCode: String, displayName: String) -> String {
        let provinceName = Provinces[provinceCode] ?? ""
        let cityName = Cities[cityCode] ?? displayName
        
        if provinceName.isEmpty || provinceName == cityName {
            return cityName
        }
        
        return provinceName + cityName
    }
}
