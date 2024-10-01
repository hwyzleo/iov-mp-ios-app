//
//  MySettingPrivillegeView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import AVFoundation
import CoreLocation
import Photos
import CoreTelephony
import Network
import Alamofire
import CoreBluetooth

struct MySettingPrivillegeView: View {
    @StateObject var container: MviContainer<MySettingPrivillegeIntentProtocol, MySettingPrivillegeModelStateProtocol>
    private var intent: MySettingPrivillegeIntentProtocol { container.intent }
    private var state: MySettingPrivillegeModelStateProtocol { container.model }
    
    var body: some View {
        ZStack {
            switch state.contentState {
            case .loading:
                LoadingTip()
            case .content:
                Content(intent: intent, state: state)
            case let .error(text):
                ErrorTip(text: text)
            }
        }
        .onAppear(perform: intent.viewOnAppear)
        .modifier(MySettingPrivillegeRouter(
            subjects: state.routerSubject,
            intent: intent
        ))
    }
}

// MARK: - Views

private extension MySettingPrivillegeView {
    
    private struct Content: View {
        @Environment(\.scenePhase) var scenePhase
        @State private var refreshID = UUID()
        let intent: MySettingPrivillegeIntentProtocol
        let state: MySettingPrivillegeModelStateProtocol
        @State var showNetwork = false
        @State var networkState = "获取中"
        @State var showLocation = false
        @State var showPhoto = false
        @State var showVideo = false
        @State var showNotification = false
        @State var showBluetooth = false
        let manager: BluetoothManager = BluetoothManager()
        
        var body: some View {
            VStack {
                TopBackTitleBar(title: "权限管理")
                Spacer()
                    .frame(height: 20)
                VStack {
                    Text("为了更好的使用体验，在特定场景会向您申请以下手机系统权限。")
                        .foregroundColor(.black)
                        .font(.system(size: 12))
                        .padding(10)
                }
                .background(Color(hex: 0xf2eded))
                VStack {
                    List(title: "网络", value: networkState) {
                        showNetwork = true
                    }
                    List(title: "位置", value: getLocationPrivillege()) {
                        showLocation = true
                    }
                    List(title: "相册", value: getPhotoPrivillege()) {
                        if(getPhotoPrivillege() == "未授权") {
                            requestPhotoPrivillege()
                            refreshID == UUID()
                        }
                        showPhoto = true
                    }
                    List(title: "相机", value: getVideoPrivillege()) {
                        if(getVideoPrivillege() == "未授权") {
                            requestVideoPrivillege()
                            refreshID == UUID()
                        }
                        showVideo = true
                    }
                    List(title: "通知", value: getNotificationPrivillege()) {
                        showNotification = true
                    }
                    List(title: "蓝牙", value: getBluetoothPrivillege()) {
                        if(getBluetoothPrivillege() == "未授权") {
                            BluetoothManager.shared.scan()
                            refreshID == UUID()
                        }
                        showBluetooth = true
                    }
                }
                .padding(20)
                Spacer()
            }
            .sheet(isPresented: $showNetwork) {
                NetworkSheet(showNetwork: $showNetwork, networkState: networkState)
                    .padding(20)
                    .presentationDetents([.height(200)])
            }
            .sheet(isPresented: $showLocation) {
                LocationSheet(showLocation: $showLocation)
                    .padding(20)
                    .presentationDetents([.height(200)])
            }
            .sheet(isPresented: $showPhoto) {
                PhotoSheet(showPhoto: $showPhoto)
                    .padding(20)
                    .presentationDetents([.height(200)])
            }
            .sheet(isPresented: $showVideo) {
                VideoSheet(showVideo: $showVideo)
                    .padding(20)
                    .presentationDetents([.height(200)])
            }
            .sheet(isPresented: $showNotification) {
                NotificationSheet(showNotification: $showNotification)
                    .padding(20)
                    .presentationDetents([.height(200)])
            }
            .sheet(isPresented: $showBluetooth) {
                BluetoothSheet(showBluetooth: $showBluetooth)
                    .padding(20)
                    .presentationDetents([.height(200)])
            }
            .id(refreshID)
            .onChange(of: scenePhase) { newScenePhase in
                if newScenePhase == .active {
                    refreshID == UUID()
                    getNetworkPrivillege() { result in
                        networkState = result
                    }
                }
            }
            .onAppear() {
                getNetworkPrivillege() { result in
                    networkState = result
                }
            }
        }
    }
    
    struct List: View {
        var title: String
        var value: String
        var action: (()->Void)?
        
