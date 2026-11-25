//
//  ActivationBindingBean.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-010 on 2026/11/21.
//

import Foundation

/// 扫码认领会话响应
/// - 对应 IOV-TSP-DSN-CR-017 `POST /api/mobile/activation/v1/session/scan`
/// - 只包含最小待确认车辆信息；服务端字段为 camelCase，时间为 ISO-8601
struct ActivationScanResult: Codable {
    var sessionId: String
    var vin: String?
    var state: String?
    @FlexibleTimestamp var expiresAt: Int64?
    var claimed: Bool?
}

/// 确认绑定响应
/// - 对应 `POST /api/mobile/activation/v1/binding/confirm`
/// - `status` 为 PENDING / SUCCEEDED / FAILED；`reason` 为稳定的语义标识
struct ActivationConfirmResult: Codable {
    var operationId: String?
    var status: String?
    var reason: String?
    var relationId: String?
    var vin: String?
    @FlexibleTimestamp var completedAt: Int64?
}

/// 绑定操作结果查询响应
/// - 对应 `GET /api/mobile/activation/v1/binding/operations/{operationId}`
struct ActivationOperationResult: Codable {
    var operationId: String
    var status: String?
    var reason: String?
    var relationId: String?
    var vin: String?
    var sessionId: String?
    @FlexibleTimestamp var completedAt: Int64?
}

/// 当前账号在指定 VIN 上的人车关系查询响应
/// - 对应 IOV-TSP-DSN-CR-018 `GET /api/mobile/activation/v1/binding?vin=...`
/// - `status` 只有 BOUND / NOT_BOUND；NOT_BOUND 仅表示当前账号在该 VIN 上没有有效关系
struct UserVehicleRelationResult: Codable {
    var status: String?
    var vin: String?
    var relationId: String?
    var role: String?
    @FlexibleTimestamp var boundAt: Int64?
}
