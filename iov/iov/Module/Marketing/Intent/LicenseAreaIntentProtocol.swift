//
//  VehicleIndexIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

import Foundation

protocol LicenseAreaIntentProtocol : MviIntentProtocol {
    /// 点击上牌区域
    func onTapLicenseArea(provinceCode: String, cityCode: String, displayName: String)
}
