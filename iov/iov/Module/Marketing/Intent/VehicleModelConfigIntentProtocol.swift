//
//  VehicleIndexIntent.swift
//  iov
//
//  Created by hwyz_leo on 2024/10/6.
//

import Foundation

protocol VehicleModelConfigIntentProtocol: MviIntentProtocol {
    func onTapFeature(familyCode: String, feature: FeatureCodeDetailVo)
    func onTapSaveWishlist()
    func onTapOrder()
    func onTapReselectModel()
}