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
}
