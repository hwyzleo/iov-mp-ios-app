//
//  PaymentExpireTimeContractTests.swift
//  iovTests
//
//  意向金 / 定金下单结果 `expireTime` 解码契约。
//
//  背景（线上问题）：后端时间输出已统一为 ISO-8601，`Instant` 会带 0~9 位小数秒，
//  线上真实值为 `"2026-11-13T06:25:40.506874710Z"`。旧实现用默认
//  `ISO8601DateFormatter()`（只支持 0 位或带 `.withFractionalSeconds` 才有小数秒）
//  解析失败后回退 `Date()`，导致 `remainingSeconds == 0`、`isExpired == true`，
//  支付页一进入就渲染「支付已超时」，`PaymentFlowService.pay()` 从未被调用。
//
//  本用例钉住三件事：
//  1. ISO-8601（0/3/6/9 位小数秒、`Z` 与 `+08:00` 偏移）都能正确解析；
//  2. 历史 epoch 毫秒 / 秒 / 数字字符串仍兼容；
//  3. 解析失败或字段缺失时**不得**退化为“此刻”，否则页面会假超时。
//

import XCTest
@testable import iov

final class PaymentExpireTimeContractTests: XCTestCase {

    /// 2026-11-13T06:25:40Z（线上 `earnestMoneyOrder` 实际返回的时刻）
    private let expectedEpoch: TimeInterval = 1794551140

    // MARK: - 意向金下单结果

    private func earnestJSON(expireTime: String) -> Data {
        Data("""
        {
          "orderNo": "VSO2611130001",
          "earnestMoneyAmount": 5000.00,
          "paymentChannels": [
            { "channelCode": "WECHAT", "channelName": "微信支付", "isDefault": true },
            { "channelCode": "ALIPAY", "channelName": "支付宝", "isDefault": false }
          ],
          "expireTime": \(expireTime)
        }
        """.utf8)
    }

    /// 线上真实格式：`Instant` 纳秒精度（9 位小数秒 + Z）
    func testEarnestMoneyOrderResultDecodesNanosecondISO8601() throws {
        let json = earnestJSON(expireTime: "\"2026-11-13T06:25:40.506874710Z\"")
        let result = try TspManager.makeDecoder().decode(EarnestMoneyOrderResult.self, from: json)

        XCTAssertEqual(result.orderNo, "VSO2611130001")
        XCTAssertEqual(result.expireTime.timeIntervalSince1970, expectedEpoch, accuracy: 1.0,
                       "9 位小数秒必须被截到毫秒，而不是解析失败")
        XCTAssertEqual(result.expireTime.timeIntervalSince1970,
                       expectedEpoch + 0.506, accuracy: 0.001)
    }

    /// 解析成功且截止时间在未来时，页面不得报“已超时”
    func testEarnestMoneyOrderResultFutureExpireTimeIsNotExpired() throws {
        let future = ISO8601DateFormatter()
        future.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let text = future.string(from: Date().addingTimeInterval(900))
        let json = earnestJSON(expireTime: "\"\(text)\"")

        let result = try TspManager.makeDecoder().decode(EarnestMoneyOrderResult.self, from: json)
        let payInfo = EarnestMoneyPayInfo(from: result)
        XCTAssertFalse(payInfo.isExpired)
        XCTAssertGreaterThan(payInfo.remainingSeconds, 800)
    }

    func testEarnestMoneyOrderResultDecodesMillisWithOffset() throws {
        let json = earnestJSON(expireTime: "\"2026-11-13T06:25:40.000+00:00\"")
        let result = try TspManager.makeDecoder().decode(EarnestMoneyOrderResult.self, from: json)
        XCTAssertEqual(result.expireTime.timeIntervalSince1970, expectedEpoch, accuracy: 0.5)
    }

    func testEarnestMoneyOrderResultDecodesISO8601WithoutFraction() throws {
        let json = earnestJSON(expireTime: "\"2026-11-13T06:25:40Z\"")
        let result = try TspManager.makeDecoder().decode(EarnestMoneyOrderResult.self, from: json)
        XCTAssertEqual(result.expireTime.timeIntervalSince1970, expectedEpoch, accuracy: 0.5)
    }

    func testEarnestMoneyOrderResultDecodesMicrosecondFraction() throws {
        let json = earnestJSON(expireTime: "\"2026-11-13T06:25:40.506874Z\"")
        let result = try TspManager.makeDecoder().decode(EarnestMoneyOrderResult.self, from: json)
        XCTAssertEqual(result.expireTime.timeIntervalSince1970, expectedEpoch, accuracy: 1.0)
    }

    func testEarnestMoneyOrderResultKeepsEpochMillisCompatibility() throws {
        let json = earnestJSON(expireTime: "1794551140508")
        let result = try TspManager.makeDecoder().decode(EarnestMoneyOrderResult.self, from: json)
        XCTAssertEqual(result.expireTime.timeIntervalSince1970, expectedEpoch + 0.508, accuracy: 0.001)
    }

