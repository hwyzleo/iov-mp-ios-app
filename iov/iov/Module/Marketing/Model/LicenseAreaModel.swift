//
//  VehicleModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class LicenseAreaModel: ObservableObject, LicenseAreaModelStateProtocol {
    @Published var contentState: MarketingTypes.Model.LicenseAreaContentState = .loading
    let routerSubject = MarketingRouter.Subjects()
    var licenseAreaList: [LicenseArea] = []
    @Published var displayLicenseAreaList: [LicenseArea] = []
}

// MARK: - Action Protocol

extension LicenseAreaModel: LicenseAreaModelActionProtocol {
    func displayLoading() {
        contentState = .content
    }
    func displayError(text: String) {
        contentState = .error(text: text)
    }
    func displayProvince(licenseAreaList: [LicenseArea]) {
        self.licenseAreaList = licenseAreaList
        self.displayLicenseAreaList = []
        for area in licenseAreaList {
            if area.cityCode == nil {
                self.displayLicenseAreaList.append(area)
            }
        }
        contentState = .content
    }
    func displayCity(provinceCode: String) {
        self.displayLicenseAreaList = []
        for area in licenseAreaList {
            if area.cityCode != nil && area.provinceCode == provinceCode {
                self.displayLicenseAreaList.append(area)
            }
        }
    }
}

// MARK: - Route

extension LicenseAreaModel: LicenseAreaModelRouterProtocol {
    func closeScreen() {
        routerSubject.close.send()
    }
}

extension MarketingTypes.Model {
    enum LicenseAreaContentState {
        case loading
        case content
        case error(text: String)
    }
}
