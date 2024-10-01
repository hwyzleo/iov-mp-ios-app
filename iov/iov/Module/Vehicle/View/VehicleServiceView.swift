//
//  VehicleServiceView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct VehicleServiceView: View {
    var body: some View {
        TopBackTitleBar(title: "全部功能和服务")
        VStack {
            HStack {
                Text("首页常用功能")
                    .font(.system(size: 18))
                    .bold()
                Spacer()
                Text("自定义")
            }
            HStack {
                VStack {
                    Image(systemName: "car.top.lane.dashed.badge.steeringwheel")
                        .font(.system(size: 34))
                    Text("智驾学习")
                        .font(.system(size: 14))
                }
                Spacer()
                VStack {
                    Image(systemName: "key")
                        .font(.system(size: 30))
                    Text("蓝牙钥匙")
                        .font(.system(size: 14))
                }
                Spacer()
                VStack {
                    Image(systemName: "figure.child.and.lock")
                        .font(.system(size: 34))
                    Text("车辆授权")
                        .font(.system(size: 14))
                }
            }
            .padding(30)
            .background(Color(hex: 0xf8f8f8))
            .cornerRadius(5)
            Spacer()
                .frame(height: 30)
            HStack {
                Text("车控车设")
                    .font(.system(size: 18))
                    .bold()
                Spacer()
            }
            VStack {
                HStack {
                    VStack {
                        Image(systemName: "car.top.lane.dashed.badge.steeringwheel")
                            .font(.system(size: 34))
                        Text("智驾学习")
                            .font(.system(size: 14))
                    }
                    Spacer()
                    VStack {
                        Image(systemName: "key")
                            .font(.system(size: 30))
                        Text("蓝牙钥匙")
                            .font(.system(size: 14))
                    }
                    Spacer()
                    VStack {
                        Image(systemName: "figure.child.and.lock")
                            .font(.system(size: 34))
                        Text("车辆授权")
                            .font(.system(size: 14))
                    }
                }
                Spacer()
                    .frame(height: 30)
                HStack {
                    VStack {
                        Image(systemName: "pawprint")
                            .font(.system(size: 34))
                        Text("宠物模式")
                            .font(.system(size: 14))
                    }
                    Spacer()
                    VStack {
                        Image(systemName: "key")
                            .font(.system(size: 30))
                        Text("蓝牙钥匙")
                            .font(.system(size: 14))
                    }
                    Spacer()
                    VStack {
                        Image(systemName: "figure.child.and.lock")
                            .font(.system(size: 34))
                        Text("车辆授权")
                            .font(.system(size: 14))
                    }
                }
            }
            .padding(30)
            .background(Color(hex: 0xf8f8f8))
            .cornerRadius(5)
            Spacer()
                .frame(height: 30)
            Spacer()
        }
        .padding(20)
    }
}

#Preview {
    VehicleServiceView()
}
