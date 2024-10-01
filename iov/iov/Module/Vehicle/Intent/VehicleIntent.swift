//
//  VehicleIntent.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI

class VehicleIntent: MviIntentProtocol {
    private weak var modelAction: VehicleModelActionProtocol?
    private weak var modelRouter: VehicleModelRouterProtocol?
    private var findVehicleTimer: Timer?
    
    
    init(model: VehicleModelActionProtocol & VehicleModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    func viewOnAppear() {
        modelAction?.displayLoading()
        TspApi.getVehicleIndex() { (result: Result<TspResponse<VehicleIndex>, Error>) in
            switch result {
            case .success(let response):
                if(response.code == 0) {
                    self.modelAction?.updateContent(vehicleIndex: response.data!)
                } else {
                    self.modelAction?.displayError(text: response.message ?? "异常")
                }
            case let .failure(error):
                print(error)
                self.modelAction?.displayError(text: "请求异常")
            }
        }
    }
}

extension VehicleIntent: VehicleIntentProtocol {
    func onTapScan() {
        modelRouter?.routeToScan()
    }
    func onTapLock() {
        modelAction?.buttonLoading(button: "lock")
        if BluetoothManager.shared.isConnected() {
            BluetoothApi.lockVehicle() { (result: Result<BluetoothResponse<NoReply>, Error>) in
                switch result {
                case .success(let response):
                    if(response.code == 0) {
                        var vehicle = mockVehicle()
                        vehicle.lockState = true
                        self.modelAction?.updateVehicle(vehicle: vehicle, button: "lock")
                    } else {
                        self.modelAction?.displayError(text: response.message ?? "异常")
                    }
                case let .failure(error):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        } else {
            TspApi.lockVehicle() { (result: Result<TspResponse<NoReply>, Error>) in
                switch result {
                case .success(let response):
                    if(response.code == 0) {
                        var vehicle = mockVehicle()
                        vehicle.lockState = true
                        self.modelAction?.updateVehicle(vehicle: vehicle, button: "lock")
                    } else {
                        self.modelAction?.displayError(text: response.message ?? "异常")
                    }
                case let .failure(error):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    func onTapUnlock() {
        modelAction?.buttonLoading(button: "lock")
        if BluetoothManager.shared.isConnected() {
            BluetoothApi.unlockVehicle() { (result: Result<BluetoothResponse<NoReply>, Error>) in
                switch result {
                case .success(let response):
                    if(response.code == 0) {
                        var vehicle = mockVehicle()
                        vehicle.lockState = false
                        self.modelAction?.updateVehicle(vehicle: vehicle, button: "lock")
                    } else {
                        self.modelAction?.displayError(text: response.message ?? "异常")
                    }
                case let .failure(error):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        } else {
            TspApi.unlockVehicle() { (result: Result<TspResponse<NoReply>, Error>) in
                switch result {
                case .success(let response):
                    if(response.code == 0) {
                        var vehicle = mockVehicle()
                        vehicle.lockState = false
                        self.modelAction?.updateVehicle(vehicle: vehicle, button: "lock")
                    } else {
                        self.modelAction?.displayError(text: response.message ?? "异常")
                    }
                case let .failure(error):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    func onTapSetWindow(percent: Int) {
        modelAction?.buttonLoading(button: "window")
        if BluetoothManager.shared.isConnected() {
            BluetoothApi.setWindow(percent: percent) { (result: Result<BluetoothResponse<NoReply>, Error>) in
                switch result {
                case .success(let response):
                    if(response.code == 0) {
                        var vehicle = mockVehicle()
                        vehicle.windowPercentage = percent
                        self.modelAction?.updateVehicle(vehicle: vehicle, button: "window")
                    } else {
                        self.modelAction?.displayError(text: response.message ?? "异常")
                    }
                case let .failure(error):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        } else {
            TspApi.setWindow(percent: percent) { (result: Result<TspResponse<NoReply>, Error>) in
                switch result {
                case .success(let response):
                    if(response.code == 0) {
                        var vehicle = mockVehicle()
                        vehicle.windowPercentage = percent
                        self.modelAction?.updateVehicle(vehicle: vehicle, button: "window")
                    } else {
                        self.modelAction?.displayError(text: response.message ?? "异常")
                    }
                case let .failure(error):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    func onTapSetTrunk(percent: Int) {
        modelAction?.buttonLoading(button: "trunk")
        if BluetoothManager.shared.isConnected() {
            BluetoothApi.setTrunk(percent: percent) { (result: Result<BluetoothResponse<NoReply>, Error>) in
                switch result {
                case .success(let response):
                    if(response.code == 0) {
                        var vehicle = mockVehicle()
                        vehicle.trunkPercentage = percent
                        self.modelAction?.updateVehicle(vehicle: vehicle, button: "trunk")
                    } else {
                        self.modelAction?.displayError(text: response.message ?? "异常")
                    }
                case let .failure(error):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        } else {
            TspApi.setTrunk(percent: percent) { (result: Result<TspResponse<NoReply>, Error>) in
                switch result {
                case .success(let response):
                    if(response.code == 0) {
                        var vehicle = mockVehicle()
                        vehicle.trunkPercentage = percent
                        self.modelAction?.updateVehicle(vehicle: vehicle, button: "trunk")
                    } else {
                        self.modelAction?.displayError(text: response.message ?? "异常")
                    }
                case let .failure(error):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    func onTapFind() {
        modelAction?.buttonLoading(button: "find")
        if BluetoothManager.shared.isConnected() {
            BluetoothApi.findVehicle() { (result: Result<BluetoothResponse<NoReply>, Error>) in
                switch result {
                case .success(let response):
                    if(response.code == 0) {
                        let vehicle = mockVehicle()
                        self.modelAction?.updateVehicle(vehicle: vehicle, button: "find")
                    } else {
                        self.modelAction?.displayError(text: response.message ?? "异常")
                    }
                case let .failure(error):
                    self.modelAction?.displayError(text: "请求异常")
                }
            }
        } else {
            TspApi.findVehicle(vin: "HWYZTEST000000001") { (result: Result<TspResponse<RemoteControlState>, Error>) in
                switch result {
                case .success(let response):
                    if(response.code == 0) {
                        if let cmdId = response.data?.cmdId as? String {
                            self.modelAction?.mappingCmdId(cmdId: cmdId, button: "find")
                            self.startGetFindVehicleState(cmdId: cmdId)
                        }
                    } else {
                        self.modelAction?.displayError(text: response.message ?? "异常", button: "find")
                    }
                case let .failure(error):
                    self.modelAction?.displayError(text: error.localizedDescription, button: "find")
                }
            }
        }
    }
    private func startGetFindVehicleState(cmdId: String) {
        let queue = DispatchQueue.global(qos: .background)
        queue.async {
            self.findVehicleTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
                self.getCmdState(cmdId: cmdId)
            }
            RunLoop.current.run()
        }
    }
    func stopGetFindVehicleState() {
        findVehicleTimer?.invalidate()
        findVehicleTimer = nil
    }
    private func getCmdState(cmdId: String) {
        TspApi.getCmdState(vin: "HWYZTEST000000001", cmdId: cmdId) { (result: Result<TspResponse<RemoteControlState>, Error>) in
            switch result {
            case .success(let response):
                if response.code == 0 {
                    let cmdId = response.data?.cmdId
                    let button: String = (self.modelAction?.getCmdIdMapping(cmdId: cmdId!)!)!
                    let cmdState = response.data?.cmdState
                    if(cmdState == "EXECUTING") {
                        self.modelAction?.buttonExecuting(button: button)
                    }
                    if(cmdState == "SUCCESS") {
                        self.stopGetFindVehicleState()
                        self.modelAction?.displayInfo(text: "执行成功", button: button)
                    }
                    if(cmdState == "FAILURE") {
                        self.stopGetFindVehicleState()
                        self.modelAction?.displayError(text: "执行失败", button: button)
                    }
                    DispatchQueue.main.async {
                        
                    }
                } else {
                    // Handle error
                    print("Error polling find vehicle status: \(response.message ?? "Unknown error")")
                }
            case .failure(let error):
                // Handle network error
                print("Network error while polling find vehicle status: \(error.localizedDescription)")
            }
        }
    }
}
