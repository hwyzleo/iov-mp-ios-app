//
//  VehicleCenterView_Maintainance.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

struct VehicleCenterPage_Maintainance: View {
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("常规保养")
                            .font(.system(size: 16))
                            .bold()
                            .padding(.bottom, 2)
                            .padding(.top, 10)
                        Text("1年/10000公里")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.bottom, 10)
                    }
                    Spacer()
                }
                Divider()
                HStack {
                    VStack(alignment: .leading) {
                        Text("空气滤芯")
                            .font(.system(size: 16))
                            .bold()
                            .padding(.bottom, 2)
                            .padding(.top, 10)
                        Text("1年/20000公里")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.bottom, 10)
                    }
                    Spacer()
                }
                Divider()
                HStack {
                    VStack(alignment: .leading) {
                        Text("空调滤芯")
                            .font(.system(size: 16))
                            .bold()
                            .padding(.bottom, 2)
                            .padding(.top, 10)
                        Text("1年/20000公里")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.bottom, 10)
                    }
                    Spacer()
                }
                Divider()
                HStack {
                    VStack(alignment: .leading) {
                        Text("火花塞")
                            .font(.system(size: 16))
                            .bold()
                            .padding(.bottom, 2)
                            .padding(.top, 10)
                        Text("30000公里")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.bottom, 10)
                    }
                    Spacer()
                }
                Divider()
                HStack {
                    VStack(alignment: .leading) {
                        Text("制动液")
                            .font(.system(size: 16))
                            .bold()
                            .padding(.bottom, 2)
                            .padding(.top, 10)
                        Text("4年/80000公里")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.bottom, 10)
                    }
                    Spacer()
                }
                Divider()
                HStack {
                    VStack(alignment: .leading) {
                        Text("冷却液")
                            .font(.system(size: 16))
                            .bold()
                            .padding(.bottom, 2)
                            .padding(.top, 10)
                        Text("6年/120000公里")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.bottom, 10)
                    }
                    Spacer()
                }
                Divider()
            }
            .padding(20)
        }
        HStack {
            Button(action: {}) {
                Text("预约维保")
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .foregroundColor(.white)
            .background(Color.black)
            .cornerRadius(20)
            .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
            .buttonStyle(.plain)
        }
        .padding(20)
    }
}

#Preview {
    VehicleCenterPage_Maintainance()
}
