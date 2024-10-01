//
//  VehicleModelProtocol.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
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
}

// MARK: - Route

protocol VehicleModelRouterProtocol: MviModelRouterProtocol {
    /// 跳转至扫描页
    func routeToScan()
}
