//
//  VehicleIntent.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI
import Combine

class VehicleIntent: MviIntentProtocol {
    private weak var modelAction: VehicleModelActionProtocol?
    private weak var modelRouter: VehicleModelRouterProtocol?
    private var findVehicleTimer: Timer?
    private let bindingCoordinator: VehicleBindingCoordinator
    private var startedContext: VehiclePageContext?
    /// 是否已请求过我的车辆列表（用于 VSO 返回 VIN 后自动补全上下文）
    private var didRequestVehicleList = false

    // MARK: - 扫码前登录门禁（IOS-APP-DSN-CR-011 D-011-1）

    private let loginGate: LoginGateProviding
    /// 已扫到但未提交的 qrToken（仅内存、TTL 内有效、不落盘不打日志）
    private let pendingQRTokenStore: PendingQRTokenStore
    /// 本次未登录点击扫码（登录后直接进相机，不弹二次提示）
    private var pendingScanEntry = false
    private var loginStateSubscription: AnyCancellable?

    init(model: VehicleModelActionProtocol & VehicleModelRouterProtocol,
         loginGate: LoginGateProviding = AppLoginGate.shared,
         pendingQRTokenStore: PendingQRTokenStore = PendingQRTokenStore()) {
        self.modelAction = model
        self.modelRouter = model
        self.loginGate = loginGate
        self.pendingQRTokenStore = pendingQRTokenStore
        self.bindingCoordinator = VehicleBindingCoordinator(service: ServiceContainer.vehicleBindingService)
        bindCoordinator()
        bindLoginState()
    }

