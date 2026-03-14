//
//  ServiceContainer.swift
//  iov
//
//  Created by Gemini on 2026/3/14.
//

import Foundation

/// 依赖注入容器，用于管理全局的服务实例
struct ServiceContainer {
    
    /// 获取车辆相关的业务服务
    static var vehicleService: VehicleServiceProtocol {
        if AppGlobalState.shared.isMock {
            return MockVehicleService()
        }
        return RealVehicleService()
    }
    
    /// 获取登录相关的业务服务
    static var loginService: LoginServiceProtocol {
        if AppGlobalState.shared.isMock {
            return MockLoginService()
        }
        return RealLoginService()
    }
    
    /// 获取购车营销相关的业务服务
    static var marketingService: MarketingServiceProtocol {
        if AppGlobalState.shared.isMock {
            return MockMarketingService()
        }
        return RealMarketingService()
    }
}
