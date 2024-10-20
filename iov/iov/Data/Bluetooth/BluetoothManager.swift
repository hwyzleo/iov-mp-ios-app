//
//  BluetoothManager.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import CoreBluetooth

class BluetoothManager: NSObject {
    public static let shared = BluetoothManager()
    private var centralManager: CBCentralManager!
    /// 开关状态
    private(set) var cbManagerState: CBManagerState = .unknown
    /// 连接状态
    private(set) var cbConnetionState: CbConnectionState = .disconnected
    private var timer: Timer?
    private var peripheral:CBPeripheral?
    private var characteristicWrite: CBCharacteristic?
    private var completion: ((Result<BluetoothResponse<NoReply>, Error>) -> Void)?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: .main)
        loopConnect()
    }
}

/// 外部方法
extension BluetoothManager {
    /// 获取授权
    func getPrivillege() -> Bool {
        switch CBPeripheralManager.authorization {
        case .allowedAlways:
            return true
        default:
            return false
        }
    }
    /// 扫描外部设备
    func scan() {
        debugPrint("扫描外设")
        if cbManagerState == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil)
        }
    }
    /// 是否连接
    func isConnected() -> Bool {
        return cbConnetionState == .connected
    }
    /// 向外设写数据
    func writeData(data: Data, completion: @escaping (Result<BluetoothResponse<NoReply>, Error>) -> Void) {
        guard let characteristic = characteristicWrite else {
            return
        }
        self.completion = completion
        peripheral?.writeValue(data, for: characteristic, type: .withResponse)
    }
}

/// 内部方法
extension BluetoothManager {
    /// 循环连接车辆
    private func loopConnect() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            if self.cbConnetionState == .disconnected {
                self.scan()
            }
        }
    }
}

/// 中心设备代理
extension BluetoothManager: CBCentralManagerDelegate {
    /// 更新状态
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        cbManagerState = central.state
    }
    /// 发现外设
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // 获取厂商信息
        // 无法Mock厂商数据
        // guard let kCBAdvDataManufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data else { return }
        // let kCBAdvDataManufacturerStr = kCBAdvDataManufacturerData.hexToStr()
        // if kCBAdvDataManufacturerStr != "OpenIov" {
        //     return
        // }
        // 获取设备信息
        guard let kCBAdvDataLocalNameDataStr = advertisementData["kCBAdvDataLocalName"] as? String else { return }
//        debugPrint("发现外设:\(kCBAdvDataLocalNameDataStr)")
        if kCBAdvDataLocalNameDataStr == "Vehicle" {
            self.peripheral = peripheral
            debugPrint("连接外设")
            centralManager.connect(peripheral, options: nil)
        }
    }
    /// 连接成功
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
    }
    /// 连接失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
    }
    /// 断开连接
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
    }
}

/// 外设代理
extension BluetoothManager: CBPeripheralDelegate {
    /// 发现服务
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
    }
    /// 发现特征值
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
    }
    /// 收到数据
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    /// 外写数据
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            completion?(.failure(error))
        } else {
            completion?(.success(BluetoothResponse.init(code: 0, ts: Date().timestamp())))
        }
    }
}

/// 蓝牙连接状态
enum CbConnectionState: Int {
    /// 断开连接
    case disconnected
    /// 连接失败
    case failed
    /// 连接超时
    case timeOut
    /// 鉴权失败
    case authFailed
    /// 连接成功
    case connected
    /// 鉴权中
    case authing
    /// 鉴权成功
    case authed
}
