//
//  IovApp.swift
//  IOV
//
//  Created by 叶荣杰 on 2024/8/31.
//

import SwiftUI
import SwiftData

@main
struct IovApp: App {
    @StateObject var appGlobalState = AppGlobalState.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appGlobalState)
                .onAppear() {
                    requestNotificationPrivillege()
                    BluetoothManager.shared.scan()
                }
        }
    }
}

/// 请求通知权限
func requestNotificationPrivillege() {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted {
            print("通知权限已获得")
        } else {
            print("通知权限未获得")
        }
    }
}
