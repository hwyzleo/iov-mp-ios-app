//
//  VehiclePage.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
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
                    .tint(AppTheme.colors.brandMain)
                    .scaleEffect(1.5)
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
                // 解决状态栏重叠
                Spacer().frame(height: kStatusBarHeight)
                
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
                                Text(vehicle.lockState ? "已落锁" : "未上锁")
                                    .font(AppTheme.fonts.subtext)
                                    .bold()
                                Divider().frame(height: 12).background(Color.white.opacity(0.2))
                                Text("蓝牙连接中")
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
                            .padding(.vertical, 10)
                            
                            // 能源分布卡片
                            HStack(spacing: 20) {
                                EnergyProgress(icon: "bolt.fill", value: vehicle.electricDrivingRange, percentage: vehicle.electricPercentage, color: Color(hex: "#00E676"))
                                EnergyProgress(icon: "drop.fill", value: vehicle.fuelDrivingRange, percentage: vehicle.fuelPercentage, color: AppTheme.colors.brandMain)
                            }
                            .appCardStyle()
                            
                            // 车辆图片预览
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
                            
                            // 功能模块
                            VStack(spacing: AppTheme.layout.spacing) {
                                FeatureGridSection(title: "常用功能", detailText: "全部服务") {
                                    FeatureItem(icon: "steeringwheel", name: "智驾学习")
                                    FeatureItem(icon: "key.fill", name: "蓝牙钥匙")
                                    FeatureItem(icon: "person.badge.key.fill", name: "车辆授权")
                                }
                                
                                FeatureSection(title: "车内环境", detailText: "调节") {
                                    VStack(spacing: 20) {
                                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                                            Text("\(vehicle.interiorTemp)")
                                                .font(.system(size: 36, weight: .medium, design: .rounded))
                                            Text("℃")
                                                .font(.system(size: 16))
                                        }
                                        .foregroundColor(AppTheme.colors.fontPrimary)
                                        
                                        HStack(spacing: 12) {
                                            QuickActionBtn(icon: "sun.max.fill", label: "急速升温", sub: "HI")
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

// MARK: - 辅助组件
private struct EnergyProgress: View {
    var icon: String
    var value: Int
    var percentage: Int
    var color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 10)).foregroundColor(color)
                Text("\(value)km").font(.system(size: 14, weight: .bold)).foregroundColor(AppTheme.colors.fontPrimary)
                Spacer()
                Text("\(percentage)%").font(.system(size: 10)).foregroundColor(AppTheme.colors.fontSecondary)
            }
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.05)).frame(height: 4)
                Capsule().fill(color).frame(width: 60 * CGFloat(percentage) / 100, height: 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
                    Circle().fill(AppTheme.colors.cardBackground).frame(width: 60, height: 60)
                    if loading {
                        ProgressView().tint(AppTheme.colors.brandMain)
                    } else {
                        Image(icon).resizable().renderingMode(.template).foregroundColor(AppTheme.colors.fontPrimary).frame(width: 24, height: 24)
                    }
                }
            }
            Text(name).font(AppTheme.fonts.subtext).foregroundColor(AppTheme.colors.fontSecondary)
        }
    }
}

private struct FeatureSection<Content: View>: View {
    var title: String
    var detailText: String
    let content: Content
    init(title: String, detailText: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.detailText = detailText
        self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title).font(AppTheme.fonts.title1).foregroundColor(AppTheme.colors.fontPrimary)
                Spacer()
                Text(detailText).font(AppTheme.fonts.subtext).foregroundColor(AppTheme.colors.fontSecondary)
                Image(systemName: "chevron.right").font(.system(size: 10)).foregroundColor(AppTheme.colors.fontTertiary)
            }
            content
        }
        .appCardStyle()
    }
}

private struct FeatureGridSection<Content: View>: View {
    var title: String
    var detailText: String
    let content: Content
    init(title: String, detailText: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.detailText = detailText
        self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title).font(AppTheme.fonts.title1).foregroundColor(AppTheme.colors.fontPrimary)
                Spacer()
                Text(detailText).font(AppTheme.fonts.subtext).foregroundColor(AppTheme.colors.fontSecondary)
                Image(systemName: "chevron.right").font(.system(size: 10)).foregroundColor(AppTheme.colors.fontTertiary)
            }
            HStack(spacing: 0) { content }
        }
        .appCardStyle()
    }
}

private struct FeatureItem: View {
    var icon: String
    var name: String
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 22)).foregroundColor(AppTheme.colors.brandMain)
            Text(name).font(.system(size: 12)).foregroundColor(AppTheme.colors.fontPrimary)
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
            Image(systemName: icon).font(.system(size: 18)).foregroundColor(AppTheme.colors.fontPrimary)
            Text(label).font(.system(size: 11)).foregroundColor(AppTheme.colors.fontPrimary)
            Text(sub).font(.system(size: 10)).foregroundColor(AppTheme.colors.fontSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(AppTheme.layout.radiusSmall)
    }
}
