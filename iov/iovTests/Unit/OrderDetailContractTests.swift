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

    // MARK: - 订单详情门店选项（OTD-VSO-DSN-CR-008）

    /// 真实后端响应（GET /api/mobile/vso/v1/dealership/list?serviceType=S）
    private let dealershipListJSON = """
    {
      "code": "000000",
      "message": "成功",
      "data": [
        {"code": "STORE001", "name": "深圳南山销售门店", "address": "深圳市南山区示例路 1 号", "distance": 3.2},
        {"code": "STORE002", "name": "深圳福田销售门店", "address": "深圳市福田区示例路 2 号", "distance": null}
      ],
      "timestamp": 1794532510160
    }
    """.data(using: .utf8)!

    func testDealershipListDecodesVSOResponse() throws {
        let response: Result<TspResponse<[Dealership]>, Error> = TspManager.parseData(dealershipListJSON)

        guard case .success(let value) = response else {
            return XCTFail("门店选项解析失败: \(response)")
        }
        let list = try XCTUnwrap(value.data, "门店选项 data 不应为 nil")
        XCTAssertEqual(list.count, 2)
        XCTAssertEqual(list[0].code, "STORE001")
        XCTAssertEqual(list[0].name, "深圳南山销售门店")
        XCTAssertEqual(list[0].address, "深圳市南山区示例路 1 号")
        XCTAssertEqual(list[0].distance, 3.2)
        XCTAssertNil(list[1].distance, "ORG 无法计算距离时 distance 为 null，不应导致整页解析失败")
    }

    func testDealershipListReturnsEmptyArray() throws {
        let json = """
        {"code": "000000", "message": "成功", "data": [], "timestamp": 1}
        """.data(using: .utf8)!

        let response: Result<TspResponse<[Dealership]>, Error> = TspManager.parseData(json)
        guard case .success(let value) = response else {
            return XCTFail("空门店列表解析失败: \(response)")
        }
        XCTAssertEqual(value.data?.count, 0)
    }

    // MARK: - 购车合同与尾款（OTD-VSO-DSN-CR-014）

    func testOrderDetailDecodesTailPaymentAmount() throws {
        let json = """
        {"code": "000000", "data": {"orderNo": "O1", "orderState": 600, "paymentMethod": "full_payment", "totalPrice": 203000, "tailPaymentAmount": 183000}, "timestamp": 1}
        """.data(using: .utf8)!

        let response: Result<TspResponse<Order>, Error> = TspManager.parseData(json)
        guard case .success(let value) = response else {
            return XCTFail("订单详情解析失败: \(response)")
        }
        let order = try XCTUnwrap(value.data)
        XCTAssertEqual(order.orderState, 600)
        XCTAssertEqual(order.paymentMethod, "full_payment")
        XCTAssertEqual(order.tailPaymentAmount, Decimal(183000))
    }

    func testOrderDetailDecodesNullAndMissingTailPaymentAmount() throws {
        let nullJSON = """
        {"code": "000000", "data": {"orderNo": "O1", "orderState": 300, "tailPaymentAmount": null}, "timestamp": 1}
        """.data(using: .utf8)!
        let missingJSON = """
        {"code": "000000", "data": {"orderNo": "O1", "orderState": 300}, "timestamp": 1}
        """.data(using: .utf8)!

        for json in [nullJSON, missingJSON] {
            let response: Result<TspResponse<Order>, Error> = TspManager.parseData(json)
            guard case .success(let value) = response else {
                return XCTFail("tailPaymentAmount 缺失/null 不应导致解析失败: \(response)")
            }
            XCTAssertNotNil(value.data)
            XCTAssertNil(value.data?.tailPaymentAmount)
        }
    }

    func testContractInfoDecodesSignedContract() throws {
        let json = """
        {
          "code": "000000",
          "data": {
            "contractNo": "CT001",
            "contractType": "VEHICLE_PURCHASE",
            "contractStatus": "SIGNED",
            "signNo": "SIGN001",
            "fileUrl": "mock://esign/contract/O1/EXT001",
            "generateTime": "2026-11-19T07:00:00.000+00:00",
            "signTime": "2026-11-19T07:05:00.000+00:00",
            "effectiveTime": null,
            "invalidTime": null,
            "invalidReason": null
          },
          "timestamp": 1
        }
        """.data(using: .utf8)!

        let response: Result<TspResponse<ContractInfo>, Error> = TspManager.parseData(json)
        guard case .success(let value) = response else {
            return XCTFail("合同详情解析失败: \(response)")
        }
        let contract = try XCTUnwrap(value.data)
        XCTAssertEqual(contract.contractNo, "CT001")
        XCTAssertEqual(contract.contractStatus, "SIGNED")
        XCTAssertTrue(contract.isSignEffective)
        XCTAssertFalse(contract.isSigning)
        XCTAssertNil(contract.signUrl, "SIGNED 不再返回签署地址")
        XCTAssertNotNil(contract.signTime)
    }

    func testContractInfoDecodesSigningContractWithMockSignUrl() throws {
        let json = """
        {
          "code": "000000",
          "data": {
            "contractNo": "CT001",
            "contractType": "VEHICLE_PURCHASE",
            "contractStatus": "SIGNING",
            "signNo": "SIGN001",
            "signUrl": "mock://esign/sign/SIGN001",
            "generateTime": 1794551140508
          },
          "timestamp": 1
        }
        """.data(using: .utf8)!

        let response: Result<TspResponse<ContractInfo>, Error> = TspManager.parseData(json)
        guard case .success(let value) = response else {
            return XCTFail("合同解析失败: \(response)")
        }
        let contract = try XCTUnwrap(value.data)
        XCTAssertTrue(contract.isSigning)
        XCTAssertFalse(contract.isSignEffective)
        XCTAssertEqual(contract.signUrl, "mock://esign/sign/SIGN001")
        XCTAssertEqual(contract.generateTime, 1794551140508)
        XCTAssertNil(contract.signTime)
    }

    func testContractNotExistMapsToNoData() throws {
        let json = """
        {"code": "201061", "message": "购车合同不存在", "data": null, "timestamp": 1}
        """.data(using: .utf8)!

        let response: Result<TspResponse<ContractInfo>, Error> = TspManager.parseData(json)
        guard case .success(let value) = response else {
            return XCTFail("201061 响应不应解析失败: \(response)")
        }
        XCTAssertEqual(value.code, ContractErrorCode.notExist)
        XCTAssertNil(value.data, "201061 表示未签署，data 为空不应视为错误")
    }
}

