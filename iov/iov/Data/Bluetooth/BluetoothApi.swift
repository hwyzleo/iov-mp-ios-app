//
//  BluetoothApi.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import Foundation

/// 蓝牙接口
class BluetoothApi {
    
    /// Mock状态
    static private var isMock = true
    
    /// 解锁车辆
    static func unlockVehicle(completion: @escaping (Result<BluetoothResponse<NoReply>, Error>) -> Void) {
        sendVehicleControlCmd(controlCmd: .lock, parameter: .off, completion: completion)
    }
    
    /// 上锁车辆
    static func lockVehicle(completion: @escaping (Result<BluetoothResponse<NoReply>, Error>) -> Void) {
        sendVehicleControlCmd(controlCmd: .lock, parameter: .on, completion: completion)
    }
    
    /// 设置后备箱
    static func setTrunk(percent: Int, completion: @escaping (Result<BluetoothResponse<NoReply>, Error>) -> Void) {
        var paramter: ControlParameter = .off
        if(percent > 0) {
            paramter = .on
        }
        sendVehicleControlCmd(controlCmd: .trunk, parameter: paramter, completion: completion)
    }
    
    /// 设置车窗
    static func setWindow(percent: Int, completion: @escaping (Result<BluetoothResponse<NoReply>, Error>) -> Void) {
        var paramter: ControlParameter = .off
        if(percent > 0) {
            paramter = .on
        }
        sendVehicleControlCmd(controlCmd: .window, parameter: paramter, completion: completion)
    }
    
    /// 寻车
    static func findVehicle(completion: @escaping (Result<BluetoothResponse<NoReply>, Error>) -> Void) {
        sendVehicleControlCmd(controlCmd: .find, parameter: .on, completion: completion)
    }
    
    /// 发送车控命令
    static private func sendVehicleControlCmd(controlCmd: ControlCmd, parameter: ControlParameter, completion: @escaping (Result<BluetoothResponse<NoReply>, Error>) -> Void) {
        if(!isMock) {
            sendCmd(cmdType: .control, cmd: controlCmd.rawValue, parameter: parameter.rawValue, completion: completion)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                completion(.success(BluetoothResponse.init(code: 0, ts: Int64(Date().timeIntervalSince1970*1000))))
            }
        }
    }
    /// 发送通用命令
    static private func sendCmd(cmdType: CmdType, cmd: String, parameter: String, completion: @escaping (Result<BluetoothResponse<NoReply>, Error>) -> Void) {
        var data: Data = (cmdType.rawValue + cmd + parameter).toHexData()
        BluetoothManager.shared.writeData(data: data, completion: completion)
    }
}

/// 命令类型
enum CmdType: String {
    case control = "0"
}

/// 车控命令
enum ControlCmd: String {
    case lock = "0"
    case window = "1"
    case trunk = "2"
    case find = "3"
}

/// 车控参数
enum ControlParameter: String {
    case off = "00"
    case on = "01"
}
