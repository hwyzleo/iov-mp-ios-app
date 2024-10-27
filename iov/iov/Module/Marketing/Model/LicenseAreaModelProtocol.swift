//
//  VehicleModelProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

// MARK: - View State

protocol LicenseAreaModelStateProtocol {
    var contentState: MarketingTypes.Model.LicenseAreaContentState { get }
    var routerSubject: MarketingRouter.Subjects { get }
    var displayLicenseAreaList: [LicenseArea] { get }
}

// MARK: - Intent Action

protocol LicenseAreaModelActionProtocol: MviModelActionProtocol {
    /// 显示省市列表
    func displayProvince(licenseAreaList: [LicenseArea])
    /// 显示省市下级列表
    func displayCity(provinceCode: String)
}

// MARK: - Route

protocol LicenseAreaModelRouterProtocol: MviModelRouterProtocol {

}
