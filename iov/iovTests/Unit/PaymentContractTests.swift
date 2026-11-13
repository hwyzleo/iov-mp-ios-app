//
//  PaymentContractTests.swift
//  iovTests
//
//  IOS-APP-DSN-CR-002
//

import XCTest
@testable import iov

final class PaymentContractTests: XCTestCase {

    // MARK: - Mock 网关签名

    func testMockPaymentSignatureMatchesBackendContract() {
        let signature = MockPaymentGateway.buildSignature(
            paymentNo: "P123",
            externalTradeNo: "MOCK-P123",
            status: "PAID",
            amount: 5000,
            nonce: "abc",
            timestamp: 1700000000
        )
        XCTAssertEqual(signature, "b54c1db1d0f6a59da0c7a5064215f2939d27704ea378a84c5b2601cdd15d1a6c")
    }

    func testHMACSHA256UsesLowercaseHex() {
        let value = MockPaymentGateway.hmacSHA256(content: "abc", secret: "key")
        XCTAssertEqual(value, "9c196e32dc0175f86f4b1cb89289d6619de6bee699e4c378e68309ed97a1a6ab")
    }

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
