//
//  VehicleCenterView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct VehicleCenterPage: View {
    var body: some View {
        TopBackTitleBar(title: "车辆中心")
        VStack {
            LabelTabView(tabs: ["车辆状况", "保养提示"], views: [AnyView(VehicleCenterPage_VehicleStatus()), AnyView(VehicleCenterPage_Maintainance())])
        }
        .padding(20)
    }
}

#Preview {
    VehicleCenterPage()
}
