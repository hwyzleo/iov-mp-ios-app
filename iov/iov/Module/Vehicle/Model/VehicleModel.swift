//
//  VehicleModel.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

final class VehicleModel: ObservableObject, VehicleModelStateProtocol {
    @Published var contentState: VehicleTypes.Model.ContentState = .content
    let routerSubject = VehicleRouter.Subjects()
    var vehicle: Vehicle?
    var lockLoading: Bool = false
    var lockDuration: Double = 0.0
    var windowLoading: Bool = false
    var windowDuration: Double = 0.0
    var trunkLoading: Bool = false
    var trunkDuration: Double = 0.0
    @Published var findLoading: Bool = false
    @Published var findDuration: Double = 0.0
    var cmdMapping: [String : String] = [:]

    // MARK: - 绑定 / 关系状态（IOS-APP-DSN-CR-010）

    @Published private(set) var relationshipState: VehicleRelationshipState = .loading
    /// 当前 App 无车机登录状态查询接口，按 unknown 保持（不声称待完成或失败）
    @Published private(set) var loginState: VehicleLoginState = .unknown
    @Published private(set) var bindingOperationState: VehicleBindingOperationState = .idle
    @Published private(set) var bindingSession: VehicleBindingSession?
    @Published private(set) var lastBindingFailure: VehicleBindingFailure?
    @Published private(set) var scanFailure: VehicleBindingFailure?
    /// 结果未知轮询已耗尽（IOS-APP-DSN-CR-011 D-011-3）
    @Published private(set) var pollingExhausted: Bool = false
    /// 会话不可提交原因（IOS-APP-DSN-CR-011 D-011-2）
    @Published private(set) var sessionBlockReason: VehicleBindingSessionBlockReason?
    /// 登录门禁提示（IOS-APP-DSN-CR-011 D-011-1）
    @Published private(set) var loginHint: VehicleBindingLoginHint?
    private(set) var pageContext: VehiclePageContext?

    /// 扫码失败的动作分类（弹窗按钮据此渲染）
    var scanFailureAction: ScanFailureAction? {
        scanFailure?.scanFailureAction
    }

    var displayState: VehiclePageDisplayState {
        VehiclePageDisplayState.derive(relationship: relationshipState, login: loginState)
    }

    var maskedVin: String? {
        VehicleVinMask.mask(pageContext?.vin ?? bindingSession?.vin ?? vehicle?.vin)
    }
}

// MARK: - Action Protocol

extension VehicleModel: VehicleModelActionProtocol {
    func displayLoading() {
        contentState = .loading
    }
    func mappingCmdId(cmdId: String, button: String) {
        self.cmdMapping[cmdId] = button
    }
    func getCmdIdMapping(cmdId: String) -> String? {
        self.cmdMapping[cmdId]
    }
    func buttonLoading(button: String) {
        setButton(button: button, loading: true, duration: 0)
    }
    func buttonExecuting(button: String) {
        setButton(button: button, loading: false, duration: 10)
    }
    func updateVehicle(vehicle: Vehicle, button: String) {
        self.vehicle = vehicle
        setButton(button: button, loading: false, duration: 0)
        contentState = .content
    }
    func updateContent(vehicleIndex: VehicleIndex) {
        self.vehicle = vehicleIndex.vehicle
        contentState = .content
    }
    func displayInfo(text: String, button: String) {
        setButton(button: button, loading: false, duration: 0)
        contentState = .info(text: text)
    }
    func displayError(text: String, button: String) {
        setButton(button: button, loading: false, duration: 0)
        contentState = .error(text: text)
    }
    func displayError(text: String) {
        contentState = .error(text: text)
    }

    func setContext(_ context: VehiclePageContext) {
        pageContext = context
        relationshipState = .loading
        loginState = .unknown
        bindingOperationState = .idle
        bindingSession = nil
        lastBindingFailure = nil
        scanFailure = nil
        pollingExhausted = false
        sessionBlockReason = nil
    }

    func updateRelationship(_ state: VehicleRelationshipState, context: VehiclePageContext) {
        guard isCurrent(context) else { return }
        relationshipState = state
    }

    func updateBindingSession(_ session: VehicleBindingSession?, context: VehiclePageContext) {
        guard isCurrent(context) else { return }
        bindingSession = session
        if session != nil { scanFailure = nil }
        if session == nil {
            sessionBlockReason = nil
            pollingExhausted = false
        }
    }

    func updateBindingOperation(_ state: VehicleBindingOperationState,
                                failure: VehicleBindingFailure?,
                                context: VehiclePageContext) {
        guard isCurrent(context) else { return }
        bindingOperationState = state
        lastBindingFailure = failure
    }

    func updateScanFailure(_ failure: VehicleBindingFailure?, context: VehiclePageContext) {
        guard isCurrent(context) else { return }
        scanFailure = failure
    }

    func clearScanFailure() {
        scanFailure = nil
    }

    func updateSessionBlockReason(_ reason: VehicleBindingSessionBlockReason?, context: VehiclePageContext) {
        guard isCurrent(context) else { return }
        sessionBlockReason = reason
    }

    func updatePollingExhausted(_ exhausted: Bool, context: VehiclePageContext) {
        guard isCurrent(context) else { return }
        pollingExhausted = exhausted
    }

    func updateLoginHint(_ hint: VehicleBindingLoginHint?) {
        loginHint = hint
    }

    /// 迟到响应与切换账号/车辆后的旧响应一律丢弃
    private func isCurrent(_ context: VehiclePageContext) -> Bool {
        guard let pageContext else { return false }
        return pageContext == context
    }
    
    private func setButton(button: String, loading: Bool, duration: Double) {
        switch button {
        case "lock":
            self.lockLoading = loading
            self.lockDuration = duration
        case "window":
            self.windowLoading = loading
            self.windowDuration = duration
        case "trunk":
            self.trunkLoading = loading
            self.trunkDuration = duration
        case "find":
            self.findLoading = loading
            self.findDuration = duration
        default:break
        }
    }
}

// MARK: - Route

extension VehicleModel: VehicleModelRouterProtocol {
    func closeScreen() {}
    func routeToScan() {
        routerSubject.screen.send(.scan)
    }
    func routeToLogin() {
        routerSubject.screen.send(.login)
    }
}

extension VehicleTypes.Model {
    enum ContentState {
        case loading
        case content
        case info(text: String)
        case error(text: String)
    }
}
