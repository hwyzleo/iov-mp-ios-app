//
//  VehicleView+Build.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

extension LicenseAreaPage {
    
    static func buildContainer() -> some MviContainer<LicenseAreaIntentProtocol, LicenseAreaModelStateProtocol> {
        let model = LicenseAreaModel()
        let intent = LicenseAreaIntent(model: model)
        let container = MviContainer(
            intent: intent as LicenseAreaIntentProtocol,
            model: model as LicenseAreaModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    static func build() -> some View {
        return LicenseAreaPage(container: buildContainer())
    }
    
}
