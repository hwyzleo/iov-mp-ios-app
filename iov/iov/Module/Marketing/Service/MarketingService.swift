//
//  MarketingService.swift
//  iov
//
//  Created by Gemini on 2026/3/14.
//

import Foundation

/// 购车营销业务服务协议
protocol MarketingServiceProtocol {
    func getMyVehicleList(completion: @escaping (Result<TspResponse<[MyVehicleVo]>, Error>) -> Void)
    func getValidVehicleSaleOrderList(completion: @escaping (Result<TspResponse<[VehicleSaleOrder]>, Error>) -> Void)
    func getWishlist(wishlistId: String, completion: @escaping (Result<TspResponse<Wishlist>, Error>) -> Void)
    func getLicenseArea(completion: @escaping (Result<TspResponse<[LicenseArea]>, Error>) -> Void)
    func getDealership(completion: @escaping (Result<TspResponse<[Dealership]>, Error>) -> Void)
    func getDeliveryCenter(completion: @escaping (Result<TspResponse<[Dealership]>, Error>) -> Void)
    func getSelectedSaleModel(saleCode: String, modelCode: String, exteriorCode: String, interiorCode: String, wheelCode: String, spareTireCode: String, adasCode: String, completion: @escaping (Result<TspResponse<SelectedSaleModel>, Error>) -> Void)
    func getOrder(orderNum: String, completion: @escaping (Result<TspResponse<Order>, Error>) -> Void)
    func deleteWishlist(wishlistId: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void)
    func earnestMoneyOrder(saleCode: String, orderNum: String?, modelCode: String, exteriorCode: String, interiorCode: String, wheelCode: String, spareTireCode: String, adasCode: String, licenseCityCode: String, completion: @escaping (Result<TspResponse<String>, Error>) -> Void)
    func downPaymentOrder(saleCode: String, orderNum: String, modelCode: String, exteriorCode: String, interiorCode: String, wheelCode: String, spareTireCode: String, adasCode: String, orderPersonType: Int, purchasePlan: Int, orderPersonName: String, orderPersonIdType: Int, orderPersonIdNum: String, licenseCityCode: String, dealership: String, deliveryCenter: String, completion: @escaping (Result<TspResponse<String>, Error>) -> Void)
    func cancelOrder(orderNum: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void)
    func payOrder(orderNum: String, orderPaymentPhase: Int, paymentAmount: Decimal, paymentChannel: String, completion: @escaping (Result<TspResponse<OrderPaymentResponse>, Error>) -> Void)
    func earnestMoneyToDownPayment(orderNum: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void)
    func lockOrder(orderNum: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void)
}

/// 真实的 TSP API 实现
class RealMarketingService: MarketingServiceProtocol {
    func getMyVehicleList(completion: @escaping (Result<TspResponse<[MyVehicleVo]>, Error>) -> Void) {
        TspApi.getMyVehicleList(completion: completion)
    }
    
    func getValidVehicleSaleOrderList(completion: @escaping (Result<TspResponse<[VehicleSaleOrder]>, Error>) -> Void) {
        TspApi.getValidVehicleSaleOrderList(completion: completion)
    }
    
    func getWishlist(wishlistId: String, completion: @escaping (Result<TspResponse<Wishlist>, Error>) -> Void) {
        TspApi.getWishlist(wishlistId: wishlistId, completion: completion)
    }
    
    func getLicenseArea(completion: @escaping (Result<TspResponse<[LicenseArea]>, Error>) -> Void) {
        TspApi.getLicenseArea(completion: completion)
    }
    
    func getDealership(completion: @escaping (Result<TspResponse<[Dealership]>, Error>) -> Void) {
        TspApi.getDealership(completion: completion)
    }
    
    func getDeliveryCenter(completion: @escaping (Result<TspResponse<[Dealership]>, Error>) -> Void) {
        TspApi.getDeliveryCenter(completion: completion)
    }
    
    func getSelectedSaleModel(saleCode: String, modelCode: String, exteriorCode: String, interiorCode: String, wheelCode: String, spareTireCode: String, adasCode: String, completion: @escaping (Result<TspResponse<SelectedSaleModel>, Error>) -> Void) {
        TspApi.getSelectedSaleModel(saleCode: saleCode, modelCode: modelCode, exteriorCode: exteriorCode, interiorCode: interiorCode, wheelCode: wheelCode, spareTireCode: spareTireCode, adasCode: adasCode, completion: completion)
    }
    
