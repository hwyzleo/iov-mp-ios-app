//
//  OrderDetailContractTests.swift
//  iovTests
//
//  订单详情接口解码契约：后端 `orderTime` / `eventTime` 等时间字段
//  可能返回 epoch 时间戳，也可能返回 ISO-8601 字符串
//  （如 `"2026-11-12T13:52:17.000+00:00"`）。
//  当模型只声明 `Int64?` 时，字符串会触发 DecodingError.typeMismatch，
//  `TspResponse.data` 被静默置 nil，页面表现为「黑屏 + 请求异常」。
//

import XCTest
@testable import iov

final class OrderDetailContractTests: XCTestCase {

    /// 真实后端响应（GET /api/mobile/vso/v1/order/{orderNo}，节选）
    private let orderDetailJSON = """
    {
      "code": "000000",
      "message": "成功",
      "data": {
        "orderNo": "VSO2611120001",
        "orderState": 960,
        "orderTime": "2026-11-12T13:52:17.000+00:00",
        "customerType": "personal",
        "paymentMethod": null,
        "orderPersonType": null,
        "orderPersonName": null,
        "purchasePlan": null,
        "licenseCityCode": "440300",
        "licenseCityName": "市辖区",
        "orderStoreCode": "STORE001",
        "deliveryStoreCode": "STORE002",
        "saleModelCode": "HC",
        "modelCode": "MD_HC03",
        "variantCode": "VR_HC03_01",
        "optionCodes": ["OC_EXT_BODY_COLOR_BLACK_1", "OC_ACC_SPARE_TIRE_FULL_SIZE"],
        "optionBreakdown": [
          {"optionCode": "OC_EXT_BODY_COLOR_BLACK_1", "optionFamilyCode": "EXTERIOR", "optionFamilyName": "外观", "optionName": "星夜黑", "optionPrice": 0},
          {"optionCode": "OC_ACC_SPARE_TIRE_FULL_SIZE", "optionFamilyCode": "SPARE_TIRE", "optionFamilyName": "备胎", "optionName": "全尺寸备胎", "optionPrice": 5000}
        ],
        "totalPrice": 235000.00,
        "saleModelImages": ["https://example.com/1.png"],
        "saleModelDesc": "全尺寸备胎 星夜黑"
      },
      "timestamp": 1794532510160
    }
    """.data(using: .utf8)!

    // MARK: - 订单详情

    func testOrderDetailDecodesISO8601OrderTime() throws {
        let response: Result<TspResponse<Order>, Error> = TspManager.parseData(orderDetailJSON)

        guard case .success(let value) = response else {
            return XCTFail("订单详情解析失败: \(response)")
        }
        let order = try XCTUnwrap(value.data, "orderTime 为 ISO-8601 字符串时 data 不应为 nil")
        XCTAssertEqual(order.orderNo, "VSO2611120001")
        XCTAssertEqual(order.orderState, 960)
        XCTAssertEqual(order.modelCode, "MD_HC03")
        XCTAssertEqual(order.totalPrice, Decimal(235000))
        XCTAssertEqual(order.optionBreakdown?.count, 2)

        // ISO-8601 → 毫秒时间戳：2026-11-12T13:52:17Z（与 tsFormat(ts:) 兼容，内部换算为秒）
        XCTAssertEqual(order.orderTime, 1794491537000)
        XCTAssertEqual(try XCTUnwrap(order.orderTime) / 1000, 1794491537)
    }

    func testOrderDetailDecodesEpochMillisOrderTime() throws {
        let json = """
        {"code": "000000", "data": {"orderNo": "O1", "orderState": 960, "orderTime": 1794532510160}, "timestamp": 1}
        """.data(using: .utf8)!

        let response: Result<TspResponse<Order>, Error> = TspManager.parseData(json)
        guard case .success(let value) = response else {
            return XCTFail("订单详情解析失败: \(response)")
        }
        XCTAssertEqual(value.data?.orderTime, 1794532510160)
    }

    func testOrderDetailDecodesWithoutOrderTime() throws {
        let json = """
        {"code": "000000", "data": {"orderNo": "O1", "orderState": 960}, "timestamp": 1}
        """.data(using: .utf8)!

        let response: Result<TspResponse<Order>, Error> = TspManager.parseData(json)
        guard case .success(let value) = response else {
            return XCTFail("订单详情解析失败: \(response)")
        }
        XCTAssertNotNil(value.data)
        XCTAssertNil(value.data?.orderTime)
    }

    // MARK: - 其他时间字段

    func testTimelineEventDecodesISO8601EventTime() throws {
        let json = """
        {
          "eventType": "CREATED",
          "eventName": "订单创建",
          "eventTime": "2026-11-12T13:52:17.000+00:00",
          "afterStatus": "EARNEST_MONEY_UNPAID"
        }
        """.data(using: .utf8)!

        let event = try JSONDecoder().decode(OrderTimelineEvent.self, from: json)
        XCTAssertEqual(event.eventTime, 1794491537000)
    }

    func testPaymentRecordDecodesISO8601Times() throws {
        let json = """
        {
          "paymentNo": "P1",
          "payTime": "2026-11-12T13:52:17.000+00:00",
          "expireTime": "2026-11-12T14:52:17.000+00:00"
        }
        """.data(using: .utf8)!

        let record = try JSONDecoder().decode(PaymentRecord.self, from: json)
        XCTAssertEqual(record.payTime, 1794491537000)
        XCTAssertEqual(record.expireTime, 1794495137000)
    }

    func testPaymentRecordKeepsEpochMillis() throws {
        let json = """
        {"paymentNo": "P1", "payTime": 1794532510160, "expireTime": "1794532510160"}
        """.data(using: .utf8)!

        let record = try JSONDecoder().decode(PaymentRecord.self, from: json)
        XCTAssertEqual(record.payTime, 1794532510160)
        XCTAssertEqual(record.expireTime, 1794532510160)
    }
}
