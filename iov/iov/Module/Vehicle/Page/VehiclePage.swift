//
//  VehicleView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import AVFoundation
import Kingfisher

struct VehiclePage: View {
    
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
            intent.viewOnAppear()
        }
        .modifier(VehicleRouter(
            subjects: state.routerSubject,
            intent: intent
        ))
    }
}

extension VehiclePage {
    
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
            VStack(spacing: 0) {
                if let vehicle = vehicle {
                    VehiclePage_TopBar()
                        .padding(.horizontal, AppTheme.layout.margin)
                        .padding(.bottom, 10)
                    
                    ScrollView {
                        VStack(spacing: AppTheme.layout.spacing) {
                            // 车辆状态摘要
                            HStack(spacing: 12) {
                                Image(systemName: "car.front.waves.up")
                                Image(systemName: "key.radiowaves.forward")
                                Text("停放中")
                                    .font(AppTheme.fonts.subtext)
                                    .bold()
                                Divider().frame(height: 12)
                                Text("无法获取位置")
                                    .font(AppTheme.fonts.subtext)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                            }
                            .foregroundColor(AppTheme.colors.fontSecondary)
                            .padding(.horizontal, 4)
                            
                            // 续航里程显示
                            VStack(spacing: 8) {
                                HStack(alignment: .lastTextBaseline, spacing: 4) {
                                    Text("\(vehicle.drivingRange)")
                                        .font(.system(size: 64, weight: .bold, design: .rounded))
                                        .foregroundColor(AppTheme.colors.fontPrimary)
                                    Text("km")
                                        .font(AppTheme.fonts.title1)
                                        .foregroundColor(AppTheme.colors.fontSecondary)
                                }
                                Text("WLTC 综合续航")
                                    .font(AppTheme.fonts.subtext)
                                    .foregroundColor(AppTheme.colors.fontTertiary)
                            }
                            .padding(.vertical, 20)
                            
                            // 能源分布卡片
                            HStack(spacing: 20) {
                                EnergyProgress(icon: "bolt.fill", value: vehicle.electricDrivingRange, percentage: vehicle.electricPercentage, color: .green)
                                EnergyProgress(icon: "drop.fill", value: vehicle.fuelDrivingRange, percentage: vehicle.fuelPercentage, color: AppTheme.colors.brandMain)
                            }
                            .appCardStyle(radius: AppTheme.layout.radiusMedium)
                            
                            // 车辆 3D 预览图
                            if let bodyImg = vehicle.bodyImg {
                                KFImage(URL(string: bodyImg)!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 180)
                                    .padding(.vertical, 10)
                            }
                            
                            // 快捷控车按钮
                            HStack {
                                ControlButton(icon: "icon_lock", name: vehicle.lockState ? "解锁" : "上锁", loading: lockLoading) {
                                    vehicle.lockState ? intent.onTapUnlock() : intent.onTapLock()
                                }
                                Spacer()
                                ControlButton(icon: "icon_window", name: vehicle.windowPercentage > 0 ? "关窗" : "通风", loading: windowLoading) {
                                    intent.onTapSetWindow(percent: vehicle.windowPercentage > 0 ? 0 : 10)
                                }
                                Spacer()
                                ControlButton(icon: "icon_trunk", name: vehicle.trunkPercentage > 0 ? "关尾门" : "开尾门", loading: trunkLoading) {
                                    intent.onTapSetTrunk(percent: vehicle.trunkPercentage > 0 ? 0 : 80)
                                }
                                Spacer()
                                ControlButton(icon: "icon_vehicle_search", name: "寻车", loading: findLoading) {
                                    intent.onTapFind()
                                }
                            }
                            .padding(.horizontal, 10)
                            
                            // 功能模块卡片组
                            VStack(spacing: AppTheme.layout.spacing) {
                                // 常用功能
                                FeatureGridSection(title: "常用功能", detailText: "全部服务", destination: VehicleServicePage()) {
                                    FeatureItem(icon: "car.top.lane.dashed.badge.steeringwheel", name: "智驾学习")
                                    FeatureItem(icon: "key", name: "蓝牙钥匙")
                                    FeatureItem(icon: "figure.child.and.lock", name: "车辆授权")
                                }
                                
                                // 车内环境
                                FeatureSection(title: "车内环境", detailText: "调节", destination: VehicleAcSeatPage()) {
                                    VStack(spacing: 16) {
                                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                                            Text("\(vehicle.interiorTemp)")
                                                .font(.system(size: 36, weight: .medium))
                                            Text("℃")
                                                .font(.system(size: 16))
                                        }
                                        .foregroundColor(AppTheme.colors.fontPrimary)
                                        
                                        HStack(spacing: 12) {
                                            QuickActionBtn(icon: "sun.max", label: "急速升温", sub: "HI")
                                            QuickActionBtn(icon: "snowflake", label: "急速降温", sub: "LO")
                                            QuickActionBtn(icon: "thermometer.medium", label: "一键舒适", sub: "24℃")
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.layout.margin)
                        .padding(.bottom, 40)
                    }
                }
            }
            .appBackground()
        }
    }
}

// MARK: - 局部辅助组件
private struct EnergyProgress: View {
    var icon: String
    var value: Int
    var percentage: Int
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text("\(value)km")
                    .font(.system(size: 14, weight: .bold))
                Spacer()
                Text("\(percentage)%")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.1)).frame(height: 4)
                    Capsule().fill(color).frame(width: geo.size.width * CGFloat(percentage) / 100, height: 4)
                }
            }
            .frame(height: 4)
        }
    }
}

