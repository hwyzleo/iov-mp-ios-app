//
//  MyIntentProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

protocol MyIntentProtocol : MviIntentProtocol {
    /// 点击扫码
    func onTapScan()
    /// 点击我的二维码
    func onTapMyQrCode()
    /// 从扫码返回
    func onTapBackFromScan()
    /// 点击登录
    func onTapLogin()
    /// 点击消息
    func onTapMessage()
    /// 点击设置
    func onTapSetting()
    /// 点击用户资料
    func onTapProfile()
    /// 点击我的作品
    func onTapMyArticle()
    /// 点击我的积分
    func onTapMyPoints()
    /// 点击我的权益
    func onTapMyRights()
    /// 点击我的订单
    func onTapMyOrder()
    /// 点击邀请好友
    func onTapMyInvite()
    /// 点击试驾报告
    func onTapTestDriveReport()
    /// 点击充电桩
    func onTapChargingPile()
}
