//
//  AppDelegate.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/22.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if((UIDevice.current.systemVersion as NSString).floatValue >= 8.0) {
          // 可以自定义 categories
            JPUSHService.register(forRemoteNotificationTypes: UIUserNotificationType.badge.rawValue | UIUserNotificationType.badge.rawValue | UIUserNotificationType.alert.rawValue , categories: nil)
        } else {
            JPUSHService.register(forRemoteNotificationTypes: UIUserNotificationType.badge.rawValue | UIUserNotificationType.badge.rawValue | UIUserNotificationType.alert.rawValue , categories: nil)
        }
        JPUSHService.setup(withOption: launchOptions, appKey: "13e96ce8c7949a5d7d51d497", channel: "App Store", apsForProduction: true)
        print("Application did finish launching")
        return true
    }
    
    private func application(application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("get the deviceToken  \(deviceToken)")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DidRegisterRemoteNotification") , object: deviceToken)
        JPUSHService.registerDeviceToken(deviceToken as Data)
    }
    
}
