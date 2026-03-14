//
//  MarketingService.swift
//  iov
//
//  Created by Gemini on 2026/3/14.
//

import Foundation

/// 购车营销业务服务协议
protocol MarketingServiceProtocol {
    func getValidVehicleSaleOrderList(completion: @escaping (Result<TspResponse<[VehicleSaleOrder]>, Error>) -> Void)
    func getWishlist(orderNum: String, completion: @escaping (Result<TspResponse<Wishlist>, Error>) -> Void)
}

/// 真实的 TSP API 实现
class RealMarketingService: MarketingServiceProtocol {
    func getValidVehicleSaleOrderList(completion: @escaping (Result<TspResponse<[VehicleSaleOrder]>, Error>) -> Void) {
        TspApi.getValidVehicleSaleOrderList(completion: completion)
    }
    
    func getWishlist(orderNum: String, completion: @escaping (Result<TspResponse<Wishlist>, Error>) -> Void) {
        TspApi.getWishlist(orderNum: orderNum, completion: completion)
    }
}

/// Mock 数据实现
class MockMarketingService: MarketingServiceProtocol {
    func getValidVehicleSaleOrderList(completion: @escaping (Result<TspResponse<[VehicleSaleOrder]>, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let mockData = mockVehicleSaleOrderList()
            let response = TspResponse(code: 0, message: "Success", ts: Int64(Date().timeIntervalSince1970 * 1000), data: mockData)
            DispatchQueue.main.async {
                completion(.success(response))
            }
        }
    }
    
    func getWishlist(orderNum: String, completion: @escaping (Result<TspResponse<Wishlist>, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let mockData = mockWishlist()
            let response = TspResponse(code: 0, message: "Success", ts: Int64(Date().timeIntervalSince1970 * 1000), data: mockData)
            DispatchQueue.main.async {
                completion(.success(response))
            }
        }
    }
}
