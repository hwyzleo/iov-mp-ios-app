//
//  VehicleModelProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

// MARK: - View State

protocol VehicleModelStateProtocol {
    var contentState: VehicleTypes.Model.ContentState { get }
    var routerSubject: VehicleRouter.Subjects { get }
    var vehicle: Vehicle? { get }
    var lockLoading: Bool { get }
    var lockDuration: Double { get }
    var windowLoading: Bool { get }
    var windowDuration: Double { get }
    var trunkLoading: Bool { get }
    var trunkDuration: Double { get }
    var findLoading: Bool { get }
    var findDuration: Double { get }
    var cmdMapping: [String: String] { get }
    /// 当前账号与选中车辆的关系状态
    var relationshipState: VehicleRelationshipState { get }
    /// 车机登录状态（当前无查询接口，保持 unknown）
    var loginState: VehicleLoginState { get }
    /// 绑定操作状态（与持久关系分离）
    var bindingOperationState: VehicleBindingOperationState { get }
    /// 扫码后待确认的会话（nil 表示无待确认信息）
    var bindingSession: VehicleBindingSession? { get }
    /// 最近一次绑定失败（用于可读提示）
    var lastBindingFailure: VehicleBindingFailure? { get }
    /// 扫码/会话失败（不进入待确认弹层，直接提示）
    var scanFailure: VehicleBindingFailure? { get }
    /// 扫码失败的用户动作分类（重试 / 重新扫码 / 需人工 / 去登录）
    var scanFailureAction: ScanFailureAction? { get }
    /// 结果未知轮询已耗尽（保持结果未知，保留手动刷新）
    var pollingExhausted: Bool { get }
    /// 会话不可提交的原因（nil = 可提交）；仅 SCANNED + 未占用 + 未过期可提交
    var sessionBlockReason: VehicleBindingSessionBlockReason? { get }
    /// 登录门禁提示（未登录扫码 / 登录取消后重新扫码）
    var loginHint: VehicleBindingLoginHint? { get }
    /// 由关系 + 登录派生的页面展示态
    var displayState: VehiclePageDisplayState { get }
    /// 脱敏后的当前车辆 VIN
    var maskedVin: String? { get }
}

// MARK: - Intent Action

protocol VehicleModelActionProtocol: MviModelActionProtocol {
    /// 映射指令ID
    func mappingCmdId(cmdId: String, button: String)
    /// 获取指令ID映射
    func getCmdIdMapping(cmdId: String) -> String?
    /// 按钮加载中
    func buttonLoading(button: String)
    /// 按钮执行中
    func buttonExecuting(button: String)
    /// 更新车辆信息
    func updateVehicle(vehicle: Vehicle, button: String)
    /// 更新内容
    func updateContent(vehicleIndex: VehicleIndex)
    /// 显示信息并恢复按钮
    func displayInfo(text: String, button: String)
    /// 显示错误并恢复按钮
    func displayError(text: String, button: String)
    /// 设置当前页面上下文（账号 + 车辆 + VIN）
    func setContext(_ context: VehiclePageContext)
    /// 更新关系状态（仅当前上下文生效）
    func updateRelationship(_ state: VehicleRelationshipState, context: VehiclePageContext)
    /// 更新扫码会话（仅当前上下文生效）
    func updateBindingSession(_ session: VehicleBindingSession?, context: VehiclePageContext)
    /// 更新绑定操作状态（仅当前上下文生效）
    func updateBindingOperation(_ state: VehicleBindingOperationState,
                               failure: VehicleBindingFailure?,
                               context: VehiclePageContext)
    /// 更新扫码失败提示（仅当前上下文生效）
    func updateScanFailure(_ failure: VehicleBindingFailure?, context: VehiclePageContext)
    /// 清除扫码失败提示
    func clearScanFailure()
    /// 更新会话不可提交原因（过期 / 已绑定 / 已取消 / 已跳过 / ISSUED / 未知）
    func updateSessionBlockReason(_ reason: VehicleBindingSessionBlockReason?, context: VehiclePageContext)
    /// 更新轮询耗尽状态（仅当前上下文生效）
    func updatePollingExhausted(_ exhausted: Bool, context: VehiclePageContext)
    /// 更新登录门禁提示
    func updateLoginHint(_ hint: VehicleBindingLoginHint?)
}

// MARK: - Route

protocol VehicleModelRouterProtocol: MviModelRouterProtocol {
    /// 跳转至扫描页
    func routeToScan()
    /// 跳转至登录页（扫码前登录门禁）
    func routeToLogin()
}
