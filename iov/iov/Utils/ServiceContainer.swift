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
    
    /// 获取车辆绑定（关系 / 扫码 / 确认 / 操作恢复）服务。
    /// 不使用 mock 伪造绑定结果，始终走真实链路。
    static var vehicleBindingService: VehicleBindingServiceProtocol {
        return RealVehicleBindingService()
    }

    /// 获取登录相关的业务服务
    static var loginService: LoginServiceProtocol {
        return RealLoginService()
    }
    
    /// 获取购车营销相关的业务服务
    static var marketingService: MarketingServiceProtocol {
        return RealMarketingService()
    }
}
