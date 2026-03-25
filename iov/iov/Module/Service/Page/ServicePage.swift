//
//  ServiceView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import Kingfisher

struct ServicePage: View {
    
    @StateObject var container: MviContainer<ServiceIntentProtocol, ServiceModelStateProtocol>
    private var intent: ServiceIntentProtocol { container.intent }
    private var state: ServiceModelStateProtocol { container.model }
    
    var body: some View {
        ZStack {
            switch state.contentState {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(2)
            case .content:
                Content(intent: intent, state: state)
            case let .error(text):
                ErrorTip(text: text)
            }
        }
        .onAppear {
            if state.contentBlocks.count == 0 {
                intent.viewOnAppear()
            }
        }
        .modifier(ServiceRouter(
            subjects: state.routerSubject,
            intent: intent
        ))
    }
}

extension ServicePage {
    
    struct Content: View {
        let intent: ServiceIntentProtocol
        var state: ServiceModelStateProtocol
        
        var body: some View {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: AppTheme.layout.spacing) {
                        // 便捷服务
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(LocalizedStringKey("convenient_service"))
                                    .font(AppTheme.fonts.title1)
                                    .bold()
                                    .foregroundColor(AppTheme.colors.fontPrimary)
                                Spacer()
                            }
                            
                            HStack(spacing: 0) {
                                ServiceIconItem(icon: "car.fill", nameKey: "pick_up_and_drop_off")
                                ServiceIconItem(icon: "antenna.radiowaves.left.and.right", nameKey: "data_service")
                                ServiceIconItem(icon: "lifepreserver.fill", nameKey: "roadside_assistance")
                                ServiceIconItem(icon: "square.and.pencil", nameKey: "edit", isAction: true)
                            }
                        }
                        .appCardStyle()
                        
                        // 能源服务
                        VStack(alignment: .leading, spacing: 16) {
                            SectionTitle(titleKey: "energy_service")
                            
                            VStack(spacing: 0) {
                                // 地图组件区域
                                ZStack {
                                    Rectangle()
                                        .fill(Color.white.opacity(0.05))
                                        .frame(height: 140)
                                    
                                    Image(systemName: "map.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(AppTheme.colors.brandMain.opacity(0.2))
                                    
                                    // 模拟车辆位置
                                    VStack {
                                        Image(systemName: "location.north.fill")
                                            .foregroundColor(AppTheme.colors.brandMain)
                                            .font(.system(size: 20))
                                            .shadow(color: AppTheme.colors.brandMain, radius: 5)
                                    }
                                }
                                .cornerRadius(AppTheme.layout.radiusMedium, corners: [.topLeft, .topRight])
                                
                                // 最近站点信息
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("特来电上海静安中心站")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(AppTheme.colors.fontPrimary)
                                            Text("上海市静安区南京西路1266号B3层")
                                                .font(.system(size: 12))
                                                .foregroundColor(AppTheme.colors.fontSecondary)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text("1.2 km")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(AppTheme.colors.brandMain)
                                            Text("离车距离")
                                                .font(.system(size: 10))
                                                .foregroundColor(AppTheme.colors.fontTertiary)
                                        }
                                    }
                                    
                                    Divider().background(Color.white.opacity(0.05))
                                    
                                    HStack {
                                        // 充电枪状态
                                        HStack(spacing: 8) {
                                            StatusTag(label: "闲 8", color: .green)
                                            StatusTag(label: "忙 4", color: .orange)
                                        }
                                        
                                        Spacer()
                                        
                                        // 价格信息
                                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                                            Text("￥")
                                                .font(.system(size: 10))
                                            Text("1.25")
                                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                            Text("/度")
                                                .font(.system(size: 10))
                                        }
                                        .foregroundColor(AppTheme.colors.fontPrimary)
                                    }
                                }
                                .padding(16)
                                .background(Color.white.opacity(0.02))
                                .cornerRadius(AppTheme.layout.radiusMedium, corners: [.bottomLeft, .bottomRight])
                            }
                            
                            // 附近站点汇总
                            HStack {
                                Image(systemName: "bolt.car.fill")
                                    .foregroundColor(AppTheme.colors.brandMain)
                                Text("发现附近共有 24 个充电站")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.colors.fontSecondary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.colors.fontTertiary)
                            }
                            .padding(.horizontal, 4)
                        }
                        .appCardStyle()
                        
                        // 售后服务
                        VStack(alignment: .leading, spacing: 16) {
                            SectionTitle(titleKey: "after_sales_service")
                            
                            // 售后中心概览图
                            ZStack(alignment: .bottomLeading) {
                                KFImage(URL(string: "https://i.ibb.co/7tHhCRMf/image-cc-640.png")!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 140)
                                    .cornerRadius(AppTheme.layout.radiusMedium, corners: [.topLeft, .topRight])
                                    .clipped()
                                
                                LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.6)]), startPoint: .top, endPoint: .bottom)
                                    .cornerRadius(AppTheme.layout.radiusMedium, corners: [.topLeft, .topRight])
                                
                                HStack {
                                    Image(systemName: "house.fill")
                                        .foregroundColor(AppTheme.colors.brandMain)
                                    Text("全国共有 128 家售后服务中心")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                .padding(16)
                            }
                            
                            // 最近服务网点
                            VStack(alignment: .leading, spacing: 12) {
                                Text("最近服务网点")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.colors.fontTertiary)
                                    .padding(.bottom, 4)
                                
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("开源汽车上海虹桥维修中心")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(AppTheme.colors.fontPrimary)
                                        Text("上海市闵行区申昆路1500号")
                                            .font(.system(size: 13))
                                            .foregroundColor(AppTheme.colors.fontSecondary)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("3.5 km")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(AppTheme.colors.brandMain)
                                        Text("离车距离")
                                            .font(.system(size: 10))
                                            .foregroundColor(AppTheme.colors.fontTertiary)
                                    }
                                }
                                
                                Button(action: { /* 预约逻辑 */ }) {
                                    HStack {
                                        Spacer()
                                        Text("立即预约")
                                            .font(.system(size: 14, weight: .bold))
                                        Spacer()
                                    }
                                    .padding(.vertical, 10)
                                    .background(AppTheme.colors.brandMain.opacity(0.1))
                                    .foregroundColor(AppTheme.colors.brandMain)
                                    .cornerRadius(AppTheme.layout.radiusSmall)
                                }
                                .padding(.top, 8)
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.02))
                            .cornerRadius(AppTheme.layout.radiusMedium, corners: [.bottomLeft, .bottomRight])
                        }
                        .appCardStyle()
                        
                        // 用车服务
                        VStack(alignment: .leading, spacing: 16) {
                            SectionTitle(titleKey: "vehicle_service")
                            
                            let columns = [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ]
                            
                            LazyVGrid(columns: columns, spacing: 20) {
                                ServiceIconItem(icon: "calendar.badge.plus", nameKey: "service_booking")
                                ServiceIconItem(icon: "lifepreserver", nameKey: "roadside_assistance")
                                ServiceIconItem(icon: "car.side.front.open.fill", nameKey: "pick_up_service")
                                ServiceIconItem(icon: "exclamationmark.shield", nameKey: "vehicle_damage_report")
                                ServiceIconItem(icon: "doc.text.below.ecg", nameKey: "maintenance_report")
                            }
                            .padding(.top, 8)
                        }
                        .appCardStyle()
                        
                        // 用车工具
                        VStack(alignment: .leading, spacing: 16) {
                            SectionTitle(titleKey: "vehicle_tools")
                            
                            let columns = [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ]
                            
                            LazyVGrid(columns: columns, spacing: 20) {
                                ServiceIconItem(icon: "book.closed.fill", nameKey: "user_manual")
                                ServiceIconItem(icon: "shield.righthalf.filled", nameKey: "warranty_policy")
                                ServiceIconItem(icon: "lightbulb.fill", nameKey: "indicator_lights_explanation")
                                ServiceIconItem(icon: "info.circle.fill", nameKey: "about_vehicle")
                            }
                            .padding(.top, 8)
                        }
                        .appCardStyle()
                        
                        Spacer().frame(height: 100)
                    }
                    .padding(.horizontal, AppTheme.layout.margin)
                    .padding(.top, 20)
                }
                .scrollIndicators(.hidden)
            }
            .background(AppTheme.colors.background)
        }
    }
}

