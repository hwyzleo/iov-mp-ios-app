//
//  VehicleAcSeatView_Ac.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct VehicleAcSeatView_Ac: View {
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 20)
            Text("26")
                .font(.system(size: 50))
            Text("车内温度")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            HStack {
                Spacer()
                Text("车外温度")
                    .font(.system(size: 14))
                Text("18")
                    .font(.system(size: 14))
                Divider()
                Text("空气质量")
                    .font(.system(size: 14))
                Text("26")
                    .font(.system(size: 14))
                Spacer()
            }
            Spacer()
                .frame(height: 300)
            HStack {
                Image(systemName: "minus.circle")
                    .font(.system(size: 30))
                Spacer()
                    .frame(width: 30)
                Text("25")
                    .font(.system(size: 35))
                    .bold()
                Text("℃")
                Spacer()
                    .frame(width: 30)
                Image(systemName: "plus.circle")
                    .font(.system(size: 30))
            }
            HStack {
                VStack {
                    Button(action: {}) {
                        VStack {
                            Image(systemName: "sun.max")
                                .font(.system(size: 26))
                            Text("极速升温")
                                .font(.system(size: 12))
                        }
                    }
                    .frame(width: 80, height: 80)
                    .buttonStyle(.plain)
                }
                Spacer()
                VStack {
                    Button(action: {}) {
                        VStack {
                            Image(systemName: "snowflake")
                                .font(.system(size: 26))
                            Text("极速降温")
                                .font(.system(size: 12))
                        }
                    }
                    .frame(width: 80, height: 80)
                    .buttonStyle(.plain)
                }
                Spacer()
                VStack {
                    Button(action: {}) {
                        VStack {
                            Image(systemName: "windshield.front.and.heat.waves")
                                .font(.system(size: 24))
                            Text("前除霜")
                                .font(.system(size: 12))
                        }
                    }
                    .frame(width: 80, height: 80)
                    .buttonStyle(.plain)
                }
                Spacer()
                VStack {
                    Button(action: {}) {
                        VStack {
                            Image(systemName: "suv.side.air.circulate")
                                .font(.system(size: 24))
                                .padding(.bottom, 0.5)
                            Text("内循环")
                                .font(.system(size: 12))
                        }
                    }
                    .frame(width: 80, height: 80)
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
            HStack {
                Button(action: {}) {
                    Text("开启空调")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                .buttonStyle(.plain)
            }
            .padding(20)
        }
    }
}

#Preview {
    VehicleAcSeatView_Ac()
}
