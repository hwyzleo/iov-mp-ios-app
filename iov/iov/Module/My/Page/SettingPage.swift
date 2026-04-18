//
//  SettingView.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
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
                tapLanguageSetting: { intent.onTapLanguageSetting() },
                tapAboutUs: { intent.onTapAboutUs() },
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
        var tapLanguageSetting: (()->Void)?
        var tapAboutUs: (()->Void)?
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
        @State private var showClearCacheAlert = false
        @State private var cacheSizeDisplay = "0 MB"
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
                            SettingPage.List(titleLocal: LocalizedStringKey("profile")) {
                                if UserManager.isLogin() {
                                    tapProfile?()
                                } else {
                                    loginAction?()
                                }
                            }
                            SettingPage.List(titleLocal: LocalizedStringKey("multi_language")) {
                                tapLanguageSetting?()
                            }
                            SettingPage.List(titleLocal: LocalizedStringKey("permission_management")) {
                                tapPermissionManagement?()
                            }
                            
                            // 清除缓存
                            Button(action: { 
                                showClearCacheAlert = true
                            }) {
                                VStack {
                                    HStack {
                                        Text(LocalizedStringKey("clear_cache"))
                                            .foregroundStyle(AppTheme.colors.fontPrimary)
                                            .font(AppTheme.fonts.body)
                                        Spacer()
                                        Text(cacheSizeDisplay)
                                            .foregroundStyle(AppTheme.colors.fontSecondary)
                                            .font(AppTheme.fonts.body)
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(AppTheme.colors.fontSecondary)
                                            .font(AppTheme.fonts.body)
                                    }
                                    .padding(.top, 20)
                                    Divider()
                                        .padding(.top, 15)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            
                            // 关于我们
                            Button(action: { 
                                tapAboutUs?()
                            }) {
                                HStack {
                                    Text(LocalizedStringKey("about_us"))
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
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(AppTheme.colors.fontSecondary)
                                        .font(AppTheme.fonts.body)
                                }
                                .padding(.vertical, 20)
                                .contentShape(Rectangle())
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
                .alert(Text(LocalizedStringKey("tip")), isPresented: $showClearCacheAlert) {
                    Button(LocalizedStringKey("cancel"), role: .cancel) { }
                    Button(LocalizedStringKey("confirm")) {
                        CacheManager.clearCache {
                            refreshCacheSize()
                        }
                    }
                } message: {
                    Text(LocalizedStringKey("clear_cache_confirm"))
                }
                .onAppear {
                    refreshCacheSize()
                    // 重置 mock 计数
                    mockCount = 0
                }
            }
        }
        
        private func refreshCacheSize() {
            CacheManager.getCacheSize { size in
                cacheSizeDisplay = CacheManager.formatCacheSize(size)
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

// MARK: - About Us

struct AboutUsView: View {
    @EnvironmentObject var appGlobalState: AppGlobalState
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: kStatusBarHeight)
            TopBackTitleBar(titleLocal: LocalizedStringKey("about_us"))
            ScrollView {
                VStack(spacing: 40) {
                    // Logo & App Name
                    VStack(spacing: 15) {
                        Image("icon_app_320")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .cornerRadius(16)

                        VStack(spacing: 5) {
                            Text("Open IOV")
                                .font(AppTheme.fonts.title1)
                                .foregroundColor(AppTheme.colors.fontPrimary)
                            Text("Version \(appVersion)")
                                .font(AppTheme.fonts.subtext)
                                .foregroundColor(AppTheme.colors.fontSecondary)
                        }
                    }
                    .padding(.top, 40)
                    
                    // Info List
                    VStack(spacing: 0) {
                        AboutUsItem(title: "official_website", content: "www.open-iov.com")
                        AboutUsItem(title: "email", content: "support@open-iov.com")
                        AboutUsItem(title: "customer_service_phone", content: "400-123-4567")
                        AboutUsItem(title: "app_filing_number", content: "京ICP备2024000001号-1", isLast: true)
                    }
                    .appCardStyle()
                    .padding(.horizontal, AppTheme.layout.margin)
                }
            }
        }
        .appBackground()
        .onAppear {
            appGlobalState.currentView = "AboutUs"
        }
    }
}

struct AboutUsItem: View {
    var title: String
    var content: String
    var isLast: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(LocalizedStringKey(title))
                    .font(AppTheme.fonts.body)
                    .foregroundColor(AppTheme.colors.fontPrimary)
                Spacer()
                Text(content)
                    .font(AppTheme.fonts.body)
                    .foregroundColor(AppTheme.colors.fontSecondary)
            }
            .padding(.vertical, 20)
            if !isLast {
                Divider()
            }
        }
    }
}

extension AboutUsView {
    static func build() -> some View {
        AboutUsView()
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
