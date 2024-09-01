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
    var windowLoading: Bool = false
    var trunkLoading: Bool = false
    var findLoading: Bool = false
}

// MARK: - Action Protocol

extension VehicleModel: VehicleModelActionProtocol {
    func displayLoading() {
        contentState = .loading
    }
    func buttonLoading(button: String) {
        switch button {
        case "lock":
            self.lockLoading = true
        case "window":
            self.windowLoading = true
        case "trunk":
            self.trunkLoading = true
        case "find":
            self.findLoading = true
        default:
            self.lockLoading = false
        }
        contentState = .buttonLoading
    }
    func updateVehicle(vehicle: Vehicle, button: String) {
        self.vehicle = vehicle
        switch button {
        case "lock":
            self.lockLoading = false
        case "window":
            self.windowLoading = false
        case "trunk":
            self.trunkLoading = false
        case "find":
            self.findLoading = false
        default:
            self.lockLoading = false
            self.windowLoading = false
            self.trunkLoading = false
            self.findLoading = false
        }
        contentState = .content
    }
    func updateContent(vehicleIndex: VehicleIndex) {
        self.vehicle = vehicleIndex.vehicle
        contentState = .content
    }
    func displayError(text: String) {
        contentState = .error(text: text)
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
        case buttonLoading
        case content
        case error(text: String)
    }
}
