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
        for (index, vehicleSaleOrder) in vehicleSaleOrderList.enumerated() {
            if vehicleSaleOrder.orderState == 100 {
                add(orderNum: vehicleSaleOrder.orderNum, type: .WISHLIST, displayName: vehicleSaleOrder.displayName)
            } else if vehicleSaleOrder.orderState == 700 {
                add(orderNum: vehicleSaleOrder.orderNum, type: .ACTIVATED, displayName: vehicleSaleOrder.displayName)
            } else {
                add(orderNum: vehicleSaleOrder.orderNum, type: .ORDER, displayName: vehicleSaleOrder.displayName)
            }
            if currentVehicleId == nil && index == 0 {
                setCurrentVehicleId(id: vehicleSaleOrder.orderNum)
            }
        }
    }
    
    /// 添加车辆信息
    func add(orderNum: String, type: VehicleType, displayName: String) {
        let vehicle = VehiclePo()
        vehicle.id = orderNum
        vehicle.type = type
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
        if currentVehicleId != nil {
            return currentVehicleId
        }
        if hasVehicle() {
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
        vehicles.removeAll()
        let realm = RealmManager.vehicle.realm
        do {
            try realm.write {
                realm.deleteAll()
                realm.refresh()
            }
        } catch {
            print("Error clear vehicles: \(error)")
        }
    }
    
    private func getVehicles() -> [String: VehiclePo] {
        let realm = RealmManager.vehicle.realm
        let vehicles = realm.objects(VehiclePo.self)
        var result: [String: VehiclePo] = [:]
        for vehicle in vehicles {
            result[vehicle.id] = vehicle
        }
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
    @Persisted var vin: String = ""
    @Persisted var displayName: String = ""
}
