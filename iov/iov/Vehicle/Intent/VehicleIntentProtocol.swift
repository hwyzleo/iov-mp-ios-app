//
//  VehicleIntentProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

protocol VehicleIntentProtocol : MviIntentProtocol {
    /// 点击扫描
    func onTapScan()
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
