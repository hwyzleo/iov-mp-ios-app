//
//  VehicleManager.swift
//  iov
//
//  Created by 叶荣杰 on 2024/10/6.
//

import Foundation
import RealmSwift

@objcMembers
class VehicleManager: Object {
    
    dynamic var vehicles: Dictionary<String, VehiclePo> = [:]
    
    /// 车架号
    dynamic var vin: String = ""
    
    /// 是否拥有车辆
    class func hasVehicle() -> Bool {
        return !getVehicles().isEmpty
    }
    
    /// 订购车辆
    class func order(orderNum: String) {
        let vehicle = VehiclePo()
        vehicle.type = "order"
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
    
    /// 清楚车辆
    class func clear() {
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
    
    private class func getVehicles() -> [String: VehiclePo] {
        let realm = RealmManager.vehicle.realm
        let vehicles = realm.objects(VehiclePo.self)
        var result: [String: VehiclePo] = [:]
        for vehicle in vehicles {
            result[vehicle.id] = vehicle
        }
        return result
    }
    
}

/// 车辆持久化对象
class VehiclePo: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var type: String = ""
    @Persisted var vin: String = ""
}
