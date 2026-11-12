//
//  AvatarImageProcessorTests.swift
//  iovTests
//
//  Created by CR IOS-APP-DSN-CR-003 on 2026/11/12.
//

import XCTest
import UIKit
@testable import iov

final class AvatarImageProcessorTests: XCTestCase {

    // MARK: - TC-003-1 裁剪几何

    func testMinimumScaleCoversCropFrame() {
        let imageSize = CGSize(width: 4000, height: 3000)
        let cropSide: CGFloat = 280
        let scale = CropGeometry.minimumScale(imageSize: imageSize, cropSide: cropSide)

        XCTAssertGreaterThanOrEqual(imageSize.width * scale, cropSide)
        XCTAssertGreaterThanOrEqual(imageSize.height * scale, cropSide)
        XCTAssertEqual(scale, cropSide / imageSize.height, accuracy: 0.000001)
    }

    func testInitialCropIsCenteredAndUsesFullShortSide() {
        let imageSize = CGSize(width: 4000, height: 3000)
        let cropSide: CGFloat = 280
        let scale = CropGeometry.minimumScale(imageSize: imageSize, cropSide: cropSide)

        let rect = CropGeometry.sourceRect(imageSize: imageSize, cropSide: cropSide, scale: scale, offset: .zero)

        XCTAssertEqual(rect.width, 3000, accuracy: 0.001)
        XCTAssertEqual(rect.height, 3000, accuracy: 0.001)
        XCTAssertEqual(rect.midX, imageSize.width / 2, accuracy: 0.001)
        XCTAssertEqual(rect.midY, imageSize.height / 2, accuracy: 0.001)
    }

    func testSourceRectStaysSquareAndInsideImageAfterDragAndZoom() {
        let imageSize = CGSize(width: 4000, height: 3000)
        let cropSide: CGFloat = 280
        let minScale = CropGeometry.minimumScale(imageSize: imageSize, cropSide: cropSide)

        let cases: [(CGFloat, CGSize)] = [
            (minScale, .zero),
            (minScale * 2, CGSize(width: 1200, height: -900)),
            (minScale * 4, CGSize(width: -99999, height: 99999)),
            (minScale * 3, CGSize(width: 99999, height: 99999))
        ]

        for (scale, offset) in cases {
            let rect = CropGeometry.sourceRect(imageSize: imageSize, cropSide: cropSide, scale: scale, offset: offset)
            XCTAssertEqual(rect.width, rect.height, accuracy: 0.001, "scale=\(scale) offset=\(offset)")
            XCTAssertGreaterThanOrEqual(rect.minX, -0.001)
            XCTAssertGreaterThanOrEqual(rect.minY, -0.001)
            XCTAssertLessThanOrEqual(rect.maxX, imageSize.width + 0.001)
            XCTAssertLessThanOrEqual(rect.maxY, imageSize.height + 0.001)
        }
    }

    func testClampOffsetLimitsTranslation() {
        let imageSize = CGSize(width: 4000, height: 3000)
        let cropSide: CGFloat = 280
        let scale = CropGeometry.minimumScale(imageSize: imageSize, cropSide: cropSide)

        let clamped = CropGeometry.clampOffset(
            CGSize(width: 10000, height: -10000),
            imageSize: imageSize,
            cropSide: cropSide,
            scale: scale
        )

        let maxX = (imageSize.width * scale - cropSide) / 2
        XCTAssertEqual(clamped.width, maxX, accuracy: 0.001)
        XCTAssertEqual(clamped.height, 0, accuracy: 0.001)

        let clampedNegative = CropGeometry.clampOffset(
            CGSize(width: -10000, height: 10000),
            imageSize: imageSize,
            cropSide: cropSide,
            scale: scale
        )
        XCTAssertEqual(clampedNegative.width, -maxX, accuracy: 0.001)
        XCTAssertEqual(clampedNegative.height, 0, accuracy: 0.001)
    }

    // MARK: - TC-003-1 输出规格

    func testMakeJPEGOutputs1024SquareJPEG() {
        let image = makeImage(width: 4000, height: 3000)
        let scale = CropGeometry.minimumScale(imageSize: image.size, cropSide: 280)

        let result = AvatarImageProcessor.makeJPEG(from: image, cropSide: 280, scale: scale)

        guard case let .success(output) = result else {
            return XCTFail("预处理失败: \(result)")
        }
        XCTAssertEqual(output.pixelSize, CGSize(width: 1024, height: 1024))
        XCTAssertEqual(output.quality, 0.8)
        XCTAssertEqual(Array(output.data.prefix(3)), [0xFF, 0xD8, 0xFF], "必须为 JPEG")

        let decoded = UIImage(data: output.data)
        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.size.width ?? 0, 1024, accuracy: 0.5)
        XCTAssertEqual(decoded?.size.height ?? 0, 1024, accuracy: 0.5)
    }

    func testQualityLadderReducesBytesUnderLimit() {
        let image = makeNoiseImage(side: 1200)

        let baseline: Result<AvatarImageOutput, AvatarImageError> = AvatarImageProcessor.makeJPEG(
            from: image,
            cropSide: 1024,
            scale: 1,
            maxBytes: Int.max
        )
        guard case let .success(first) = baseline else {
            return XCTFail("基准编码失败: \(baseline)")
        }
        XCTAssertEqual(first.quality, 0.8)

        let limit = max(first.data.count - 100, 200)
        let reduced: Result<AvatarImageOutput, AvatarImageError> = AvatarImageProcessor.makeJPEG(
            from: image,
            cropSide: 1024,
            scale: 1,
            maxBytes: limit
        )
        guard case let .success(second) = reduced else {
            return XCTFail("质量递减失败: \(reduced)")
        }
        XCTAssertLessThanOrEqual(second.data.count, limit)
        XCTAssertLessThan(second.quality, 0.8, "应触发质量递减")
    }

    func testTooLargeWhenQualityLadderExhausted() {
        let image = makeNoiseImage(side: 512)

        let result: Result<AvatarImageOutput, AvatarImageError> = AvatarImageProcessor.makeJPEG(
            from: image,
            cropSide: 512,
            scale: 1,
            maxBytes: 100
        )

        guard case let .failure(error) = result else {
            return XCTFail("应返回超限错误")
        }
        XCTAssertEqual(error, .tooLarge(maxBytes: 100))
    }

    func testDecodeFailureReturnsError() {
        let result = AvatarImageProcessor.makeJPEG(from: UIImage(), cropSide: 280, scale: 1)

        guard case let .failure(error) = result else {
            return XCTFail("空图片应解码失败")
        }
        XCTAssertEqual(error, .decodeFailed)
    }

    // MARK: - Helpers

    private func makeImage(width: Int, height: Int) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)
        return renderer.image { context in
            UIColor.orange.setFill()
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))
            UIColor.blue.setFill()
            context.fill(CGRect(x: width / 4, y: height / 4, width: width / 2, height: height / 2))
        }
    }

    private func makeNoiseImage(side: Int) -> UIImage {
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * side
        var data = [UInt8](repeating: 0, count: bytesPerRow * side)
        for index in stride(from: 0, to: data.count, by: bytesPerPixel) {
            data[index] = UInt8.random(in: 0...255)
            data[index + 1] = UInt8.random(in: 0...255)
            data[index + 2] = UInt8.random(in: 0...255)
            data[index + 3] = 255
        }
        let provider = CGDataProvider(data: Data(data) as CFData)!
        let cgImage = CGImage(
            width: side,
            height: side,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        )!
        return UIImage(cgImage: cgImage)
    }
}
