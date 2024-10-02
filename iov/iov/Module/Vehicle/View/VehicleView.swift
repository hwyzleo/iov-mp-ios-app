//
//  VehicleView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import AVFoundation
import Kingfisher

struct VehicleView: View {
    
    @StateObject var container: MviContainer<VehicleIntentProtocol, VehicleModelStateProtocol>
    private var intent: VehicleIntentProtocol { container.intent }
    private var state: VehicleModelStateProtocol { container.model }
    
    var body: some View {
        ZStack {
            switch state.contentState {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(2)
            case .content:
                Content(intent: intent, vehicle: state.vehicle, lockLoading: state.lockLoading, lockDuration: state.lockDuration, windowLoading: state.windowLoading, windowDuration: state.windowDuration, trunkLoading: state.trunkLoading, trunkDuration: state.trunkDuration, findLoading: Binding.constant(state.findLoading), findDuration: Binding.constant(state.findDuration))
            case let .info(text):
                Content(intent: intent, vehicle: state.vehicle, lockLoading: state.lockLoading, lockDuration: state.lockDuration, windowLoading: state.windowLoading, windowDuration: state.windowDuration, trunkLoading: state.trunkLoading, trunkDuration: state.trunkDuration, findLoading: Binding.constant(state.findLoading), findDuration: Binding.constant(state.findDuration))
                InfoTip(text: text)
            case let .error(text):
                Content(intent: intent, vehicle: state.vehicle, lockLoading: state.lockLoading, lockDuration: state.lockDuration, windowLoading: state.windowLoading, windowDuration: state.windowDuration, trunkLoading: state.trunkLoading, trunkDuration: state.trunkDuration, findLoading: Binding.constant(state.findLoading), findDuration: Binding.constant(state.findDuration))
                ErrorTip(text: text)
            }
        }
        .onAppear {
            if state.vehicle == nil {
                intent.viewOnAppear()
            }
        }
        .modifier(VehicleRouter(
            subjects: state.routerSubject,
            intent: intent
        ))
    }
}

extension VehicleView {
    
    struct Content: View {
        var intent: VehicleIntentProtocol
        var vehicle: Vehicle?
        @State var lockLoading = false
        @State var lockDuration = 0.0
        @State var windowLoading = false
        @State var windowDuration = 0.0
        @State var trunkLoading = false
        @State var trunkDuration = 0.0
        @Binding var findLoading: Bool
        @Binding var findDuration: Double
        
