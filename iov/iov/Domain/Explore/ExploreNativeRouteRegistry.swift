//
//  ExploreNativeRouteRegistry.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-012 on 2026/11/26.
//

import Foundation

/// 客户端已实现的既有原生页面命令。
/// 新增 NATIVE 映射时必须同时登记到 `ExploreNativeRouteRegistry` 并补充测试。
enum ExploreNativeDestination: Equatable {
    case orderDetail(orderNo: String)
}

enum ExploreTargetResolutionError: Error, Equatable {
    case unavailable
    case insecureURL
    case unsupportedNativeRoute
    case invalidNativeParameters
}

struct ExploreNativeRouteRegistration {
    let routeCode: String
    let allowedParamKeys: Set<String>
    let makeDestination: ([String: String]) -> ExploreNativeDestination?

    init(routeCode: String,
         allowedParamKeys: Set<String>,
         makeDestination: @escaping ([String: String]) -> ExploreNativeDestination?) {
        self.routeCode = routeCode
        self.allowedParamKeys = Set(allowedParamKeys.map { $0.lowercased() })
        self.makeDestination = makeDestination
    }
}

/// CMS 的 NATIVE 目标只提供 `routeCode + params`；客户端必须显式登记，
/// 未登记的 routeCode / 未允许的参数键一律拒绝（设计 §4.3、§8）。
struct ExploreNativeRouteRegistry {

    /// 生产注册表：当前 CMS 未确认任何 routeCode，默认拒绝全部 NATIVE 目标。
    static let production = ExploreNativeRouteRegistry(registrations: [])

    private let registrations: [String: ExploreNativeRouteRegistration]

    init(registrations: [ExploreNativeRouteRegistration]) {
        var map: [String: ExploreNativeRouteRegistration] = [:]
        for registration in registrations {
            let code = registration.routeCode.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !code.isEmpty else { continue }
            map[code] = registration
        }
        self.registrations = map
    }

    var isEmpty: Bool { registrations.isEmpty }

    func resolve(routeCode: String, params: [String: String]) -> Result<ExploreNativeDestination, ExploreTargetResolutionError> {
        let code = routeCode.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !code.isEmpty, let registration = registrations[code] else {
            return .failure(.unsupportedNativeRoute)
        }
        for key in params.keys {
            guard registration.allowedParamKeys.contains(key.lowercased()) else {
                return .failure(.invalidNativeParameters)
            }
        }
        guard let destination = registration.makeDestination(params) else {
            return .failure(.invalidNativeParameters)
        }
        return .success(destination)
    }
}