    /// 登录态变化 → 自动续跑已扫到的 qrToken（每个登录闭环最多一次）
    private func bindLoginState() {
        loginStateSubscription = loginGate.loginState
            .removeDuplicates()
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoggedIn in
                guard let self else { return }
                if isLoggedIn {
                    self.onLoginCompleted()
                } else if self.pendingScanEntry || self.pendingQRTokenStore.hasPending {
                    self.onLoginCancelled()
                }
            }
    }

    /// 绑定编排回调 → 页面状态（均回到主线程，且 Model 会再校对上下文）
    private func bindCoordinator() {
        bindingCoordinator.onRelationship = { [weak self] context, state in
            DispatchQueue.main.async {
                self?.modelAction?.updateRelationship(state, context: context)
            }
        }
        bindingCoordinator.onSession = { [weak self] context, session in
            DispatchQueue.main.async {
                self?.modelAction?.updateBindingSession(session, context: context)
            }
        }
        bindingCoordinator.onOperation = { [weak self] context, state in
            DispatchQueue.main.async {
                self?.modelAction?.updateBindingOperation(state,
                                                          failure: self?.bindingCoordinator.lastTransientFailure,
                                                          context: context)
            }
        }
        bindingCoordinator.onScanFailure = { [weak self] context, failure in
            DispatchQueue.main.async {
                self?.modelAction?.updateScanFailure(failure, context: context)
            }
        }
        bindingCoordinator.onSessionBlocked = { [weak self] context, reason in
            DispatchQueue.main.async {
                self?.modelAction?.updateSessionBlockReason(reason, context: context)
            }
        }
        bindingCoordinator.onPolling = { [weak self] context, exhausted in
            DispatchQueue.main.async {
                self?.modelAction?.updatePollingExhausted(exhausted, context: context)
            }
        }
    }
    
    func viewOnAppear() {
        let context = makePageContext()
        // 账号/车辆变化才重新开始；同一页面内保留已确认的绑定结果
        if startedContext != context {
            apply(context, reloadVehicleIndex: true)
        } else if bindingCoordinator.context == nil {
            bindingCoordinator.start(context: context)
        }
        refreshVehicleListIfVinMissing()
    }

    /// VSO `myVehicleList` 是 VIN 的权威来源；本地缺失/非法时补拉一次，拿到后由
    /// `onVehicleDataChanged` 触发关系查询。失败保持未知，不做任何推断。
    private func refreshVehicleListIfVinMissing() {
        guard startedContext?.vin == nil, !didRequestVehicleList else { return }
        didRequestVehicleList = true
        ServiceContainer.marketingService.getMyVehicleList { result in
            switch result {
            case .success(let response):
                if response.isSuccess, let list = response.data {
                    VehicleManager.shared.update(myVehicleList: list)
                } else {
                    self.didRequestVehicleList = false
                }
            case .failure(let error):
                SafeLog.log("车辆列表补拉失败:", String(describing: error))
                self.didRequestVehicleList = false
            }
        }
    }

    /// VehicleManager 数据变化（典型场景：VSO `myVehicleList` 刚返回 VIN）。
    /// 只处理“当前车已交付且上下文确实变化”的情况，避免批量写库期间的中间态抖动。
    func onVehicleDataChanged() {
        guard VehicleManager.shared.getCurrentVehicle()?.type == .ACTIVATED else { return }
        let context = makePageContext()
        guard context.hasAccountAndVehicle else { return }
        guard startedContext != context else { return }
        apply(context, reloadVehicleIndex: false)
    }

    private func apply(_ context: VehiclePageContext, reloadVehicleIndex: Bool) {
        startedContext = context
        // 账号/车辆切换：丢弃待续跑二维码，防跨账号续跑（D-011-1 §3.2）
        pendingQRTokenStore.invalidate()
        modelAction?.setContext(context)
        bindingCoordinator.start(context: context)
        if reloadVehicleIndex {
            modelAction?.displayLoading()
            loadVehicleIndex(fallbackVin: context.vin)
        }
    }

    /// 当前账号 + 当前选中车辆 + 可得的 VIN
    private func makePageContext() -> VehiclePageContext {
        let accountId = UserManager.getUser()?.userId ?? ""
        let vehicleId = VehicleManager.shared.getCurrentVehicleId() ?? ""
        // 只有合法 VIN 才可作为关系查询上下文；非法/缺失按未知处理
        let rawVin = VehicleVin.normalize(VehicleManager.shared.getCurrentVin())
        let vin = VehicleVin.isValid(rawVin) ? rawVin : nil
        return VehiclePageContext(accountId: accountId, vehicleId: vehicleId, vin: vin)
    }

    private func loadVehicleIndex(fallbackVin: String?) {
        ServiceContainer.vehicleService.getVehicleIndex { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                if response.isSuccess, let data = response.data {
                    self.modelAction?.updateContent(vehicleIndex: data)
                    // VSO 订单未返回 VIN 时，用 TSP 车辆信息里的 VIN 作为当前车辆标识（仍需服务端校验）
                    let normalizedVin = VehicleVin.normalize(data.vehicle.vin)
                    if (fallbackVin ?? "").isEmpty, let normalizedVin, VehicleVin.isValid(normalizedVin), self.startedContext?.vin == nil {
                        guard let current = self.startedContext, current.vehicleId == VehicleManager.shared.getCurrentVehicleId() else { return }
                        let updated = VehiclePageContext(accountId: current.accountId, vehicleId: current.vehicleId, vin: normalizedVin)
                        self.startedContext = updated
                        self.modelAction?.setContext(updated)
                        self.bindingCoordinator.start(context: updated)
                    }
                } else {
                    self.modelAction?.displayError(text: response.message ?? "异常")
                }
            case .failure(let error):
                print(error)
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
}

extension VehicleIntent: VehicleIntentProtocol {
    func onTapScan() {
        // D-011-1：未登录先登录，不进入相机、不发任何请求
        guard loginGate.isLoggedIn else {
            pendingScanEntry = true
            modelAction?.updateLoginHint(.loginRequired)
            modelRouter?.routeToLogin()
            return
        }
        pendingScanEntry = false
        modelAction?.updateLoginHint(nil)
        modelRouter?.routeToScan()
    }

    func onScanResult(payload: String) {
        // 相机流程中登录态失效（后台被清/退出）：暂存二维码，登录后续跑
        guard loginGate.isLoggedIn else {
            pendingQRTokenStore.store(payload)
            pendingScanEntry = false
            modelAction?.updateLoginHint(.loginRequired)
            modelRouter?.routeToLogin()
            return
        }
        bindingCoordinator.beginScan(qrToken: payload)
    }

    func onLoginCompleted() {
        modelAction?.updateLoginHint(nil)
        if let token = pendingQRTokenStore.take() {
            pendingScanEntry = false
            // 自动续跑一次，用户无需重扫
            bindingCoordinator.beginScan(qrToken: token)
            return
        }
        if pendingScanEntry {
            pendingScanEntry = false
            modelRouter?.routeToScan()
        }
    }

    func onLoginCancelled() {
        let hadPending = pendingQRTokenStore.hasPending
        pendingQRTokenStore.invalidate()
        pendingScanEntry = false
        guard hadPending else { return }
        modelAction?.updateLoginHint(.rescanRequired)
    }

    func onTapRetryScan() {
        modelAction?.clearScanFailure()
        // 复用同一次 qrToken（服务端扫码认领幂等，不新建幂等键）
        if !bindingCoordinator.retryScan() {
            modelRouter?.routeToScan()
        }
    }

    func onTapScanLogin() {
        modelAction?.clearScanFailure()
        modelRouter?.routeToLogin()
    }

    func onTapRescan() {
        modelAction?.clearScanFailure()
        if loginGate.isLoggedIn {
            modelRouter?.routeToScan()
        } else {
            modelRouter?.routeToLogin()
        }
    }

    func onDismissLoginHint() {
        modelAction?.updateLoginHint(nil)
    }

    func onScenePhaseChange(isActive: Bool) {
        guard !isActive else { return }
        // 后台停止自动恢复；回前台不自动重启（仅保留手动刷新）
        bindingCoordinator.pausePolling()
    }

    func onTapRefreshBinding() {
        if startedContext?.vin == nil {
            // VIN 仍缺失时先补拉车辆列表，再按当前上下文重试关系查询
            didRequestVehicleList = false
            refreshVehicleListIfVinMissing()
        }
        bindingCoordinator.refreshRelationship()
    }

    func onConfirmBinding() {
        bindingCoordinator.confirm()
    }

    func onTapRefreshBindingResult() {
        bindingCoordinator.refreshBindingResult()
    }

    func onDismissBindingSheet() {
        bindingCoordinator.dismissBindingSheet()
    }

    func onDismissScanFailure() {
        modelAction?.clearScanFailure()
    }

    func onTapOrderDetail() {
        let orderNo = VehicleManager.shared.getCurrentVehicleId() ?? ""
        guard !orderNo.isEmpty else { return }
        // 650/900 复用既有「已提车」只读详情页
        AppGlobalState.shared.parameters["orderDetailView"] = "DELIVERED"
        AppRouter.shared.push(.marketing(.orderDetail(orderNo: orderNo)))
    }

    func onTapLock() {
        modelAction?.buttonLoading(button: "lock")
        ServiceContainer.vehicleService.lockVehicle { result in
            switch result {
            case .success(let response):
                if response.isSuccess {
                    // 更新本地状态
                    var vehicle = mockVehicle()
                    vehicle.lockState = true
                    self.modelAction?.updateVehicle(vehicle: vehicle, button: "lock")
                } else {
                    self.modelAction?.displayError(text: response.message ?? "异常")
                }
            case .failure(let error):
                print(error)
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    func onTapUnlock() {
        modelAction?.buttonLoading(button: "lock")
        if BluetoothManager.shared.isConnected() {
            BluetoothApi.unlockVehicle() { (result: Result<BluetoothResponse<NoReply>, Error>) in
                switch result {
                case .success(let response):
                    if(response.isSuccess) {
                        var vehicle = mockVehicle()
                        vehicle.lockState = false
                        self.modelAction?.updateVehicle(vehicle: vehicle, button: "lock")
                    } else {
                        self.modelAction?.displayError(text: response.message ?? "异常")
                    }
                case let .failure(error):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        } else {
            TspApi.unlockVehicle() { (result: Result<TspResponse<NoReply>, Error>) in
                switch result {
                case .success(let response):
                    if(response.isSuccess) {
                        var vehicle = mockVehicle()
                        vehicle.lockState = false
                        self.modelAction?.updateVehicle(vehicle: vehicle, button: "lock")
                    } else {
                        self.modelAction?.displayError(text: response.message ?? "异常")
                    }
                case let .failure(error):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    func onTapSetWindow(percent: Int) {
        modelAction?.buttonLoading(button: "window")
        if BluetoothManager.shared.isConnected() {
            BluetoothApi.setWindow(percent: percent) { (result: Result<BluetoothResponse<NoReply>, Error>) in
                switch result {
                case .success(let response):
                    if(response.isSuccess) {
                        var vehicle = mockVehicle()
                        vehicle.windowPercentage = percent
                        self.modelAction?.updateVehicle(vehicle: vehicle, button: "window")
                    } else {
                        self.modelAction?.displayError(text: response.message ?? "异常")
                    }
                case let .failure(error):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        } else {
            TspApi.setWindow(percent: percent) { (result: Result<TspResponse<NoReply>, Error>) in
                switch result {
                case .success(let response):
                    if(response.isSuccess) {
                        var vehicle = mockVehicle()
                        vehicle.windowPercentage = percent
                        self.modelAction?.updateVehicle(vehicle: vehicle, button: "window")
                    } else {
                        self.modelAction?.displayError(text: response.message ?? "异常")
                    }
                case let .failure(error):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    func onTapSetTrunk(percent: Int) {
        modelAction?.buttonLoading(button: "trunk")
        if BluetoothManager.shared.isConnected() {
            BluetoothApi.setTrunk(percent: percent) { (result: Result<BluetoothResponse<NoReply>, Error>) in
                switch result {
                case .success(let response):
                    if(response.isSuccess) {
                        var vehicle = mockVehicle()
                        vehicle.trunkPercentage = percent
                        self.modelAction?.updateVehicle(vehicle: vehicle, button: "trunk")
                    } else {
                        self.modelAction?.displayError(text: response.message ?? "异常")
                    }
                case let .failure(error):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        } else {
            TspApi.setTrunk(percent: percent) { (result: Result<TspResponse<NoReply>, Error>) in
                switch result {
                case .success(let response):
                    if(response.isSuccess) {
                        var vehicle = mockVehicle()
                        vehicle.trunkPercentage = percent
                        self.modelAction?.updateVehicle(vehicle: vehicle, button: "trunk")
                    } else {
                        self.modelAction?.displayError(text: response.message ?? "异常")
                    }
                case let .failure(error):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    func onTapFind() {
        modelAction?.buttonLoading(button: "find")
        if BluetoothManager.shared.isConnected() {
            BluetoothApi.findVehicle() { (result: Result<BluetoothResponse<NoReply>, Error>) in
                switch result {
                case .success(let response):
                    if(response.isSuccess) {
                        let vehicle = mockVehicle()
                        self.modelAction?.updateVehicle(vehicle: vehicle, button: "find")
                    } else {
                        self.modelAction?.displayError(text: response.message ?? "异常")
                    }
                case let .failure(error):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        } else {
            TspApi.findVehicle(vin: "HWYZTEST000000001") { (result: Result<TspResponse<RemoteControlState>, Error>) in
                switch result {
                case .success(let response):
                    if(response.isSuccess) {
                        if let cmdId = response.data?.cmdId as? String {
                            self.modelAction?.mappingCmdId(cmdId: cmdId, button: "find")
                            self.startGetFindVehicleState(cmdId: cmdId)
                        }
                    } else {
                        self.modelAction?.displayError(text: response.message ?? "异常", button: "find")
                    }
                case let .failure(error):
                    self.modelAction?.displayError(text: error.localizedDescription, button: "find")
                }
            }
        }
    }
    private func startGetFindVehicleState(cmdId: String) {
        let queue = DispatchQueue.global(qos: .background)
        queue.async {
            self.findVehicleTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
                self.getCmdState(cmdId: cmdId)
            }
            RunLoop.current.run()
        }
    }
    func stopGetFindVehicleState() {
        findVehicleTimer?.invalidate()
        findVehicleTimer = nil
    }
    private func getCmdState(cmdId: String) {
        TspApi.getCmdState(vin: "HWYZTEST000000001", cmdId: cmdId) { (result: Result<TspResponse<RemoteControlState>, Error>) in
            switch result {
            case .success(let response):
                if response.isSuccess {
                    let cmdId = response.data?.cmdId
                    let button: String = (self.modelAction?.getCmdIdMapping(cmdId: cmdId!)!)!
                    let cmdState = response.data?.cmdState
                    if(cmdState == "EXECUTING") {
                        self.modelAction?.buttonExecuting(button: button)
                    }
                    if(cmdState == "SUCCESS") {
                        self.stopGetFindVehicleState()
                        self.modelAction?.displayInfo(text: "执行成功", button: button)
                    }
                    if(cmdState == "FAILURE") {
                        self.stopGetFindVehicleState()
                        self.modelAction?.displayError(text: "执行失败", button: button)
                    }
                    DispatchQueue.main.async {
                        
                    }
                } else {
                    // Handle error
                    print("Error polling find vehicle status: \(response.message ?? "Unknown error")")
                }
            case .failure(let error):
                // Handle network error
                print("Network error while polling find vehicle status: \(error.localizedDescription)")
            }
        }
    }
}
