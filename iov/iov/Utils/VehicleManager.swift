//
//  VehicleManager.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

import Foundation
import RealmSwift

class VehicleManager {
    
    static let shared = VehicleManager()
    
    private var vehicles: Dictionary<String, VehiclePo> = [:]
    
    /// 当前选择的车辆订单
    private var currentVehicleId: String?
    
    private init() {
        for vehicle in getVehicles() {
            vehicles[vehicle.key] = vehicle.value
        }
    }
    
    /// 是否拥有车辆
    func hasVehicle() -> Bool {
        for vehicle in vehicles.values {
            if vehicle.type == .ACTIVATED {
                return true
            }
        }
        return false
    }
    
    /// 是否拥有订单
    func hasOrder() -> Bool {
        return !vehicles.isEmpty
    }
    
    /// 订购车辆
    class func order(orderNum: String) {
        let vehicle = VehiclePo()
        vehicle.type = .ORDER
        vehicle.id = orderNum
        let realm = RealmManager.vehicle.realm
        do {
            try realm.write {
                realm.add(vehicle, update: .modified)
            }
        } catch {
            print("Error saving vehicles: \(error)")
        }
    }
    
    /// 更新车辆信息
    func update(vehicleSaleOrderList: [VehicleSaleOrder]) {
        clear()
        for (_, vehicleSaleOrder) in vehicleSaleOrderList.enumerated() {
            switch vehicleSaleOrder.orderState {
            case 100:
                add(orderNum: vehicleSaleOrder.orderNum, type: .WISHLIST, subState: 100, displayName: vehicleSaleOrder.displayName)
            case 700:
                add(orderNum: vehicleSaleOrder.orderNum, type: .ACTIVATED, subState: 700, displayName: vehicleSaleOrder.displayName)
            default:
                add(orderNum: vehicleSaleOrder.orderNum, type: .ORDER, subState: vehicleSaleOrder.orderState, displayName: vehicleSaleOrder.displayName)
            }
        }
        if !vehicles.isEmpty && (currentVehicleId == nil || !vehicles.keys.contains(currentVehicleId!)) {
            setCurrentVehicleId(id: vehicles.first!.key)
        }
    }
    
    /// 更新细分状态
    func updateSubState(id: String, subState: Int) {
        let realm = RealmManager.vehicle.realm
        if let vehiclePo = realm.object(ofType: VehiclePo.self, forPrimaryKey: id) {
            do {
                try realm.write {
                    vehiclePo.subState = subState
                }
            } catch {
                print("Error update subState: \(error)")
            }
        }
    }
    
    /// 添加车辆信息
    func add(orderNum: String, type: VehicleType, subState: Int = 0, displayName: String) {
        let vehicle = VehiclePo()
        vehicle.id = orderNum
        vehicle.type = type
        vehicle.subState = subState
        vehicle.displayName = displayName
        let realm = RealmManager.vehicle.realm
        do {
            try realm.write {
                realm.add(vehicle, update: .modified)
                vehicles[orderNum] = vehicle
            }
        } catch {
            print("Error saving vehicles: \(error)")
        }
    }
    
    /// 删除车辆信息
    func delete(orderNum: String) {
        if let vehiclePo = vehicles[orderNum] {
            let realm = RealmManager.vehicle.realm
            do {
                try realm.write {
                    realm.delete(vehiclePo)
                    realm.refresh()
                }
            } catch {
                print("Error clear vehicles: \(error)")
            }
            vehicles.removeValue(forKey: orderNum)
            if orderNum == currentVehicleId {
                currentVehicleId = nil
                if !vehicles.isEmpty {
                    currentVehicleId = vehicles.first?.key
                }
            }
        }
    }
    
    /// 设置当前选择的车辆
    func setCurrentVehicleId(id: String) {
        currentVehicleId = id
    }
    
    /// 获取当前选择的车辆ID
    func getCurrentVehicleId() -> String? {
        if currentVehicleId != nil && vehicles.keys.contains(currentVehicleId!) {
            return currentVehicleId
        }
        if hasOrder() {
            setCurrentVehicleId(id: vehicles.keys.first!)
            return vehicles.keys.first!
        }
        return nil
    }
    
    /// 获取当前选择的车辆
    func getCurrentVehicle() -> VehiclePo? {
        if currentVehicleId == nil {
            return nil
        }
        if getVehicles()[currentVehicleId!] == nil {
            return nil
        }
        return getVehicles()[currentVehicleId!]
    }
    
    /// 清除车辆
    func clear() {
        let realm = RealmManager.vehicle.realm
        do {
            try realm.write {
                realm.delete(realm.objects(VehiclePo.self))
                realm.refresh()
            }
            vehicles.removeAll() // 确保内存字典也被清空
        } catch {
            print("Error clear vehicles: \(error)")
        }
    }
    
    /// 仅供 MockService 调试使用的车辆列表获取
    func getVehiclesForMock() -> [String: VehiclePo] {
        return getVehicles()
    }
    
    private func getVehicles() -> [String: VehiclePo] {
        let realm = RealmManager.vehicle.realm
        realm.refresh() // 强制拉取磁盘最新变更
        let vehiclesResults = realm.objects(VehiclePo.self)
        var result: [String: VehiclePo] = [:]
        for vehicle in vehiclesResults {
            result[vehicle.id] = vehicle
        }
        self.vehicles = result // 同步刷新内存缓存
        return result
    }
    
}

/// 订单状态
enum OrderState: Int {
    /// 心愿单
    case WISHLIST = 100
    /// 意向金待支付
    case EARNEST_MONEY_UNPAID = 200
    /// 意向金已支付
    case EARNEST_MONEY_PAID = 210
    /// 定金待支付
    case DOWN_PAYMENT_UNPAID = 300
    /// 定金已支付
    case DOWN_PAYMENT_PAID = 310
    /// 安排生产
    case ARRANGE_PRODUCTION = 400
    /// 已分配车辆
    case ALLOCATION_VEHICLE = 450
    /// 待运输
    case PREPARE_TRANSPORT = 500
    /// 待交付
    case PREPARE_DELIVER = 600
    /// 已交付
    case DELIVERED = 650
    /// 已激活
    case ACTIVATED = 700
}

/// 车辆类型
enum VehicleType: String, PersistableEnum {
    /// 已激活车辆
    case ACTIVATED
    /// 订单车辆
    case ORDER
    /// 心愿单车辆
    case WISHLIST
}

/// 车辆持久化对象
@objcMembers
class VehiclePo: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var type: VehicleType = .ACTIVATED
    @Persisted var subState: Int = 0 // 细分状态，如 100:心愿单, 200:待支付定金, 201:待支付意向金, 300:已支付...
    @Persisted var vin: String = ""
    @Persisted var displayName: String = ""
}