private struct ControlButton: View {
    var icon: String
    var name: String
    var loading: Bool
    var action: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Button(action: action) {
                ZStack {
                    Circle()
                        .fill(AppTheme.colors.cardBackground)
                        .frame(width: 60, height: 60)
                    if loading {
                        ProgressView().tint(AppTheme.colors.brandMain)
                    } else {
                        Image(icon)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(AppTheme.colors.fontPrimary)
                            .frame(width: 24, height: 24)
                    }
                }
            }
            Text(name)
                .font(AppTheme.fonts.subtext)
                .foregroundColor(AppTheme.colors.fontSecondary)
        }
    }
}

private struct FeatureSection<Content: View>: View {
    var title: String
    var detailText: String
    var destination: any View
    let content: Content
    
    init(title: String, detailText: String, destination: any View, @ViewBuilder content: () -> Content) {
        self.title = title
        self.detailText = detailText
        self.destination = destination
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title).font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                Spacer()
                Text(detailText).font(.system(size: 12)).foregroundColor(.gray)
                Image(systemName: "chevron.right").font(.system(size: 10)).foregroundColor(.gray)
            }
            content
        }
        .appCardStyle(radius: AppTheme.layout.radiusMedium)
    }
}

private struct FeatureGridSection<Content: View>: View {
    var title: String
    var detailText: String
    var destination: any View
    let content: Content
    
    init(title: String, detailText: String, destination: any View, @ViewBuilder content: () -> Content) {
        self.title = title
        self.detailText = detailText
        self.destination = destination
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title).font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                Spacer()
                Text(detailText).font(.system(size: 12)).foregroundColor(.gray)
                Image(systemName: "chevron.right").font(.system(size: 10)).foregroundColor(.gray)
            }
            HStack(spacing: 0) {
                content
            }
        }
        .appCardStyle(radius: AppTheme.layout.radiusMedium)
    }
}

private struct FeatureItem: View {
    var icon: String
    var name: String
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppTheme.colors.brandMain)
            Text(name)
                .font(.system(size: 12))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct QuickActionBtn: View {
    var icon: String
    var label: String
    var sub: String
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 18))
            Text(label).font(.system(size: 11))
            Text(sub).font(.system(size: 10)).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(AppTheme.layout.radiusSmall)
    }
}
