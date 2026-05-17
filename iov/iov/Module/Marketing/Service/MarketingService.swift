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
    func getSelectedSaleModel(saleModelCode: String, orderNo: String?, saleModelConfigType: [String: String], completion: @escaping (Result<TspResponse<SelectedSaleModel>, Error>) -> Void)
    func getOrder(orderNo: String, completion: @escaping (Result<TspResponse<Order>, Error>) -> Void)
    func deleteWishlist(wishlistId: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void)
    func earnestMoneyOrder(saleModelCode: String, orderNo: String?, saleModelConfigType: [String: String], licenseCityCode: String, completion: @escaping (Result<TspResponse<EarnestMoneyOrderResult>, Error>) -> Void)
    func initiatePayment(orderNo: String, paymentChannel: String, completion: @escaping (Result<TspResponse<InitiatePaymentResult>, Error>) -> Void)
    func paymentCallback(paymentNo: String, externalTradeNo: String, paymentStage: String, paymentAmount: Decimal, paymentStatus: String, payTime: Date, idempotentKey: String?, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void)
    func downPaymentOrder(saleModelCode: String, orderNo: String, saleModelConfigType: [String: String], customerType: String, paymentMethod: String, orderPersonType: Int, purchasePlan: Int, orderPersonName: String, orderPersonIdType: Int, orderPersonIdNum: String, licenseCityCode: String, orderStoreCode: String, deliveryStoreCode: String, completion: @escaping (Result<TspResponse<DownPaymentOrderResult>, Error>) -> Void)
    func cancelOrder(orderNo: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void)
    func payOrder(orderNo: String, orderPaymentPhase: Int, paymentAmount: Decimal, paymentChannel: String, completion: @escaping (Result<TspResponse<OrderPaymentResponse>, Error>) -> Void)
    func earnestMoneyToDownPayment(parameters: [String: Any], completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void)
    func lockOrder(orderNo: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void)
    func getSaleModelList(completion: @escaping (Result<TspResponse<[SaleModelMp]>, Error>) -> Void)
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
    
    func getSelectedSaleModel(saleModelCode: String, orderNo: String?, saleModelConfigType: [String: String], completion: @escaping (Result<TspResponse<SelectedSaleModel>, Error>) -> Void) {
        TspApi.getSelectedSaleModel(saleModelCode: saleModelCode, orderNo: orderNo, saleModelConfigType: saleModelConfigType, completion: completion)
    }
    
    func getOrder(orderNo: String, completion: @escaping (Result<TspResponse<Order>, Error>) -> Void) {
        TspApi.getOrder(orderNo: orderNo, completion: completion)
    }
    
    func deleteWishlist(wishlistId: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        TspApi.deleteWishlist(wishlistId: wishlistId, completion: completion)
    }
    
    func earnestMoneyOrder(saleModelCode: String, orderNo: String?, saleModelConfigType: [String: String], licenseCityCode: String, completion: @escaping (Result<TspResponse<EarnestMoneyOrderResult>, Error>) -> Void) {
        TspApi.earnestMoneyOrder(
            saleModelCode: saleModelCode,
            orderNo: orderNo,
            saleModelConfigType: saleModelConfigType,
            licenseCityCode: licenseCityCode,
            completion: completion
        )
    }

    func initiatePayment(orderNo: String, paymentChannel: String, completion: @escaping (Result<TspResponse<InitiatePaymentResult>, Error>) -> Void) {
        TspApi.initiatePayment(orderNo: orderNo, paymentChannel: paymentChannel, completion: completion)
    }

    func paymentCallback(paymentNo: String, externalTradeNo: String, paymentStage: String, paymentAmount: Decimal, paymentStatus: String, payTime: Date, idempotentKey: String?, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        TspApi.paymentCallback(paymentNo: paymentNo, externalTradeNo: externalTradeNo, paymentStage: paymentStage, paymentAmount: paymentAmount, paymentStatus: paymentStatus, payTime: payTime, idempotentKey: idempotentKey, completion: completion)
    }
    
    func downPaymentOrder(saleModelCode: String, orderNo: String, saleModelConfigType: [String: String], customerType: String, paymentMethod: String, orderPersonType: Int, purchasePlan: Int, orderPersonName: String, orderPersonIdType: Int, orderPersonIdNum: String, licenseCityCode: String, orderStoreCode: String, deliveryStoreCode: String, completion: @escaping (Result<TspResponse<DownPaymentOrderResult>, Error>) -> Void) {
        TspApi.downPaymentOrder(
            saleModelCode: saleModelCode,
            orderNo: orderNo,
            saleModelConfigType: saleModelConfigType,
            customerType: customerType,
            paymentMethod: paymentMethod,
            orderPersonType: orderPersonType,
            purchasePlan: purchasePlan,
            orderPersonName: orderPersonName,
            orderPersonIdType: orderPersonIdType,
            orderPersonIdNum: orderPersonIdNum,
            licenseCityCode: licenseCityCode,
            orderStoreCode: orderStoreCode,
            deliveryStoreCode: deliveryStoreCode,
            completion: completion
        )
    }
    
    func cancelOrder(orderNo: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        TspApi.cancelOrder(orderNo: orderNo, completion: completion)
    }
    
    func payOrder(orderNo: String, orderPaymentPhase: Int, paymentAmount: Decimal, paymentChannel: String, completion: @escaping (Result<TspResponse<OrderPaymentResponse>, Error>) -> Void) {
        TspApi.payOrder(orderNo: orderNo, orderPaymentPhase: orderPaymentPhase, paymentAmount: paymentAmount, paymentChannel: paymentChannel, completion: completion)
    }
    
    func earnestMoneyToDownPayment(parameters: [String: Any], completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        TspApi.earnestMoneyToDownPayment(parameters: parameters, completion: completion)
    }
    
    func lockOrder(orderNo: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        TspApi.lockOrder(orderNo: orderNo, completion: completion)
    }
    
    func getSaleModelList(completion: @escaping (Result<TspResponse<[SaleModelMp]>, Error>) -> Void) {
        TspApi.getSaleModelList(completion: completion)
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
                        saleModelImages: nil,
                        totalPrice: nil,
                        saleModelDesc: nil
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

    func getSelectedSaleModel(saleModelCode: String, orderNo: String?, saleModelConfigType: [String: String], completion: @escaping (Result<TspResponse<SelectedSaleModel>, Error>) -> Void) {
        mockDelayedSuccess(data: mockSelectedSaleModel(), completion: completion)
    }

    func getOrder(orderNo: String, completion: @escaping (Result<TspResponse<Order>, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            var orderData = mockOrder()
            // 同步本地存储的状态
            if let vehicle = VehicleManager.shared.getVehiclesForMock()[orderNo] {
                orderData.orderNo = orderNo
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

    func earnestMoneyOrder(saleModelCode: String, orderNo: String?, saleModelConfigType: [String: String], licenseCityCode: String, completion: @escaping (Result<TspResponse<EarnestMoneyOrderResult>, Error>) -> Void) {
        let mockResult = EarnestMoneyOrderResult(
            orderNo: "MOCK_ORDER_001",
            earnestMoneyAmount: 5000,
            paymentChannels: [
                PaymentChannelInfo(channelCode: "WECHAT", channelName: "微信支付", isDefault: true),
                PaymentChannelInfo(channelCode: "ALIPAY", channelName: "支付宝", isDefault: false),
                PaymentChannelInfo(channelCode: "UNION_PAY", channelName: "银联支付", isDefault: false)
            ],
            expireTime: Date().addingTimeInterval(900)
        )
        mockDelayedSuccess(data: mockResult, completion: completion)
    }

    func initiatePayment(orderNo: String, paymentChannel: String, completion: @escaping (Result<TspResponse<InitiatePaymentResult>, Error>) -> Void) {
        let mockResult = InitiatePaymentResult(
            paymentNo: "MOCK_PAYMENT_001",
            paymentChannel: paymentChannel,
            paymentAmount: 5000,
            paymentMerchant: "MOCK_MERCHANT",
            paymentReference: "MOCK_REF_001"
        )
        mockDelayedSuccess(data: mockResult, completion: completion)
    }

    func paymentCallback(paymentNo: String, externalTradeNo: String, paymentStage: String, paymentAmount: Decimal, paymentStatus: String, payTime: Date, idempotentKey: String?, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        mockDelayedSuccess(data: nil, completion: completion)
    }

    func downPaymentOrder(saleModelCode: String, orderNo: String, saleModelConfigType: [String: String], customerType: String, paymentMethod: String, orderPersonType: Int, purchasePlan: Int, orderPersonName: String, orderPersonIdType: Int, orderPersonIdNum: String, licenseCityCode: String, orderStoreCode: String, deliveryStoreCode: String, completion: @escaping (Result<TspResponse<DownPaymentOrderResult>, Error>) -> Void) {
        let mockResult = DownPaymentOrderResult(
            orderNo: "MOCK_ORDER_NUM",
            downPaymentAmount: 5000,
            paymentChannels: [
                PaymentChannelInfo(channelCode: "WECHAT", channelName: "微信支付", isDefault: true),
                PaymentChannelInfo(channelCode: "ALIPAY", channelName: "支付宝", isDefault: false)
            ],
            expireTime: Date().addingTimeInterval(900)
        )
        mockDelayedSuccess(data: mockResult, completion: completion)
    }

    func cancelOrder(orderNo: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        mockDelayedSuccess(data: nil, completion: completion)
    }

    func payOrder(orderNo: String, orderPaymentPhase: Int, paymentAmount: Decimal, paymentChannel: String, completion: @escaping (Result<TspResponse<OrderPaymentResponse>, Error>) -> Void) {
        mockDelayedSuccess(data: mockOrderPaymentResponse(), completion: completion)
    }

    func earnestMoneyToDownPayment(parameters: [String: Any], completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        mockDelayedSuccess(data: nil, completion: completion)
    }

    func lockOrder(orderNo: String, completion: @escaping (Result<TspResponse<NoReply>, Error>) -> Void) {
        mockDelayedSuccess(data: nil, completion: completion)
    }

    func getSaleModelList(completion: @escaping (Result<TspResponse<[SaleModelMp]>, Error>) -> Void) {
        mockDelayedSuccess(data: mockSaleModelList(), completion: completion)
    }
}
