//
//  VehicleIntent.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

class MarketingIndexIntent: MviIntentProtocol {
    private weak var modelAction: MarketingIndexModelActionProtocol?
    private weak var modelRouter: MarketingIndexModelRouterProtocol?
    
    init(model: MarketingIndexModelActionProtocol & MarketingIndexModelRouterProtocol) {
        self.modelAction = model
        self.modelRouter = model
    }
    
    func viewOnAppear() {
        modelAction?.displayLoading()
        if UserManager.isLogin() {
            fetchMyVehicleListFirst()
        } else {
            fetchSaleModelList()
        }
    }
    
    private func fetchMyVehicleListFirst() {
        ServiceContainer.marketingService.getMyVehicleList { [weak self] (result: Result<TspResponse<[MyVehicleVo]>, Error>) in
            switch result {
            case .success(let res):
                if res.isSuccess {
                    guard let resData = res.data else {
                        self?.modelAction?.displayError(text: "数据异常")
                        return
                    }
                    VehicleManager.shared.update(myVehicleList: resData)
                    
                    if resData.isEmpty {
                        self?.fetchSaleModelList()
                        return
                    }
                    
                    if let vehicle = resData.first {
                        self?.modelAction?.displayMyVehicle(vehicle: vehicle)
                    } else {
                        self?.fetchSaleModelList()
                    }
                } else {
                    self?.modelAction?.displayError(text: res.message ?? "请求异常")
                }
            case .failure(_):
                self?.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    
    private func fetchSaleModelList() {
        ServiceContainer.marketingService.getSaleModelList { [weak self] result in
            switch result {
            case .success(let res):
                if res.isSuccess, let saleModelList = res.data, !saleModelList.isEmpty {
                    self?.modelAction?.displaySaleModelList(saleModelList: saleModelList)
                    self?.modelAction?.displayNoOrder()
                } else {
                    self?.modelAction?.displayError(text: "获取车型列表失败")
                }
            case .failure(_):
                self?.modelAction?.displayError(text: "请求异常")
            }
        }
    }
}

extension MarketingIndexIntent: MarketingIndexIntentProtocol {
    func onTapSelectSaleModel(index: Int) {
        modelAction?.selectSaleModel(index: index)
    }
    
    func onTapModelConfig() {
        if UserManager.isLogin() {
            guard let saleModel = modelAction?.getCurrentSaleModel() else { return }
            AppGlobalState.shared.parameters["saleModelCode"] = saleModel.saleModelCode
            AppRouter.shared.push(.marketing(.modelVariantSelection(saleModelCode: saleModel.saleModelCode)))
        } else {
            AppRouter.shared.push(.login)
        }
    }
    func onTapOrder() {
        guard let wishlistId = VehicleManager.shared.getCurrentVehicleId() else { return }
        ServiceContainer.marketingService.getWishlist(wishlistId: wishlistId) { [weak self] (result: Result<TspResponse<Wishlist>, Error>) in
            switch result {
            case .success(let res):
                guard let wishlist = res.data else {
                    self?.modelAction?.displayError(text: res.message ?? "请求异常")
                    return
                }
                
                // 由于新结构不再有saleModelConfigs，需要根据optionCodes来处理
                // 这里暂时使用空字典，因为新结构没有familyCode到featureCode的映射
                let featureCodes: [String: String] = [:]
                
                AppGlobalState.shared.parameters["saleModelCode"] = wishlist.saleModelCode
                AppGlobalState.shared.parameters["saleModelConfigType"] = featureCodes
                AppGlobalState.shared.parameters["orderDetailView"] = "ORDER"
                AppGlobalState.shared.parameters["lastView"] = "MARKETING_INDEX"
                DispatchQueue.main.async {
                    AppRouter.shared.push(.marketing(.orderDetail(orderNo: "")))
                }
            case .failure(_):
                self?.modelAction?.displayError(text: "请求异常")
            }
        }
    }
    

    func onTapWishlistDetail() {
        let wishlistId = VehicleManager.shared.getCurrentVehicleId()
        print("🔍 onTapWishlistDetail() - wishlistId: \(wishlistId ?? "nil")")
        AppGlobalState.shared.parameters["orderDetailView"] = "WISHLIST"
        AppRouter.shared.push(.marketing(.orderDetail(orderNo: wishlistId ?? "")))
    }
    func onTapOrderDetail(orderState: OrderState) {
        switch orderState {
        case .WISHLIST:
            break
        case .EARNEST_MONEY_UNPAID:
            AppGlobalState.shared.parameters["orderDetailView"] = "EARNEST_MONEY_UNPAID"
        case .EARNEST_MONEY_PAID:
            AppGlobalState.shared.parameters["orderDetailView"] = "EARNEST_MONEY_PAID"
        case .DOWN_PAYMENT_UNPAID:
            AppGlobalState.shared.parameters["orderDetailView"] = "DOWN_PAYMENT_UNPAID"
        case .DOWN_PAYMENT_PAID:
            AppGlobalState.shared.parameters["orderDetailView"] = "DOWN_PAYMENT_PAID"
        case .ARRANGE_PRODUCTION:
            AppGlobalState.shared.parameters["orderDetailView"] = "ARRANGE_PRODUCTION"
        case .ALLOCATION_VEHICLE, .SHIPPING_APPLY:
            AppGlobalState.shared.parameters["orderDetailView"] = "ALLOCATION_VEHICLE"
        case .PREPARE_TRANSPORT, .TRANSPORTING:
            AppGlobalState.shared.parameters["orderDetailView"] = "PREPARE_TRANSPORT"
        case .PREPARE_DELIVER:
            AppGlobalState.shared.parameters["orderDetailView"] = "PREPARE_DELIVER"
        case .FINAL_PAYMENT_PAID:
            AppGlobalState.shared.parameters["orderDetailView"] = "FINAL_PAYMENT_PAID"
        case .INVOICED:
            AppGlobalState.shared.parameters["orderDetailView"] = "INVOICED"
        case .DELIVERED:
            AppGlobalState.shared.parameters["orderDetailView"] = "DELIVERED"
        case .ACTIVATED:
            break
        }
        AppRouter.shared.push(.marketing(.orderDetail(orderNo: "")))
    }
    func onTapPayOrder(orderPaymentPhase: Int, paymentAmount: Decimal, paymentChannel: String) {
        if let orderNo = VehicleManager.shared.getCurrentVehicleId() {
            modelAction?.displayLoading()
            ServiceContainer.marketingService.payOrder(orderNo: orderNo, orderPaymentPhase: orderPaymentPhase, paymentAmount: paymentAmount, paymentChannel: paymentChannel) { [weak self] (result: Result<TspResponse<OrderPaymentResponse>, Error>) in
                switch result {
                case .success(let res):
                    if res.isSuccess {
                        // 根据支付阶段更新本地状态码
                        let nextSubState: Int
                        if orderPaymentPhase == 1 {
                            nextSubState = 210 // 意向金已支付
                        } else if orderPaymentPhase == 2 {
                            nextSubState = 310 // 定金已支付
                        } else {
                            nextSubState = 700 // 其他（如尾款）支付后视为激活/完成
                        }
                        
                        // 更新本地存储
                        VehicleManager.shared.updateSubState(id: orderNo, subState: nextSubState)
                        
                        // 如果原来是心愿单，支付后应变为订单类型
                        if let vehicle = VehicleManager.shared.getCurrentVehicle(), vehicle.type == .WISHLIST {
                            VehicleManager.shared.add(orderNum: orderNo, type: .ORDER, subState: nextSubState, displayName: vehicle.displayName)
                        }
                        
                        if orderPaymentPhase == 3 {
                            AppGlobalState.shared.needRefresh = true
                        }
                        self?.viewOnAppear()
                    } else {
                        self?.modelAction?.displayError(text: res.message ?? "请求异常")
                    }
                case .failure(_):
                    self?.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    func onTapCancelOrder() {
        if let orderNo = VehicleManager.shared.getCurrentVehicleId() {
            modelAction?.displayLoading()
            ServiceContainer.marketingService.cancelOrder(orderNo: orderNo) { [weak self] (result: Result<TspResponse<NoReply>, Error>) in
                switch result {
                case .success(let res):
                    if res.isSuccess {
                        VehicleManager.shared.delete(orderNum: orderNo)
                        self?.viewOnAppear()
                    } else {
                        self?.modelAction?.displayError(text: res.message ?? "请求异常")
                    }
                case .failure(_):
                    self?.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    func onTapEarnestMoneyToDownPayment() {
        if let orderNo = VehicleManager.shared.getCurrentVehicleId() {
            modelAction?.displayLoading()
            let parameters: [String: Any] = ["orderNo": orderNo]
            ServiceContainer.marketingService.earnestMoneyToDownPayment(parameters: parameters) { [weak self] (result: Result<TspResponse<NoReply>, Error>) in
                switch result {
                case .success(_):
                    self?.viewOnAppear()
                case .failure(_):
                    self?.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
    func onTapLockOrder() {
        if let orderNo = VehicleManager.shared.getCurrentVehicleId() {
            modelAction?.displayLoading()
            ServiceContainer.marketingService.lockOrder(orderNo: orderNo) { [weak self] (result: Result<TspResponse<NoReply>, Error>) in
                switch result {
                case .success(let res):
                    if res.isSuccess {
                        // 更新本地状态为：安排生产
                        VehicleManager.shared.updateSubState(id: orderNo, subState: 400)
                        self?.viewOnAppear()
                    } else {
                        self?.modelAction?.displayError(text: res.message ?? "请求异常")
                    }
                case .failure(_):
                    self?.modelAction?.displayError(text: "请求异常")
                }
            }
        }
    }
}
