//
//  PaymentContractTests.swift
//  iovTests
//
//  IOS-APP-DSN-CR-002
//  注：客户端伪造网关回调的 MockPaymentGateway 已下线（IOS-APP-DSN-CR-007），
//  mock 支付终态改由服务端扮演渠道自回调驱动，故此处不再校验客户端签名。
//

import XCTest
@testable import iov

final class PaymentContractTests: XCTestCase {

    // MARK: - 发起支付响应

    func testInitiatePaymentResultDecodesNewContractFields() throws {
        let json = """
        {
          "paymentNo": "P1",
          "paymentChannel": "WECHAT",
          "paymentAmount": 5000,
          "paymentStatus": "PROCESSING",
          "externalTradeNo": "MOCK-P1",
          "expireTime": 1700000000000
        }
        """.data(using: .utf8)!

        let result = try JSONDecoder().decode(InitiatePaymentResult.self, from: json)
        XCTAssertEqual(result.paymentNo, "P1")
        XCTAssertEqual(result.paymentStatus, "PROCESSING")
        XCTAssertEqual(result.externalTradeNo, "MOCK-P1")
        XCTAssertEqual(result.expireTime, 1700000000000)
    }

    func testPaymentRecordDecodesEpochMillis() throws {
        let json = """
        {
          "paymentNo": "P1",
          "orderNo": "O1",
          "paymentStage": "EARNEST_MONEY",
          "paymentChannel": "WECHAT",
          "paymentAmount": 5000,
          "paymentStatus": "PAID",
          "externalTradeNo": "MOCK-P1",
          "payTime": 1700000000000,
          "expireTime": 1700000900000
        }
        """.data(using: .utf8)!

        let record = try JSONDecoder().decode(PaymentRecord.self, from: json)
        XCTAssertEqual(record.paymentStatus, "PAID")
        XCTAssertEqual(record.paymentStage, "EARNEST_MONEY")
        XCTAssertEqual(record.payTime, 1700000000000)
    }

    // MARK: - 购车协议

    func testPurchaseAgreementDecodes() throws {
        let json = """
        {
          "agreementId": "A1",
          "agreementCode": "VEHICLE_PURCHASE",
          "saleModelCode": "SM001",
          "versionNo": 1,
          "title": "购车协议",
          "agreementStatus": "active",
          "effectiveFrom": 1700000000000
        }
        """.data(using: .utf8)!

        let agreement = try JSONDecoder().decode(PurchaseAgreement.self, from: json)
        XCTAssertEqual(agreement.agreementCode, "VEHICLE_PURCHASE")
        XCTAssertEqual(agreement.versionNo, 1)
        XCTAssertEqual(agreement.effectiveFrom, 1700000000000)
    }

    // MARK: - 尾款支付阶段（OTD-VSO-DSN-CR-014）

    func testInitiatePaymentResultDecodesTailPaymentStage() throws {
        let json = """
        {
          "paymentNo": "P1",
          "paymentChannel": "ALIPAY",
          "paymentAmount": 183000,
          "paymentStatus": "PROCESSING",
          "paymentStage": "TAIL_PAYMENT",
          "externalTradeNo": "MOCK-P1",
          "expireTime": 1700000000000
        }
        """.data(using: .utf8)!

        let result = try JSONDecoder().decode(InitiatePaymentResult.self, from: json)
        XCTAssertEqual(result.paymentStage, PaymentStageValue.tailPayment.rawValue)
        XCTAssertEqual(result.paymentAmount, Decimal(183000))
    }

    func testInitiatePaymentResultWithoutPaymentStage() throws {
        let json = """
        {"paymentNo": "P1", "paymentChannel": "WECHAT", "paymentAmount": 5000}
        """.data(using: .utf8)!

        let result = try JSONDecoder().decode(InitiatePaymentResult.self, from: json)
        XCTAssertNil(result.paymentStage, "旧服务端不返回 paymentStage 时不应解析失败")
    }

    // MARK: - 尾款资格纯函数

    private let prepareDeliver = OrderState.PREPARE_DELIVER.rawValue

    func testTailPaymentAllowedOnlyWhenAllConditionsMet() {
        XCTAssertTrue(TailPaymentRules.canPayTailPayment(orderState: prepareDeliver,
                                                         paymentMethod: "full_payment",
                                                         contractStatus: "SIGNED",
                                                         tailPaymentAmount: 183000))
        XCTAssertTrue(TailPaymentRules.canPayTailPayment(orderState: prepareDeliver,
                                                         paymentMethod: "full_payment",
                                                         contractStatus: "EFFECTIVE",
                                                         tailPaymentAmount: 183000))
    }

    func testTailPaymentRejectedWhenAnyConditionMissing() {
        // 未签署 / 签署中 / 未知状态
        for status in [nil, "DRAFT", "GENERATED", "SIGNING", "INVALID", "UNKNOWN"] {
            XCTAssertFalse(TailPaymentRules.canPayTailPayment(orderState: prepareDeliver,
                                                              paymentMethod: "full_payment",
                                                              contractStatus: status,
                                                              tailPaymentAmount: 183000),
                           "合同状态 \(String(describing: status)) 不应允许尾款")
        }
        // 非待交付状态
        XCTAssertFalse(TailPaymentRules.canPayTailPayment(orderState: 500,
                                                          paymentMethod: "full_payment",
                                                          contractStatus: "SIGNED",
                                                          tailPaymentAmount: 183000))
        // 非全款
        XCTAssertFalse(TailPaymentRules.canPayTailPayment(orderState: prepareDeliver,
                                                          paymentMethod: "loan",
                                                          contractStatus: "SIGNED",
                                                          tailPaymentAmount: 183000))
        // 金额缺失/非正
        XCTAssertFalse(TailPaymentRules.canPayTailPayment(orderState: prepareDeliver,
                                                          paymentMethod: "full_payment",
                                                          contractStatus: "SIGNED",
                                                          tailPaymentAmount: 0))
        XCTAssertFalse(TailPaymentRules.canPayTailPayment(orderState: prepareDeliver,
                                                          paymentMethod: "full_payment",
                                                          contractStatus: "SIGNED",
                                                          tailPaymentAmount: -1))
    }

    func testSignContractEligibility() {
        XCTAssertTrue(TailPaymentRules.canSignContract(orderState: prepareDeliver,
                                                       paymentMethod: "full_payment",
                                                       contractStatus: nil))
        XCTAssertTrue(TailPaymentRules.canSignContract(orderState: prepareDeliver,
                                                       paymentMethod: "full_payment",
                                                       contractStatus: "DRAFT"))
        XCTAssertTrue(TailPaymentRules.canSignContract(orderState: prepareDeliver,
                                                       paymentMethod: "full_payment",
                                                       contractStatus: "INVALID"))
        // 已发起或已签署不允许重复发起
        for status in ["SIGNING", "SIGNED", "EFFECTIVE"] {
            XCTAssertFalse(TailPaymentRules.canSignContract(orderState: prepareDeliver,
                                                            paymentMethod: "full_payment",
                                                            contractStatus: status),
                           "合同状态 \(status) 不应允许重复发起签署")
        }
        // 非待交付、非全款
        XCTAssertFalse(TailPaymentRules.canSignContract(orderState: 500,
                                                        paymentMethod: "full_payment",
                                                        contractStatus: nil))
        XCTAssertFalse(TailPaymentRules.canSignContract(orderState: prepareDeliver,
                                                        paymentMethod: "loan",
                                                        contractStatus: nil))
    }
}
