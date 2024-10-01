//
//  VehicleAcSeatView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct VehicleAcSeatView: View {
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Image(systemName: "chevron.backward")
                    Spacer()
                }
                HStack {
                    Spacer()
                    Text("更多设置")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                }
                HStack {
                    Spacer()
                    Text("空调")
                        .font(.system(size: 18))
                        .bold()
                    Spacer()
                        .frame(width: 20)
                    Text("座椅")
                        .font(.system(size: 18))
                    Spacer()
                }
            }
            ScrollView {
                VehicleAcSeatView_Ac()
            }
        }
        .padding(20)
    }
}

#Preview {
    VehicleAcSeatView()
}