    func getOrder(orderNum: String, completion: @escaping (Result<TspResponse<Order>, Error>) -> Void) {
        TspApi.getOrder(orderNum: orderNum, completion: completion)
    }
    
    func deleteWishlist(wishlistId: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        TspApi.deleteWishlist(wishlistId: wishlistId, completion: completion)
    }
    
    func earnestMoneyOrder(saleCode: String, orderNum: String?, modelCode: String, exteriorCode: String, interiorCode: String, wheelCode: String, spareTireCode: String, adasCode: String, licenseCityCode: String, completion: @escaping (Result<TspResponse<String>, Error>) -> Void) {
        TspApi.earnestMoneyOrder(
            saleCode: saleCode,
            orderNum: orderNum,
            modelCode: modelCode,
            exteriorCode: exteriorCode,
            interiorCode: interiorCode,
            wheelCode: wheelCode,
            spareTireCode: spareTireCode,
            adasCode: adasCode,
            licenseCityCode: licenseCityCode,
            completion: completion
        )
    }
    
    func downPaymentOrder(saleCode: String, orderNum: String, modelCode: String, exteriorCode: String, interiorCode: String, wheelCode: String, spareTireCode: String, adasCode: String, orderPersonType: Int, purchasePlan: Int, orderPersonName: String, orderPersonIdType: Int, orderPersonIdNum: String, licenseCityCode: String, dealership: String, deliveryCenter: String, completion: @escaping (Result<TspResponse<String>, Error>) -> Void) {
        TspApi.downPaymentOrder(
            saleCode: saleCode,
            orderNum: orderNum,
            modelCode: modelCode,
            exteriorCode: exteriorCode,
            interiorCode: interiorCode,
            wheelCode: wheelCode,
            spareTireCode: spareTireCode,
            adasCode: adasCode,
            orderPersonType: orderPersonType,
            purchasePlan: purchasePlan,
            orderPersonName: orderPersonName,
            orderPersonIdType: orderPersonIdType,
            orderPersonIdNum: orderPersonIdNum,
            licenseCityCode: licenseCityCode,
            dealership: dealership,
            deliveryCenter: deliveryCenter,
            completion: completion
        )
    }
    
    func cancelOrder(orderNum: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        TspApi.cancelOrder(orderNum: orderNum, completion: completion)
    }
    
    func payOrder(orderNum: String, orderPaymentPhase: Int, paymentAmount: Decimal, paymentChannel: String, completion: @escaping (Result<TspResponse<OrderPaymentResponse>, Error>) -> Void) {
        TspApi.payOrder(orderNum: orderNum, orderPaymentPhase: orderPaymentPhase, paymentAmount: paymentAmount, paymentChannel: paymentChannel, completion: completion)
    }
    
    func earnestMoneyToDownPayment(orderNum: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        TspApi.earnestMoneyToDownPayment(orderNum: orderNum, completion: completion)
    }
    
    func lockOrder(orderNum: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        TspApi.lockOrder(orderNum: orderNum, completion: completion)
    }
}

/// Mock 数据实现
class MockMarketingService: MarketingServiceProtocol {
    private func createMockResponse<T>(data: T?) -> TspResponse<T> {
        return TspResponse(code: "000000", message: "Success", ts: Int64(Date().timeIntervalSince1970 * 1000), data: data)
    }

    private func mockDelayedSuccess<T>(data: T?, completion: @escaping (Result<TspResponse<T>, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let response = self.createMockResponse(data: data)
            DispatchQueue.main.async {
                completion(.success(response))
            }
        }
    }

