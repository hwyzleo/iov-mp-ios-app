//
//  VehicleService.swift
//  iov
//
//  Created by Gemini on 2026/3/14.
//

import Foundation

/// 车辆业务服务协议
protocol VehicleServiceProtocol {
    func getVehicleIndex(completion: @escaping (Result<TspResponse<VehicleIndex>, Error>) -> Void)
    func lockVehicle(completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void)
}

/// 真实的 TSP API 实现
class RealVehicleService: VehicleServiceProtocol {
    func getVehicleIndex(completion: @escaping (Result<TspResponse<VehicleIndex>, Error>) -> Void) {
        TspApi.getVehicleIndex(completion: completion)
    }
    
    func lockVehicle(completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        TspApi.lockVehicle(completion: completion)
    }
}

/// Mock 数据实现
class MockVehicleService: VehicleServiceProtocol {
    func getVehicleIndex(completion: @escaping (Result<TspResponse<VehicleIndex>, Error>) -> Void) {
        // 模拟网络延迟
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let mockData = mockVehicleIndex()
            let response = TspResponse(code: "000000", message: "Success", ts: Int64(Date().timeIntervalSince1970 * 1000), data: mockData, traceId: nil, timestamp: Int64(Date().timeIntervalSince1970 * 1000))
            DispatchQueue.main.async {
                completion(.success(response))
            }
        }
    }
    
    func lockVehicle(completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let response = TspResponse<NoReply>(code: "000000", message: "Success", ts: Int64(Date().timeIntervalSince1970 * 1000), data: nil, traceId: nil, timestamp: Int64(Date().timeIntervalSince1970 * 1000))
            DispatchQueue.main.async {
                completion(.success(response))
            }
        }
    }
}
