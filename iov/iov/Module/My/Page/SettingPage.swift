//
//  SettingView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import CoreLocation
import Photos
import AVFoundation
import CoreBluetooth
import CoreTelephony

struct SettingPage: View {
    
    @EnvironmentObject var appGlobalState: AppGlobalState
    @StateObject var container: MviContainer<SettingIntentProtocol, SettingModelStateProtocol>
    private var intent: SettingIntentProtocol { container.intent }
    private var state: SettingModelStateProtocol { container.model }
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    
    var body: some View {
        ZStack {
            SettingPage.Content(
                tapProfile: { intent.onTapProfile() },
                tapPermissionManagement: { intent.onTapPermissionManagement() },
                loginAction: { intent.onTapLogin() },
                logoutAction: { intent.onTapLogout() }, 
                appVersion: appVersion,
                isMock: $appGlobalState.isMock,
                apiUrl: $appGlobalState.tspUrl
            )
        }
        .appBackground()
        .modifier(MyRouter(subjects: state.routerSubject))
    }
    
}

extension SettingPage {
    
    struct Content: View {
        
        var tapProfile: (()->Void)?
        var tapPermissionManagement: (()->Void)?
        var tapAccountChange: (()->Void)?
        var tapAccountSecurity: (()->Void)?
        var tapAccountBinding: (()->Void)?
        var tapPrivillegeAction: (()->Void)?
        var tapUserProtocolAction: (()->Void)?
        var tapCommunityConvention: (()->Void)?
        var tapPrivacyAgreement: (()->Void)?
        var loginAction: (()->Void)?
        var logoutAction: (()->Void)?
        var appVersion: String
        @State private var showAlert = false
        @State private var showMock = false
        @State private var mockCount: Int = 0
        @Binding var isMock: Bool
        @Binding var apiUrl: String
        
        var body: some View {
            VStack(spacing: 0) {
                Spacer().frame(height: kStatusBarHeight)
                TopBackTitleBar(titleLocal: LocalizedStringKey("setting"))
                ScrollView {
                    VStack(spacing: AppTheme.layout.spacing) {
                        VStack(spacing: 0) {
                            SettingPage.List(title: "个人资料") {
                                if UserManager.isLogin() {
                                    tapProfile?()
                                } else {
                                    loginAction?()
                                }
                            }
                            SettingPage.List(title: "权限管理") {
                                tapPermissionManagement?()
                            }
                            // 版本信息
                            Button(action: { 
                                mockCount = mockCount + 1
                                if(isMock && mockCount > 10) {
                                    showMock = true
                                    isMock.toggle()
                                }
                            }) {
                                HStack {
                                    Text(LocalizedStringKey("version"))
                                        .foregroundStyle(AppTheme.colors.fontPrimary)
                                        .font(AppTheme.fonts.body)
                                    Spacer()
                                    Text("\(appVersion)")
                                        .foregroundStyle(AppTheme.colors.fontSecondary)
                                        .font(AppTheme.fonts.body)
                                    if(isMock) {
                                        Text("(Mock)")
                                            .foregroundStyle(AppTheme.colors.fontSecondary)
                                            .font(AppTheme.fonts.body)
                                    }
                                }
                                .padding(.vertical, 20)
                            }
                            .buttonStyle(.plain)
                        }
                        .appCardStyle()
                        
                        if(showMock) {
                            TextField("", text: $apiUrl)
                                .frame(height: 35)
                                .textFieldStyle(.plain)
                                .foregroundColor(AppTheme.colors.fontPrimary)
                                .padding()
                                .background(AppTheme.colors.cardBackground)
                                .cornerRadius(AppTheme.layout.radiusMedium)
                        }
                        
                        if(UserManager.isLogin()) {
                            RoundedCornerButton(nameLocal: LocalizedStringKey("logout"), color: .black, bgColor: AppTheme.colors.brandMain) {
                                showAlert = true
                            }
                            .padding(.top, 20)
                        }
                    }
                    .padding(.horizontal, AppTheme.layout.margin)
                    .padding(.top, 20)
                }
                .scrollIndicators(.hidden)
                .alert(Text(LocalizedStringKey("tip")), isPresented: $showAlert) {
                    Button(LocalizedStringKey("cancel"), role: .cancel) { }
                    Button(LocalizedStringKey("confirm")) {
                        logoutAction?()
                    }
                } message: {
                    Text(LocalizedStringKey("logout_confirm"))
                }
            }
        }
    }
}

// MARK: - Permission Management

struct PermissionManagementView: View {
    @EnvironmentObject var appGlobalState: AppGlobalState
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    // 持有 CTCellularData 引用
    @State private var cellularData = CTCellularData()
    
    // 权限状态
    @State private var networkStatus = "permission_status_checking"
    @State private var locationStatus = "permission_status_checking"
    @State private var photoStatus = "permission_status_checking"
    @State private var cameraStatus = "permission_status_checking"
    @State private var bluetoothStatus = "permission_status_checking"
    
