//
//  WishlistContractTests.swift
//  iovTests
//
//  心愿单详情接口解码契约：后端日期字段返回 ISO-8601 字符串，
//  默认 JSONDecoder(.deferredToDate) 会整包解码失败，表现为「HTTP 200 但提示请求异常」。
//

import XCTest
@testable import iov

final class WishlistContractTests: XCTestCase {

    /// 真实后端响应（GET /api/mobile/vso/v1/wishlist/{wishlistId}）
    private let wishlistResponseJSON = """
    {
      "code": "0",
      "message": "成功",
      "data": {
        "wishlistId": "W6zP8mgQBLiwtgU",
        "saleModelCode": "SM_HC",
        "modelCode": "MD_HC03",
        "variantCode": "VR_HC03_01",
        "configurationCode": "CFG_HC03_01",
        "optionCodes": [
          "OC_SMART_ADAS_COMPUTE_NVIDIA_ORIN_X",
          "OC_EXT_WHEEL_21_BLACK",
          "OC_EXT_BODY_COLOR_BLACK_1",
          "OC_INT_COLOR_THEME_BLACK_1",
          "OC_ACC_SPARE_TIRE_FULL_SIZE"
        ],
        "createTime": "2026-11-12T07:24:49.000+00:00",
        "modifyTime": "2026-11-12T07:24:49.000+00:00",
        "invalidReason": null,
        "saleModelName": "寒川",
        "modelMarketingName": "寒川03",
        "variantMarketingName": "",
        "variantPrice": 220000.00,
        "saleModelImages": [
          "https://example.com/1.png",
          "https://example.com/2.png"
        ],
        "totalPrice": 235000.00,
        "optionDetails": [
          { "optionFamilyCode": "OF_ACC", "optionCode": "OC_ACC_SPARE_TIRE_FULL_SIZE", "marketingTitle": "全尺寸备胎", "optionPrice": 5000.00, "marketingImage": "https://example.com/1.png" },
          { "optionFamilyCode": "OF_EXT_COLOR", "optionCode": "OC_EXT_BODY_COLOR_BLACK_1", "marketingTitle": "星夜黑", "optionPrice": 0.00, "marketingImage": "https://example.com/2.png" }
        ]
      },
      "timestamp": 1794473020019
    }
    """

    // MARK: - 心愿单详情

    func testWishlistResponseDecodesWithISO8601DateStrings() throws {
        let result: Result<TspResponse<Wishlist>, Error> = TspManager.parseData(Data(wishlistResponseJSON.utf8))
        guard case let .success(response) = result else {
            return XCTFail("响应解码失败: \(result)")
        }

        let wishlist = try XCTUnwrap(
            response.data,
            "data 不应为 nil：曾因 createTime/modifyTime 是 ISO-8601 字符串导致内层模型整包解码失败"
        )

        XCTAssertEqual(wishlist.wishlistId, "W6zP8mgQBLiwtgU")
        XCTAssertEqual(wishlist.saleModelName, "寒川")
        XCTAssertEqual(wishlist.modelMarketingName, "寒川03")
        XCTAssertEqual(wishlist.totalPrice, Decimal(235000))
        XCTAssertEqual(wishlist.variantPrice, Decimal(220000))
        XCTAssertEqual(wishlist.optionDetails?.count, 2)
        XCTAssertEqual(wishlist.saleModelImages?.count, 2)

        // 2026-11-12T07:24:49.000+00:00 == 1794468289
        let createTime = try XCTUnwrap(wishlist.createTime)
        XCTAssertEqual(createTime.timeIntervalSince1970, 1794468289, accuracy: 0.001)
    }

    func testWishlistResponseWithMissingDateFieldsStillDecodes() throws {
        let json = """
        { "code": "0", "data": { "wishlistId": "W1", "saleModelCode": "S", "modelCode": "M",
          "variantCode": "V", "configurationCode": "C", "optionCodes": [] }, "timestamp": 1 }
        """
        let result: Result<TspResponse<Wishlist>, Error> = TspManager.parseData(Data(json.utf8))
        guard case let .success(response) = result else {
            return XCTFail("响应解码失败: \(result)")
        }
        let wishlist = try XCTUnwrap(response.data)
        XCTAssertNil(wishlist.createTime)
        XCTAssertNil(wishlist.modifyTime)
    }

    // MARK: - 日期策略

    private struct DateWrapper: Codable {
        var value: Date
    }

    func testDecoderAcceptsISO8601WithAndWithoutFractionalSeconds() throws {
        let decoder = TspManager.makeDecoder()

        let withFraction = try decoder.decode(DateWrapper.self,
                                              from: Data(#"{"value":"2026-11-12T07:24:49.123+00:00"}"#.utf8))
        XCTAssertEqual(withFraction.value.timeIntervalSince1970, 1794468289.123, accuracy: 0.002)

        let withoutFraction = try decoder.decode(DateWrapper.self,
                                                 from: Data(#"{"value":"2026-11-12T07:24:49+00:00"}"#.utf8))
        XCTAssertEqual(withoutFraction.value.timeIntervalSince1970, 1794468289, accuracy: 0.002)
    }

    func testDecoderAcceptsEpochMillisecondsAndSeconds() throws {
        let decoder = TspManager.makeDecoder()

        let milliseconds = try decoder.decode(DateWrapper.self,
                                              from: Data(#"{"value":1794468289000}"#.utf8))
        XCTAssertEqual(milliseconds.value.timeIntervalSince1970, 1794468289, accuracy: 0.002)

        let seconds = try decoder.decode(DateWrapper.self,
                                         from: Data(#"{"value":1794468289}"#.utf8))
        XCTAssertEqual(seconds.value.timeIntervalSince1970, 1794468289, accuracy: 0.002)
    }
}