// MARK: - 订单交付/完成后切换车辆状态页（IOS-APP-DSN-CR-009 / OTD-VSO-DSN-CR-016）

final class VehicleActivationMappingTests: XCTestCase {

    func testDeliveredAndCompletedStatesMapToVehicleEvenIfCloudTypeIsOrder() {
        // OTD-VSO-DSN-CR-016：700 退出订单生命周期，650 已交付、900 已完成均进入车辆场景
        XCTAssertEqual(VehicleType.resolve(cloudType: "ORDER", state: 650), .ACTIVATED,
                       "VSO myVehicleList 对订单固定返回 type=ORDER，650 必须以 state 判定为车辆场景")
        XCTAssertEqual(VehicleType.resolve(cloudType: "ORDER", state: 900), .ACTIVATED,
                       "900 已完成必须以 state 判定为车辆场景")
    }

    func testLegacyActivated700IsNoLongerATransition() {
        // 700 已删除，不再映射为车辆场景（历史数据由 VSO V1.43.0 迁移为 650/900）
        XCTAssertNil(OrderState(rawValue: 700), "700 激活态已从 OrderState 删除")
        XCTAssertEqual(VehicleType.resolve(cloudType: "ORDER", state: 700), .ORDER)
    }

    func testOtherOrderStatesStayOrder() {
        for state in [200, 300, 310, 600, 620] {
            XCTAssertEqual(VehicleType.resolve(cloudType: "ORDER", state: state), .ORDER,
                           "state=\(state) 不应切换到车辆状态页")
        }
    }

    func testWishlistAndExplicitActivatedType() {
        XCTAssertEqual(VehicleType.resolve(cloudType: "WISHLIST", state: 100), .WISHLIST)
        XCTAssertEqual(VehicleType.resolve(cloudType: "ORDER", state: 100), .WISHLIST)
        XCTAssertEqual(VehicleType.resolve(cloudType: "ACTIVATED", state: 620), .ACTIVATED)
    }

    func testCompletedStateValueIsStable() {
        XCTAssertEqual(OrderState.COMPLETED.rawValue, 900)
    }
}
