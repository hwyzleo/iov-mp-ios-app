//
//  VehicleSettingView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct VehicleSettingPage: View {
    var body: some View {
        TopBackTitleBar(title: "车辆设置")
        VStack {
            HStack {
                Text("车辆信息")
                    .font(.system(size: 18))
                    .bold()
                Spacer()
            }
            Spacer()
                .frame(height: 40)
            HStack {
                Text("车辆名称")
                Spacer()
                Text("开源汽车")
                    .foregroundColor(.gray)
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            Divider()
                .padding(.top, 20)
                .padding(.bottom, 20)
            HStack {
                Text("车架号")
                Spacer()
                Text("VIN00000000000000")
                    .foregroundColor(.gray)
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            Divider()
                .padding(.top, 20)
                .padding(.bottom, 20)
            HStack {
                Text("实名认证")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            Divider()
                .padding(.top, 20)
                .padding(.bottom, 20)
            HStack {
                Text("车辆软件版本")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            Divider()
                .padding(.top, 20)
                .padding(.bottom, 20)
            HStack {
                Text("紧急联系人")
                Spacer()
                Text("设置")
                    .foregroundColor(.gray)
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(20)
    }
}

#Preview {
    VehicleSettingPage()
}