// MARK: - 辅助组件
private struct SectionTitle: View {
    var titleKey: String
    var body: some View {
        Text(LocalizedStringKey(titleKey))
            .font(AppTheme.fonts.title1)
            .bold()
            .foregroundColor(AppTheme.colors.fontPrimary)
    }
}

private struct ServiceIconItem: View {
    var icon: String
    var nameKey: String
    var useSystemIcon: Bool = true
    var isAction: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 48, height: 48)
                
                if useSystemIcon {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(isAction ? AppTheme.colors.brandMain : AppTheme.colors.fontPrimary)
                } else {
                    Image(icon)
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
            
            Text(LocalizedStringKey(nameKey))
                .font(.system(size: 12))
                .foregroundColor(AppTheme.colors.fontSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ImageCard: View {
    var url: String
    var title: String
    var textColor: Color = .white
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            KFImage(URL(string: url)!)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .cornerRadius(AppTheme.layout.radiusSmall)
                .clipped()
            
            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.4)]), startPoint: .top, endPoint: .bottom)
                .cornerRadius(AppTheme.layout.radiusSmall)
            
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(textColor)
                .padding(10)
        }
    }
}

private struct AfterSalesItem: View {
    var icon: String
    var title: String
    var subTitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.colors.brandMain.opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.colors.brandMain)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.colors.fontPrimary)
                Text(subTitle)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.colors.fontSecondary)
            }
            Spacer()
        }
    }
}

private struct StatusTag: View {
    var label: String
    var color: Color
    var body: some View {
        Text(label)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .cornerRadius(4)
    }
}

struct ServiceView_Previews: PreviewProvider {
    static var previews: some View {
        let container = ServicePage.buildContainer()
        ServicePage.Content(intent: container.intent, state: container.model)
            .environmentObject(AppGlobalState.shared)
    }
}