    func testEarnestMoneyOrderResultKeepsEpochSecondCompatibility() throws {
        let json = earnestJSON(expireTime: "1794551140")
        let result = try TspManager.makeDecoder().decode(EarnestMoneyOrderResult.self, from: json)
        XCTAssertEqual(result.expireTime.timeIntervalSince1970, expectedEpoch, accuracy: 0.5,
                       "10 位秒时间戳必须按秒解释，不能除以 1000")
    }

    func testEarnestMoneyOrderResultDecodesNumericStringTimestamp() throws {
        let json = earnestJSON(expireTime: "\"1794551140508\"")
        let result = try TspManager.makeDecoder().decode(EarnestMoneyOrderResult.self, from: json)
        XCTAssertEqual(result.expireTime.timeIntervalSince1970, expectedEpoch + 0.508, accuracy: 0.001)
    }

    /// 字段缺失 / 无法识别时回退默认支付窗口，不能立刻判超时
    func testEarnestMoneyOrderResultMissingExpireTimeDoesNotExpireImmediately() throws {
        let json = Data("""
        {
          "orderNo": "VSO1",
          "earnestMoneyAmount": 5000.00,
          "paymentChannels": []
        }
        """.utf8)
        let result = try TspManager.makeDecoder().decode(EarnestMoneyOrderResult.self, from: json)
        let payInfo = EarnestMoneyPayInfo(from: result)
        XCTAssertFalse(payInfo.isExpired, "缺失 expireTime 不得伪装成已过期")
        XCTAssertGreaterThan(payInfo.remainingSeconds, 60)
    }

    func testEarnestMoneyOrderResultUnknownFormatDoesNotExpireImmediately() throws {
        let json = earnestJSON(expireTime: "\"not-a-date\"")
        let result = try TspManager.makeDecoder().decode(EarnestMoneyOrderResult.self, from: json)
        XCTAssertFalse(EarnestMoneyPayInfo(from: result).isExpired)
    }

    // MARK: - 定金下单结果（同一缺陷，同批修复）

    func testDownPaymentOrderResultDecodesNanosecondISO8601() throws {
        let json = Data("""
        {
          "orderNo": "VSO2611130002",
          "downPaymentAmount": 5000.00,
          "paymentChannels": [
            { "channelCode": "WECHAT", "channelName": "微信支付", "isDefault": true }
          ],
          "expireTime": "2026-11-13T06:25:40.506874710Z"
        }
        """.utf8)
        let result = try TspManager.makeDecoder().decode(DownPaymentOrderResult.self, from: json)
        XCTAssertEqual(result.expireTime.timeIntervalSince1970, expectedEpoch, accuracy: 1.0)
    }

    // MARK: - 统一时间解析入口

    func testParseTimestampHandlesAllSupportedShapes() {
        let cases: [(String, TimeInterval)] = [
            ("2026-11-13T06:25:40.506874710Z", expectedEpoch),
            ("2026-11-13T06:25:40.506Z", expectedEpoch),
            ("2026-11-13T06:25:40Z", expectedEpoch),
            ("2026-11-13T14:25:40+08:00", expectedEpoch),
            ("1794551140508", expectedEpoch + 0.508),
            (" 1794551140 ", expectedEpoch)
        ]
        for (text, expected) in cases {
            guard let date = TspManager.parseTimestamp(from: text) else {
                return XCTFail("\(text) 解析失败")
            }
            XCTAssertEqual(date.timeIntervalSince1970, expected, accuracy: 1.0, "\(text) 解析结果不符")
        }
    }

    func testParseTimestampRejectsUnsupportedValues() {
        XCTAssertNil(TspManager.parseTimestamp(from: ""))
        XCTAssertNil(TspManager.parseTimestamp(from: "   "))
        XCTAssertNil(TspManager.parseTimestamp(from: "not-a-date"))
        // 0 / 负值 / 位数不足不猜测
        XCTAssertNil(TspManager.date(fromEpochNumber: 0))
        XCTAssertNil(TspManager.date(fromEpochNumber: -1))
        XCTAssertNil(TspManager.date(fromEpochNumber: 12345))
    }

    /// FlexibleTimestamp 与统一样本解析保持一致（ISO 纳秒 → 毫秒）
    func testFlexibleTimestampNormalizesNanosecondISO8601() throws {
        let json = Data(#"{"value":"2026-11-13T06:25:40.506874710Z"}"#.utf8)
        struct Holder: Codable { @FlexibleTimestamp var value: Int64? }
        let holder = try JSONDecoder().decode(Holder.self, from: json)
        XCTAssertEqual(holder.value, 1794551140506, "ISO 纳秒时间应截断归一为毫秒时间戳")
    }
}
