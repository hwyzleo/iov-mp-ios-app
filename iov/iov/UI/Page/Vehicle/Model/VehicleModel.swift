//
//  VehicleModel.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

final class VehicleModel: ObservableObject, VehicleModelStateProtocol {
    @Published var contentState: VehicleTypes.Model.ContentState = .content
    let routerSubject = VehicleRouter.Subjects()
    var vehicle: Vehicle?
    var lockLoading: Bool = false
    var lockDuration: Double = 0.0
    var windowLoading: Bool = false
    var windowDuration: Double = 0.0
    var trunkLoading: Bool = false
    var trunkDuration: Double = 0.0
    @Published var findLoading: Bool = false
    @Published var findDuration: Double = 0.0
    var cmdMapping: [String : String] = [:]
}

// MARK: - Action Protocol

extension VehicleModel: VehicleModelActionProtocol {
    func displayLoading() {
        contentState = .loading
    }
    func mappingCmdId(cmdId: String, button: String) {
        self.cmdMapping[cmdId] = button
    }
    func getCmdIdMapping(cmdId: String) -> String? {
        self.cmdMapping[cmdId]
    }
    func buttonLoading(button: String) {
        setButton(button: button, loading: true, duration: 0)
    }
    func buttonExecuting(button: String) {
        setButton(button: button, loading: false, duration: 10)
    }
    func updateVehicle(vehicle: Vehicle, button: String) {
        self.vehicle = vehicle
        setButton(button: button, loading: false, duration: 0)
        contentState = .content
    }
    func updateContent(vehicleIndex: VehicleIndex) {
        self.vehicle = vehicleIndex.vehicle
        contentState = .content
    }
    func displayInfo(text: String, button: String) {
        setButton(button: button, loading: false, duration: 0)
        contentState = .info(text: text)
    }
    func displayError(text: String, button: String) {
        setButton(button: button, loading: false, duration: 0)
        contentState = .error(text: text)
    }
    func displayError(text: String) {
        contentState = .error(text: text)
    }
    
    private func setButton(button: String, loading: Bool, duration: Double) {
        switch button {
        case "lock":
            self.lockLoading = loading
            self.lockDuration = duration
        case "window":
            self.windowLoading = loading
            self.windowDuration = duration
        case "trunk":
            self.trunkLoading = loading
            self.trunkDuration = duration
        case "find":
            self.findLoading = loading
            self.findDuration = duration
        default:break
        }
    }
}

// MARK: - Route

extension VehicleModel: VehicleModelRouterProtocol {
    func closeScreen() {}
    func routeToScan() {
        routerSubject.screen.send(.scan)
    }
}

extension VehicleTypes.Model {
    enum ContentState {
        case loading
        case content
        case info(text: String)
        case error(text: String)
    }
}