        var body: some View {
            Button(action: { action?() }) {
                VStack {
                    HStack {
                        Text(title)
                            .font(.system(size: 18))
                            .foregroundColor(.black)
                        Spacer()
                        Text(value)
                            .font(.system(size: 18))
                            .foregroundColor(.black)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18))
                            .foregroundColor(.black)
                    }
                    .padding(.top, 25)
                    Divider()
                        .padding(.top, 25)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
    
    struct NetworkSheet: View {
        @Binding var showNetwork: Bool
        @State var networkState: String
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text("网络权限")
                        .bold()
                    Spacer()
                    Button(action: {showNetwork = false}) {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
                    .frame(height: 20)
                HStack {
                    Text(networkState)
                    Spacer()
                }
                Divider()
                HStack {
                    Text("网络权限用于与服务器进行连接，发起网络请求。")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                    .frame(height: 20)
                Button(action:{
                    showNetwork = false
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }) {
                    Text("去系统设置")
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(.black)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
            }
        }
    }
    
    struct LocationSheet: View {
        @Binding var showLocation: Bool
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text("位置权限")
                        .bold()
                    Spacer()
                    Button(action: {showLocation = false}) {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
                    .frame(height: 20)
                HStack {
                    Text(getLocationPrivillege())
                    Spacer()
                }
                Divider()
                HStack {
                    Text("位置权限用于帮助您订购上牌城市时自动选择您的位置。")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                    .frame(height: 20)
                Button(action:{
                    showLocation = false
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }) {
                    Text("去系统设置")
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(.black)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
            }
        }
    }
    
    struct PhotoSheet: View {
        @Binding var showPhoto: Bool
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text("相册权限")
                        .bold()
                    Spacer()
                    Button(action: {showPhoto = false}) {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
                    .frame(height: 20)
                HStack {
                    Text(getPhotoPrivillege())
                    Spacer()
                }
                Divider()
                HStack {
                    Text("相册权限用于修改头像需要上传照片的功能。")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                    .frame(height: 20)
                Button(action:{
                    showPhoto = false
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }) {
                    Text("去系统设置")
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(.black)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
            }
        }
    }
    
    struct VideoSheet: View {
        @Binding var showVideo: Bool
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text("相机权限")
                        .bold()
                    Spacer()
                    Button(action: {showVideo = false}) {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
                    .frame(height: 20)
                HStack {
                    Text(getVideoPrivillege())
                    Spacer()
                }
                Divider()
                HStack {
                    Text("相机权限用于修改头像时实现拍照上传照片的功能。")
                        .lineLimit(2)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                }
                Spacer()
                    .frame(height: 20)
                Button(action:{
                    showVideo = false
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }) {
                    Text("去系统设置")
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(.black)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
            }
        }
    }
    
    struct NotificationSheet: View {
        @Binding var showNotification: Bool
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text("通知权限")
                        .bold()
                    Spacer()
                    Button(action: {showNotification = false}) {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
                    .frame(height: 20)
                HStack {
                    Text(getNotificationPrivillege())
                    Spacer()
                }
                Divider()
                HStack {
                    Text("通知权限用于推送您的订单状态信息的功能。")
                        .lineLimit(2)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                }
                Spacer()
                    .frame(height: 20)
                Button(action:{
                    showNotification = false
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }) {
                    Text("去系统设置")
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(.black)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
            }
        }
    }
    
    struct BluetoothSheet: View {
        @Binding var showBluetooth: Bool
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text("蓝牙权限")
                        .bold()
                    Spacer()
                    Button(action: {showBluetooth = false}) {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
                    .frame(height: 20)
                HStack {
                    Text(getBluetoothPrivillege())
                    Spacer()
                }
                Divider()
                HStack {
                    Text("蓝牙权限用于为您进行蓝牙车控的功能。")
                        .lineLimit(2)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                }
                Spacer()
                    .frame(height: 20)
                Button(action:{
                    showBluetooth = false
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }) {
                    Text("去系统设置")
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(.black)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
            }
        }
    }
    
}

/// 获取网络权限
func getNetworkPrivillege(completion: @escaping (String) -> Void) {
    AF.request("https://www.baidu.com").response { response in
        switch response.result {
        case .success:
            completion("已授权")
        default:
            completion("未授权")
        }
    }
}

/// 获取定位权限
func getLocationPrivillege() -> String {
    let manager = CLLocationManager()
    switch manager.authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
        return "已授权"
    default:
        return "未授权"
    }
}

/// 获取相册权限
func getPhotoPrivillege() -> String {
    switch PHPhotoLibrary.authorizationStatus() {
    case .authorized:
        return "已授权"
    default:
        return "未授权"
    }
}

/// 获取相机权限
func getVideoPrivillege() -> String {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
        return "已授权"
    default:
        return "未授权"
    }
}

/// 获取通知权限
func getNotificationPrivillege() -> String {
    var priv = ""
    let semaphore = DispatchSemaphore(value: 0)
    if #available(iOS 10, *) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized:
                priv = "已授权"
            default:
                priv = "未授权"
            }
            semaphore.signal()
        }
    } else {
        let isRegistered = UIApplication.shared.isRegisteredForRemoteNotifications
        priv = "\(isRegistered)"
        semaphore.signal()
    }
    semaphore.wait()
    return priv
}

/// 获取蓝牙权限
func getBluetoothPrivillege() -> String {
    if BluetoothManager.shared.getPrivillege() {
        return "已授权"
    } else {
        return "未授权"
    }
}

/// 请求相机权限
func requestVideoPrivillege() {
    let videoStatus = AVCaptureDevice.authorizationStatus(for: .video)
    if videoStatus == .notDetermined{
        AVCaptureDevice.requestAccess(for: .video) {_ in

        }
        return
    }
}

/// 请求相册权限
func requestPhotoPrivillege() {
    if #available(iOS 14, *) {
        let readWriteStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        print(readWriteStatus)
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { (status) in
            
        }
    } else {
        let readWriteStatus = PHPhotoLibrary.authorizationStatus()
        print(readWriteStatus)
        PHPhotoLibrary.requestAuthorization { (status) in
            
        }
    }
}

struct MySettingPrivillegeView_Previews: PreviewProvider {
    static var previews: some View {
        MySettingPrivillegeView(container: MySettingPrivillegeView.buildContainer())
    }
}
