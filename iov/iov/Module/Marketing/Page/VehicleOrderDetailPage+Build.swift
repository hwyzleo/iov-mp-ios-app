//
//  VehicleView+Build.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

extension VehicleOrderDetailPage {
    
    static func buildContainer(orderNo: String = "") -> some MviContainer<VehicleOrderDetailIntentProtocol, VehicleOrderDetailModelStateProtocol> {
        let model = VehicleOrderDetailModel()
        let intent = VehicleOrderDetailIntent(model: model, orderNo: orderNo)
        let container = MviContainer(
            intent: intent as VehicleOrderDetailIntentProtocol,
            model: model as VehicleOrderDetailModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        return container
    }
    
    /// 构建订单详情页
    /// - Note: 这里绝对不能写入 `AppGlobalState.shared.parameters`。
    ///   `build` 是在 `navigationDestination` 的视图求值过程中被调用的，
    ///   向 `@Published` 属性写入会触发 "Publishing changes from within view updates is not allowed"，
    ///   并导致「发布 → 重绘 → 再次 build → 再次发布」的无限循环。
    ///   订单号改为通过 Intent 直接传递。
    static func build(orderNo: String = "") -> some View {
        VehicleOrderDetailPage(container: buildContainer(orderNo: orderNo))
    }
    
}
