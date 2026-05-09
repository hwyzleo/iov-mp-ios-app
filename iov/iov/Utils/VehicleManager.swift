//
//  VehicleManager.swift
//  iov
//
//  Created by hwyz_leo on 2024/10/6.
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
    
    /// 更新我的车辆列表（合并心愿单和订单）
    func update(myVehicleList: [MyVehicleVo]) {
        print("🔄 VehicleManager.update() - Received \(myVehicleList.count) vehicles from cloud")
        
        // 先清除本地数据
        clear()
        
        // 验证是否真的清空了
        let realm = RealmManager.vehicle.realm
        let realmCount = realm.objects(VehiclePo.self).count
        print("🔄 VehicleManager.update() - Realm has \(realmCount) vehicles after clear()")
        
        if realmCount > 0 {
            print("⚠️ WARNING: Realm still has \(realmCount) vehicles after clear()! Forcing file deletion...")
            deleteRealmFile()
        }
        
        // 如果云端返回空列表，直接返回
        if myVehicleList.isEmpty {
            print("✅ VehicleManager.update() - Cloud returned empty list, local data cleared")
            return
        }
        
        // 添加云端数据
        for myVehicle in myVehicleList {
            // 处理 displayName 为 nil 的情况
            let displayName = myVehicle.displayName ?? "未命名车辆"
            
            switch myVehicle.type {
            case "WISHLIST":
                add(orderNum: myVehicle.id, type: .WISHLIST, subState: myVehicle.state, displayName: displayName)
            case "ORDER":
                add(orderNum: myVehicle.id, type: .ORDER, subState: myVehicle.state, displayName: displayName)
            case "ACTIVATED":
                add(orderNum: myVehicle.id, type: .ACTIVATED, subState: myVehicle.state, displayName: displayName)
            default:
                add(orderNum: myVehicle.id, type: .ORDER, subState: myVehicle.state, displayName: displayName)
            }
        }
        
        // 设置当前车辆
        if !vehicles.isEmpty {
            setCurrentVehicleId(id: vehicles.first!.key)
        }
        
        print("✅ VehicleManager.update() - Updated with \(vehicles.count) vehicles, currentVehicleId=\(currentVehicleId ?? "nil")")
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
        // 先检查内存缓存
        if currentVehicleId != nil && vehicles.keys.contains(currentVehicleId!) {
            print("📍 getCurrentVehicleId() - Returning cached ID: \(currentVehicleId!)")
            return currentVehicleId
        }
        
        // 内存缓存失效，清空并检查是否有订单
        currentVehicleId = nil
        if hasOrder() {
            currentVehicleId = vehicles.keys.first!
            print("📍 getCurrentVehicleId() - Setting new ID: \(currentVehicleId!)")
            return currentVehicleId
        }
        
        print("📍 getCurrentVehicleId() - No vehicles, returning nil")
        return nil
    }
    
    /// 获取当前选择的车辆
    func getCurrentVehicle() -> VehiclePo? {
        guard let id = currentVehicleId else {
            return nil
        }
        return vehicles[id]
    }
    
    /// 清除车辆（彻底清除，包括 Realm 文件）
    func clear() {
        let realm = RealmManager.vehicle.realm
        
        // 打印删除前的数据数量
        let beforeCount = realm.objects(VehiclePo.self).count
        print("🧹 VehicleManager.clear() - Before: \(beforeCount) vehicles in Realm")
        
        do {
            try realm.write {
                realm.delete(realm.objects(VehiclePo.self))
            }
        } catch {
            print("❌ Error deleting Realm objects: \(error)")
            // 删除失败时，尝试删除 Realm 文件
            deleteRealmFile()
        }
        
        // 验证删除是否成功
        RealmManager.vehicle.invalidateRealm()
        let realmAfter = RealmManager.vehicle.realm
        let afterCount = realmAfter.objects(VehiclePo.self).count
        print("🧹 VehicleManager.clear() - After: \(afterCount) vehicles in Realm")
        
        // 如果还有数据，强制删除文件
        if afterCount > 0 {
            print("⚠️ Realm delete failed, forcing file deletion")
            deleteRealmFile()
        }
        
        vehicles.removeAll()
        currentVehicleId = nil
    }
    
    /// 强制删除 Realm 文件（最后的手段）
    private func deleteRealmFile() {
        guard let realmURL = RealmManager.vehicle.realm.configuration.fileURL else {
            return
        }
        
        do {
            // 删除 Realm 文件
            try FileManager.default.removeItem(at: realmURL)
            print("✅ Realm file deleted: \(realmURL.path)")
            
            // 删除相关文件（锁文件、管理文件等）
            let lockURL = realmURL.appendingPathExtension("lock")
            let managementURL = realmURL.deletingLastPathComponent().appendingPathComponent("Management")
            
            try? FileManager.default.removeItem(at: lockURL)
            try? FileManager.default.removeItem(at: managementURL)
            
            // 清除缓存，下次会创建新的 Realm
            RealmManager.vehicle.invalidateRealm()
        } catch {
            print("❌ Failed to delete Realm file: \(error)")
        }
    }
    
    /// 仅供 MockService 调试使用的车辆列表获取
    func getVehiclesForMock() -> [String: VehiclePo] {
        return vehicles
    }
    
    private func getVehicles() -> [String: VehiclePo] {
        let realm = RealmManager.vehicle.realm
        realm.refresh()
        let vehiclesResults = realm.objects(VehiclePo.self)
        var result: [String: VehiclePo] = [:]
        for vehicle in vehiclesResults {
            result[vehicle.id] = vehicle
        }
        self.vehicles = result
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
    /// 发运申请
    case SHIPPING_APPLY = 470
    /// 待运输
    case PREPARE_TRANSPORT = 500
    /// 运输中
    case TRANSPORTING = 550
    /// 待交付
    case PREPARE_DELIVER = 600
    /// 已支付尾款
    case FINAL_PAYMENT_PAID = 620
    /// 已开票
    case INVOICED = 630
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