    // 轮询定时器，确保从设置回来后状态能及时刷新
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: kStatusBarHeight)
            TopBackTitleBar(titleLocal: LocalizedStringKey("permission_management"))
            ScrollView {
                VStack(spacing: AppTheme.layout.spacing) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(LocalizedStringKey("permission_description_title"))
                            .font(AppTheme.fonts.title1)
                            .foregroundColor(AppTheme.colors.fontPrimary)
                        Text(LocalizedStringKey("permission_description_content"))
                            .font(AppTheme.fonts.body)
                            .foregroundColor(AppTheme.colors.fontSecondary)
                            .lineSpacing(4)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, AppTheme.layout.margin)
                    
                    VStack(spacing: 0) {
                        PermissionItem(title: "network_permission", icon: "wifi", status: networkStatus) {
                            showPermissionAlert(type: "network")
                        }
                        PermissionItem(title: "location_permission", icon: "location.fill", status: locationStatus) {
                            showPermissionAlert(type: "location")
                        }
                        PermissionItem(title: "photo_permission", icon: "photo.on.rectangle", status: photoStatus) {
                            showPermissionAlert(type: "photo")
                        }
                        PermissionItem(title: "camera_permission", icon: "camera.fill", status: cameraStatus) {
                            showPermissionAlert(type: "camera")
                        }
                        PermissionItem(title: "bluetooth_permission", icon: "bolt.horizontal.circle.fill", status: bluetoothStatus) {
                            showPermissionAlert(type: "bluetooth")
                        }
                    }
                    .appCardStyle()
                    .padding(.horizontal, AppTheme.layout.margin)
                }
            }
        }
        .appBackground()
        .onAppear {
            appGlobalState.currentView = "PermissionManagement"
            checkAllPermissions()
        }
        .onReceive(timer) { _ in
            checkAllPermissions()
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button(LocalizedStringKey("cancel"), role: .cancel) { }
            Button(LocalizedStringKey("confirm")) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func checkAllPermissions() {
        // --- 网络权限 ---
        #if targetEnvironment(simulator)
        self.networkStatus = "permission_status_authorized"
        #else
        updateNetworkStatus(cellularData.restrictedState)
        #endif
        
        // --- 位置权限 ---
        let locStatus = CLLocationManager.authorizationStatus()
        switch locStatus {
        case .authorizedAlways, .authorizedWhenInUse: locationStatus = "permission_status_authorized"
        case .denied, .restricted: locationStatus = "permission_status_denied"
        default: locationStatus = "permission_status_not_determined"
        }
        
        // --- 照片权限 (综合判断) ---
        let pReadStatus: PHAuthorizationStatus
        let pAddStatus: PHAuthorizationStatus
        if #available(iOS 14.0, *) {
            pReadStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            pAddStatus = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        } else {
            pReadStatus = PHPhotoLibrary.authorizationStatus()
            pAddStatus = pReadStatus
        }
        
        // 在 iOS 17 “私密访问”下，pReadStatus 可能是 notDetermined，但 pAddStatus 可能是 authorized
        // 或者只要有 entry 存在，我们认为用户已经做出了某种形式的授权选择
        if pReadStatus == .authorized || pReadStatus == .limited || pAddStatus == .authorized || pAddStatus == .limited {
            photoStatus = "permission_status_authorized"
        } else if pReadStatus == .denied || pReadStatus == .restricted || pAddStatus == .denied || pAddStatus == .restricted {
            photoStatus = "permission_status_denied"
        } else {
            photoStatus = "permission_status_not_determined"
        }
        
        // --- 相机权限 ---
        let cStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cStatus {
        case .authorized: cameraStatus = "permission_status_authorized"
        case .denied, .restricted: cameraStatus = "permission_status_denied"
        default: cameraStatus = "permission_status_not_determined"
        }
        
        // --- 蓝牙权限 ---
        let bStatus = CBManager.authorization
        switch bStatus {
        case .allowedAlways: bluetoothStatus = "permission_status_authorized"
        case .denied, .restricted: bluetoothStatus = "permission_status_denied"
        default: bluetoothStatus = "permission_status_not_determined"
        }
    }
    
    private func updateNetworkStatus(_ state: CTCellularDataRestrictedState) {
        DispatchQueue.main.async {
            switch state {
            case .restricted: self.networkStatus = "permission_status_denied"
            case .notRestricted: self.networkStatus = "permission_status_authorized"
            case .restrictedStateUnknown:
                // 默认认为已授权，因为 unknown 通常出现在能够正常联网但系统尚未分类时
                self.networkStatus = "permission_status_authorized"
            @unknown default:
                self.networkStatus = "permission_status_not_determined"
            }
        }
    }
    
    private func showPermissionAlert(type: String) {
        alertTitle = NSLocalizedString("permission_alert_title", comment: "")
        let permissionName = NSLocalizedString("\(type)_permission", comment: "")
        let template = NSLocalizedString("permission_alert_message", comment: "")
        alertMessage = String(format: template, permissionName)
        showAlert = true
    }
}

extension PermissionManagementView {
    static func build() -> some View {
        PermissionManagementView()
    }
}

struct PermissionItem: View {
    var title: String
    var icon: String
    var status: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(AppTheme.colors.brandMain)
                        .frame(width: 30)
                    Text(LocalizedStringKey(title))
                        .font(AppTheme.fonts.body)
                        .foregroundColor(AppTheme.colors.fontPrimary)
                    Spacer()
                    Text(LocalizedStringKey(status))
                        .font(AppTheme.fonts.subtext)
                        .foregroundColor(AppTheme.colors.fontSecondary)
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppTheme.colors.fontSecondary)
                        .font(AppTheme.fonts.body)
                }
                .padding(.vertical, 20)
                if title != "bluetooth_permission" {
                    Divider()
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct MySettingView_Previews: PreviewProvider {
    
    static var previews: some View {
        @StateObject var appGlobalState = AppGlobalState.shared
        @State var isMock = true
        @State var apiUrl = ""
        SettingPage.Content(appVersion: "0.0.1", isMock: $isMock, apiUrl: $apiUrl)
            .environment(\.locale, .init(identifier: "zh-Hans"))
            .environmentObject(appGlobalState)
    }
}
