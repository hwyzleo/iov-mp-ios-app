//
//  ConfiguratorContractTests.swift
//  iovTests
//
//  选配器接口解码契约：后端用空串（""）表示“无图”，
//  model.marketingImage 为空、真正图片在 variant.marketingImage 上，
//  若把空串当成有效 URL 传入轮播，会让「预定爱车」页顶部图片区域空白。
//

import XCTest
@testable import iov

final class ConfiguratorContractTests: XCTestCase {

    /// 真实后端响应（GET /api/mobile/saleModel/v1/{saleModelCode}/configurator，节选）
    private let configuratorResponseJSON = """
    {
      "code": "0",
      "message": "成功",
      "data": {
        "saleModelCode": "HC",
        "modelName": "寒川",
        "models": [
          {
            "modelCode": "MD_HC03",
            "modelName": "寒川03",
            "marketingImage": "",
            "marketingCopy": "",
            "sortWeight": 99,
            "variants": [
              {
                "variantCode": "VR_HC03_01",
                "variantName": "",
                "marketingImage": "https://example.com/variant.png",
                "marketingCopy": "",
                "sortWeight": 99,
                "variantPrice": 220000.00,
                "earnestMoneyPrice": 5000.00,
                "downPaymentPrice": 5000.00,
                "selectableFamilies": [
                  {
                    "optionFamilyCode": "OF_EXT_COLOR",
                    "optionFamilyName": "外观",
                    "marketingImage": null,
                    "marketingDesc": null,
                    "sortWeight": 0,
                    "options": [
                      {
                        "optionCode": "OC_EXT_BODY_COLOR_BLACK_1",
                        "optionName": "星夜黑",
                        "saleStatus": "active",
                        "price": 0.00,
                        "image": "https://example.com/black.png",
                        "marketingCopy": null,
                        "bundleWith": [],
                        "mutexWith": []
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      },
      "timestamp": 1794473827997
    }
    """

    func testConfiguratorDecodesAndResolvesVariantImage() throws {
        let result: Result<TspResponse<ConfiguratorResult>, Error> = TspManager.parseData(Data(configuratorResponseJSON.utf8))
        guard case let .success(response) = result else {
            return XCTFail("响应解码失败: \(result)")
        }
        let configurator = try XCTUnwrap(response.data)

        let model = try XCTUnwrap(configurator.models.first)
        let variant = try XCTUnwrap(model.variants.first)

        // 后端约定：model.marketingImage 为空串表示无图
        XCTAssertEqual(model.marketingImage, "")

        // 预定爱车页顶部图片应回退到 variant.marketingImage
        let images = nonEmptyImageURLs([model.marketingImage, variant.marketingImage])
        XCTAssertEqual(images, ["https://example.com/variant.png"])
    }

    func testNonEmptyImageURLsFiltersBlankAndDuplicates() {
        XCTAssertEqual(nonEmptyImageURLs([nil, "", "   "]), [])
        XCTAssertEqual(nonEmptyImageURLs(["https://a/1.png", "", nil, "https://a/1.png"]), ["https://a/1.png"])
        XCTAssertEqual(nonEmptyImageURLs(["https://a/1.png", "https://a/2.png"]),
                       ["https://a/1.png", "https://a/2.png"])
    }

    func testFamilyWithoutMarketingImageYieldsEmptyList() throws {
        let result: Result<TspResponse<ConfiguratorResult>, Error> = TspManager.parseData(Data(configuratorResponseJSON.utf8))
        guard case let .success(response) = result, let configurator = response.data,
              let family = configurator.models.first?.variants.first?.selectableFamilies.first else {
            return XCTFail("响应解码失败")
        }
        XCTAssertNil(family.marketingImage)
        XCTAssertEqual(nonEmptyImageURLs([family.marketingImage]), [])
        XCTAssertEqual(nonEmptyImageURLs([family.options.first?.image]), ["https://example.com/black.png"])
    }
}
