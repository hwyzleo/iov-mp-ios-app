//
//  VehicleIntentProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

protocol VehicleIntentProtocol : MviIntentProtocol {
    /// 点击扫描（未登录时先走登录门禁，不进入相机、不发请求）
    func onTapScan()
    /// 扫码结果（仅拿到最小待确认车辆信息，不代表已绑定）
    func onScanResult(payload: String)
    /// 登录完成（登录后续跑已扫到的 qrToken 一次）
    func onLoginCompleted()
    /// 登录取消 / 未完成（丢弃待续跑二维码，提示重新扫码）
    func onLoginCancelled()
    /// 扫码失败弹窗「重试」（复用同一次 qrToken）
    func onTapRetryScan()
    /// 扫码失败弹窗「去登录」（保留 qrToken 暂存，登录后续跑一次）
    func onTapScanLogin()
    /// 扫码失败弹窗「重新扫码」
    func onTapRescan()
    /// 关闭登录门禁提示
    func onDismissLoginHint()
    /// 前后台切换（后台停止轮询，回前台不自动重启）
    func onScenePhaseChange(isActive: Bool)
    /// 手动重试关系查询
    func onTapRefreshBinding()
    /// 用户确认绑定（同一次确认复用幂等键）
    func onConfirmBinding()
    /// 结果未知时刷新权威结果（按原 operationId / 幂等键）
    func onTapRefreshBindingResult()
    /// 关闭确认弹层（未成功则按取消处理，不删除已有关系）
    func onDismissBindingSheet()
    /// 关闭扫码失败提示
    func onDismissScanFailure()
    /// VehicleManager 数据变化（如 VSO 返回 VIN）后重新评估当前车辆上下文
    func onVehicleDataChanged()
    /// 点击订单详情
    func onTapOrderDetail()
    /// 点击上锁
    func onTapLock()
    /// 点击解锁
    func onTapUnlock()
    /// 点击设置窗户打开度
    func onTapSetWindow(percent: Int)
    /// 点击设置后备箱打开度
    func onTapSetTrunk(percent: Int)
    /// 点击寻车
    func onTapFind()
}