    func getValidVehicleSaleOrderList(completion: @escaping (Result<TspResponse<[VehicleSaleOrder]>, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let vehicles = VehicleManager.shared.getVehiclesForMock()
            var orderList: [VehicleSaleOrder] = []
            
            if vehicles.isEmpty {
                orderList = mockVehicleSaleOrderList()
            } else {
                for (id, po) in vehicles {
                    orderList.append(VehicleSaleOrder(orderNum: id, orderState: po.subState, displayName: po.displayName))
                }
            }
            
            let response = self.createMockResponse(data: orderList)
            DispatchQueue.main.async {
                completion(.success(response))
            }
        }
    }
    
func getMyVehicleList(completion: @escaping (Result<TspResponse<[MyVehicleVo]>, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            let vehicles = VehicleManager.shared.getVehiclesForMock()
            var myVehicleList: [MyVehicleVo] = []
            
            if vehicles.isEmpty {
                myVehicleList = []
            } else {
                for (id, po) in vehicles {
                    let typeStr: String
                    switch po.type {
                    case .WISHLIST: typeStr = "WISHLIST"
                    case .ORDER: typeStr = "ORDER"
                    case .ACTIVATED: typeStr = "ACTIVATED"
                    }
                    myVehicleList.append(MyVehicleVo(
                        id: id,
                        type: typeStr,
                        displayName: po.displayName,
                        state: po.subState,
                        createTime: nil,
                        modifyTime: nil,
                        saleCode: nil,
                        buildConfigCode: nil,
                        saleModelImages: nil,
                        totalPrice: nil,
                        isValid: nil
                    ))
                }
            }
            
            let response = self.createMockResponse(data: myVehicleList)
            DispatchQueue.main.async {
                completion(.success(response))
            }
        })
    }
    
    func getWishlist(wishlistId: String, completion: @escaping (Result<TspResponse<Wishlist>, Error>) -> Void) {
        mockDelayedSuccess(data: mockWishlist(), completion: completion)
    }

    func getLicenseArea(completion: @escaping (Result<TspResponse<[LicenseArea]>, Error>) -> Void) {
        mockDelayedSuccess(data: mockLicenseArea(), completion: completion)
    }

    func getDealership(completion: @escaping (Result<TspResponse<[Dealership]>, Error>) -> Void) {
        mockDelayedSuccess(data: mockDealership(), completion: completion)
    }

    func getDeliveryCenter(completion: @escaping (Result<TspResponse<[Dealership]>, Error>) -> Void) {
        mockDelayedSuccess(data: mockDeliveryCenter(), completion: completion)
    }

    func getSelectedSaleModel(saleCode: String, modelCode: String, exteriorCode: String, interiorCode: String, wheelCode: String, spareTireCode: String, adasCode: String, completion: @escaping (Result<TspResponse<SelectedSaleModel>, Error>) -> Void) {
        mockDelayedSuccess(data: mockSelectedSaleModel(), completion: completion)
    }

    func getOrder(orderNum: String, completion: @escaping (Result<TspResponse<Order>, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            var orderData = mockOrder()
            // 同步本地存储的状态
            if let vehicle = VehicleManager.shared.getVehiclesForMock()[orderNum] {
                orderData.orderNum = orderNum
                orderData.orderState = vehicle.subState
            }
            let response = self.createMockResponse(data: orderData)
            DispatchQueue.main.async {
                completion(.success(response))
            }
        }
    }

    func deleteWishlist(wishlistId: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        mockDelayedSuccess(data: nil, completion: completion)
    }

    func earnestMoneyOrder(saleCode: String, orderNum: String?, modelCode: String, exteriorCode: String, interiorCode: String, wheelCode: String, spareTireCode: String, adasCode: String, licenseCityCode: String, completion: @escaping (Result<TspResponse<String>, Error>) -> Void) {
        mockDelayedSuccess(data: "MOCK_ORDER_NUM", completion: completion)
    }

    func downPaymentOrder(saleCode: String, orderNum: String, modelCode: String, exteriorCode: String, interiorCode: String, wheelCode: String, spareTireCode: String, adasCode: String, orderPersonType: Int, purchasePlan: Int, orderPersonName: String, orderPersonIdType: Int, orderPersonIdNum: String, licenseCityCode: String, dealership: String, deliveryCenter: String, completion: @escaping (Result<TspResponse<String>, Error>) -> Void) {
        mockDelayedSuccess(data: "MOCK_ORDER_NUM", completion: completion)
    }

    func cancelOrder(orderNum: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        mockDelayedSuccess(data: nil, completion: completion)
    }

    func payOrder(orderNum: String, orderPaymentPhase: Int, paymentAmount: Decimal, paymentChannel: String, completion: @escaping (Result<TspResponse<OrderPaymentResponse>, Error>) -> Void) {
        mockDelayedSuccess(data: mockOrderPaymentResponse(), completion: completion)
    }

    func earnestMoneyToDownPayment(orderNum: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        mockDelayedSuccess(data: nil, completion: completion)
    }

    func lockOrder(orderNum: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        mockDelayedSuccess(data: nil, completion: completion)
    }
}
