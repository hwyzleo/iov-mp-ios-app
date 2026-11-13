//
//  OrderReopenContractTests.swift
//  iovTests
//
//  IOS-APP-DSN-CR-004：订单终态展示与支付超时恢复契约
//

import XCTest
@testable import iov

final class OrderReopenContractTests: XCTestCase {

    // MARK: - 状态映射

    func testTerminalOrderStatesAreMapped() {
        XCTAssertEqual(OrderState(rawValue: 950), .CANCEL)
        XCTAssertEqual(OrderState(rawValue: 960), .EXPIRED)
        XCTAssertEqual(OrderState(rawValue: 970), .CLOSED)
    }

    func testOnlyTerminalStatesAreTerminal() {
        XCTAssertTrue(OrderState.EXPIRED.isTerminal)
        XCTAssertTrue(OrderState.CANCEL.isTerminal)
        XCTAssertTrue(OrderState.CLOSED.isTerminal)
        XCTAssertFalse(OrderState.EARNEST_MONEY_UNPAID.isTerminal)
        XCTAssertFalse(OrderState.EARNEST_MONEY_PAID.isTerminal)
        XCTAssertFalse(OrderState.DELIVERED.isTerminal)
    }

    func testUnknownStateHasNoEnumValue() {
        // 未知值不得映射成“待支付”；调用方统一按终态处理（不展示支付动作）
        XCTAssertNil(OrderState(rawValue: 999))
        XCTAssertEqual(OrderState.maxReopenCount, 2)
    }

    // MARK: - 重新发起支付响应解码

    func testReopenPaymentResultDecodesEpochMillis() throws {
        let json = """
        {"orderNo":"VSO2611120001","orderState":200,"reopenCount":1,"expireTime":1794532510160}
        """
        let result = try JSONDecoder().decode(ReopenPaymentResult.self, from: Data(json.utf8))
        XCTAssertEqual(result.orderNo, "VSO2611120001")
        XCTAssertEqual(result.orderState, 200)
        XCTAssertEqual(result.reopenCount, 1)
        XCTAssertEqual(result.expireTime, 1794532510160)
    }

    func testReopenPaymentResultDecodesISO8601ExpireTime() throws {
        let json = """
        {"orderNo":"VSO1","orderState":200,"reopenCount":2,"expireTime":"2026-11-13T01:15:10.000+00:00"}
        """
        let result = try JSONDecoder().decode(ReopenPaymentResult.self, from: Data(json.utf8))
        XCTAssertEqual(result.reopenCount, 2)
        // ISO-8601 统一转为 epoch 毫秒，兼容 tsFormat(ts:)
        XCTAssertEqual(result.expireTime, 1794532510000)
    }

    func testReopenPaymentResultToleratesMissingExpireTime() throws {
        let json = """
        {"orderNo":"VSO1","orderState":200,"reopenCount":1}
        """
        let result = try JSONDecoder().decode(ReopenPaymentResult.self, from: Data(json.utf8))
        XCTAssertNil(result.expireTime)
    }

    // MARK: - 错误码

    func testPaymentErrorCodesMatchCloudContract() {
        XCTAssertEqual(PaymentErrorCode.orderExpired, "201057")
        XCTAssertEqual(PaymentErrorCode.reopenNotAllowed, "201058")
        XCTAssertEqual(PaymentErrorCode.reopenLimitExceeded, "201059")
    }
}