        var body: some View {
            VStack {
                if let vehicle = vehicle {
                    VehicleView_TopBar()
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                    ScrollView {
                        VStack {
                            HStack {
                                Image(systemName: "car.front.waves.up")
                                    .font(.system(size: 14))
                                Image(systemName: "key.radiowaves.forward")
                                    .font(.system(size: 14))
                                Text("停放中")
                                    .font(.system(size: 14))
                                    .bold()
                                Divider()
                                Text("无法获取位置")
                                    .font(.system(size: 14))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            Spacer()
                                .frame(height: 50)
                            HStack {
                                Text("\(vehicle.drivingRange)")
                                    .font(.system(size: 50))
                                    .bold()
                                VStack(alignment: .leading) {
                                    Text("km")
                                        .font(.system(size: 16))
                                    Text("WLTC")
                                        .font(.system(size: 14))
                                }
                            }
                            HStack {
                                VStack {
                                    HStack(alignment: .bottom) {
                                        Image(systemName: "bolt.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.green)
                                        Text("\(vehicle.electricDrivingRange)")
                                            .font(.system(size: 18))
                                        Text("km")
                                            .font(.system(size: 12))
                                        Divider()
                                            .font(.system(size: 12))
                                        Text("\(vehicle.electricPercentage)%")
                                            .font(.system(size: 12))
                                    }
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .frame(width:100, height: 3)
                                            .foregroundColor(.gray)
                                        Rectangle()
                                            .frame(width:CGFloat(vehicle.electricPercentage), height: 3)
                                            .foregroundColor(.green)
                                    }
                                }
                                Spacer()
                                VStack {
                                    HStack(alignment: .bottom) {
                                        Image(systemName: "drop.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.blue)
                                        Text("\(vehicle.fuelDrivingRange)")
                                            .font(.system(size: 18))
                                        Text("km")
                                            .font(.system(size: 12))
                                        Divider()
                                            .font(.system(size: 12))
                                        Text("\(vehicle.fuelPercentage)%")
                                            .font(.system(size: 12))
                                    }
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .frame(width:100, height: 3)
                                            .foregroundColor(.gray)
                                        Rectangle()
                                            .frame(width:CGFloat(vehicle.fuelPercentage), height: 3)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .padding(.leading, 30)
                            .padding(.trailing, 30)
                            Spacer()
                                .frame(height: 50)
                            HStack {
                                if let bodyImg = vehicle.bodyImg {
                                    KFImage(URL(string: bodyImg)!)
                                        .resizable()
                                        .scaledToFit()
                                }
                            }
                            .padding(.leading, 50)
                            .padding(.trailing, 50)
                            Spacer()
                                .frame(height: 30)
                            HStack {
                                if vehicle.lockState {
                                    CircularImageButton(icon: "icon_lock", name: "解锁", isLoading: $lockLoading, duration: $lockDuration) {
                                        intent.onTapUnlock()
                                    }
                                } else {
                                    CircularImageButton(icon: "icon_lock", name: "上锁", isLoading: $lockLoading, duration: $lockDuration) {
                                        intent.onTapLock()
                                    }
                                }
                                Spacer()
                                if vehicle.windowPercentage > 0 {
                                    CircularImageButton(icon: "icon_window", name: "关窗", isLoading: $windowLoading, duration: $windowDuration) {
                                        intent.onTapSetWindow(percent: 0)
                                    }
                                } else {
                                    CircularImageButton(icon: "icon_window", name: "通风", isLoading: $windowLoading, duration: $windowDuration) {
                                        intent.onTapSetWindow(percent: 10)
                                    }
                                }
                                Spacer()
                                if vehicle.trunkPercentage > 0 {
                                    CircularImageButton(icon: "icon_trunk", iconSize: 15, name: "关尾门", isLoading: $trunkLoading, duration: $trunkDuration) {
                                        intent.onTapSetTrunk(percent: 0)
                                    }
                                } else {
                                    CircularImageButton(icon: "icon_trunk", iconSize: 15, name: "开尾门", isLoading: $trunkLoading, duration: $trunkDuration) {
                                        intent.onTapSetTrunk(percent: 80)
                                    }
                                }
                                Spacer()
                                CircularImageButton(icon: "icon_vehicle_search", iconSize: 15, name: "寻车", isLoading: $findLoading, duration: $findDuration) {
                                    intent.onTapFind()
                                }
                            }
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                        }
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        Spacer()
                            .frame(height: 20)
                        VStack {
                            VStack {
                                HStack {
                                    Text("常用功能")
                                        .font(.system(size: 16))
                                        .bold()
                                    Spacer()
                                    NavigationLink(destination: VehicleServiceView().navigationBarBackButtonHidden()) {
                                        Text("全部功能和服务 >")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
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
                                .padding(20)
                            }
                            .padding(10)
                            .background(.white)
                            .cornerRadius(5)
                        }
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        Spacer()
                            .frame(height: 20)
                        VStack {
                            VStack {
                                HStack {
                                    Text("空调和座椅")
                                        .font(.system(size: 16))
                                        .bold()
                                    Spacer()
                                    NavigationLink(destination: VehicleAcSeatView().navigationBarBackButtonHidden()) {
                                        Text("全部设置 >")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                    .buttonStyle(.plain)
                                }
                                Spacer()
                                    .frame(height: 20)
                                HStack {
                                    Text("\(vehicle.interiorTemp)")
                                        .font(.system(size: 28))
                                    Text("℃")
                                }
                                Text("车内温度")
                                    .font(.system(size: 14))
                                HStack {
                                    VStack {
                                        Button(action: {}) {
                                            VStack {
                                                Image(systemName: "sun.max")
                                                    .font(.system(size: 22))
                                                Text("极速升温")
                                                    .font(.system(size: 12))
                                                Text("HI")
                                                    .font(.system(size: 12))
                                            }
                                        }
                                        .frame(width: 80, height: 80)
                                        .background(Color.white)
                                        .cornerRadius(5)
                                        .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                                        .buttonStyle(.plain)
                                    }
                                    Spacer()
                                    VStack {
                                        Button(action: {}) {
                                            VStack {
                                                Image(systemName: "snowflake")
                                                    .font(.system(size: 22))
                                                Text("极速降温")
                                                    .font(.system(size: 12))
                                                Text("LO")
                                                    .font(.system(size: 12))
                                            }
                                        }
                                        .frame(width: 80, height: 80)
                                        .background(Color.white)
                                        .cornerRadius(5)
                                        .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                                        .buttonStyle(.plain)
                                    }
                                    Spacer()
                                    VStack {
                                        Button(action: {}) {
                                            VStack {
                                                Image(systemName: "thermometer.medium")
                                                    .font(.system(size: 22))
                                                Text("一键舒适")
                                                    .font(.system(size: 12))
                                                Text("24℃")
                                                    .font(.system(size: 12))
                                            }
                                        }
                                        .frame(width: 80, height: 80)
                                        .background(Color.white)
                                        .cornerRadius(5)
                                        .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(20)
                            }
                            .padding(10)
                            .background(.white)
                            .cornerRadius(5)
                        }
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        Spacer()
                            .frame(height: 20)
                        VStack {
                            VStack {
                                HStack {
                                    Text("车辆中心")
                                        .font(.system(size: 16))
                                        .bold()
                                    Spacer()
                                    NavigationLink(destination: VehicleCenterView().navigationBarBackButtonHidden()) {
                                        Text("查看详情 >")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                    .buttonStyle(.plain)
                                }
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("\(String(format: "%.1f", vehicle.flTirePressure)) bar")
                                        Divider()
                                        Text("\(vehicle.flTireTemp)℃")
                                        Spacer()
                                            .frame(height: 60)
                                        Text("\(String(format: "%.1f", vehicle.rlTirePressure)) bar")
                                        Divider()
                                        Text("\(vehicle.rlTireTemp)℃")
                                    }
                                    if let topImg = vehicle.topImg {
                                        KFImage(URL(string: topImg)!)
                                            .resizable()
                                            .scaledToFit()
                                    }
                                    VStack(alignment: .trailing) {
                                        Text("\(String(format: "%.1f", vehicle.frTirePressure)) bar")
                                        Divider()
                                        Text("\(vehicle.frTireTemp)℃")
                                        Spacer()
                                            .frame(height: 60)
                                        Text("\(String(format: "%.1f", vehicle.rrTirePressure)) bar")
                                        Divider()
                                        Text("\(vehicle.rrTireTemp)℃")
                                    }
                                }
                                .padding(20)
                            }
                            .padding(10)
                            .background(.white)
                            .cornerRadius(5)
                        }
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .background(Color(hex: 0xf8f8f8))
        }
    }
    
}

struct VehicleView_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState.shared
    static var previews: some View {
        VehicleView(container: VehicleView.buildContainer())
            .environmentObject(appGlobalState)
    }
}
