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
        if AppGlobalState.shared.isLogin {
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
        if AppGlobalState.shared.isLogin {
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
                
                // 从 optionDetails 重建 saleModelConfigType 字典
                var featureCodes: [String: String] = [:]
                if let optionDetails = wishlist.optionDetails {
                    for option in optionDetails {
                        featureCodes[option.optionFamilyCode] = option.optionCode
                    }
                }
                
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
        case .DELIVERED, .COMPLETED:
            AppGlobalState.shared.parameters["orderDetailView"] = "DELIVERED"
        case .EXPIRED, .CANCEL, .CLOSED:
            // 终态：进入只读失效视图（可重新支付），不再进入待支付页
            AppGlobalState.shared.parameters["orderDetailView"] = "INVALID"
        }
        AppRouter.shared.push(.marketing(.orderDetail(orderNo: "")))
    }
    func onTapPayOrder(orderPaymentPhase: Int, paymentAmount: Decimal, paymentChannel: String) {
        guard let orderNo = VehicleManager.shared.getCurrentVehicleId() else { return }
        modelAction?.displayLoading()

        // 后端仅支持意向金/定金两个支付阶段；尾款走详情页入口（OTD-VSO-DSN-CR-014），
        // 不再做任何本地状态推进（OTD-VSO-DSN-CR-016 已删除 700 激活态）
        guard orderPaymentPhase == 1 || orderPaymentPhase == 2 else {
            return
        }

        let stage: PaymentStageValue = orderPaymentPhase == 1 ? .earnestMoney : .downPayment
        PaymentFlowService.shared.pay(orderNo: orderNo, stage: stage, paymentChannel: paymentChannel) { [weak self] result in
            switch result {
            case .success:
                let nextSubState = orderPaymentPhase == 1 ? 210 : 310
                VehicleManager.shared.updateSubState(id: orderNo, subState: nextSubState)
                if let vehicle = VehicleManager.shared.getCurrentVehicle(), vehicle.type == .WISHLIST {
                    VehicleManager.shared.add(orderNum: orderNo, type: .ORDER, subState: nextSubState, displayName: vehicle.displayName)
                }
                AppGlobalState.shared.needRefresh = true
                self?.viewOnAppear()
            case .failure(let error):
                self?.modelAction?.displayError(text: error.localizedDescription)
            }
        }
    }
    /// 重新发起支付（订单已失效，OTD-VSO-DSN-CR-005）
    /// 先调用云端恢复接口，成功后按意向金阶段发起支付
    func onTapReopenPayment() {
        guard let orderNo = VehicleManager.shared.getCurrentVehicleId() else { return }
        modelAction?.displayLoading()
        PaymentFlowService.shared.reopenPayment(orderNo: orderNo) { [weak self] result in
            switch result {
            case .success(let reopened):
                AppGlobalState.shared.parameters["reopenCount"] = reopened.reopenCount
                self?.onTapPayOrder(orderPaymentPhase: 1, paymentAmount: 0, paymentChannel: "ALIPAY")
            case .failure(let error):
                self?.viewOnAppear()
                self?.modelAction?.displayError(text: error.localizedDescription)
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
            ServiceContainer.marketingService.earnestMoneyToDownPayment(parameters: parameters) { [weak self] (result: Result<TspResponse<EarnestToDownResponse>, Error>) in
                switch result {
                case .success(let res):
                    if res.isSuccess {
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
