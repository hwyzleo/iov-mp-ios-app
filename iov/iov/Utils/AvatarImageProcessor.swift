//
//  AvatarImageProcessor.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-003 on 2026/11/12.
//

import Foundation
import UIKit

// MARK: - 错误

/// 头像预处理错误（IOS-APP-DSN-CR-003 RD-003-2）
enum AvatarImageError: Error, Equatable {
    /// 图片解码失败（含空图片）
    case decodeFailed
    /// 渲染或编码失败
    case renderFailed
    /// 质量递减后仍超过大小上限
    case tooLarge(maxBytes: Int)
}

// MARK: - 输入输出

/// 裁剪输入：裁剪框为正方形，`cropSide`/`scale`/`offset` 与裁剪界面视图单位一致
struct AvatarCropInput {
    let image: UIImage
    let cropSide: CGFloat
    let scale: CGFloat
    let offset: CGSize

    init(image: UIImage, cropSide: CGFloat, scale: CGFloat = 1, offset: CGSize = .zero) {
        self.image = image
        self.cropSide = cropSide
        self.scale = scale
        self.offset = offset
    }
}

/// 预处理输出（统一 1024×1024 JPEG）
struct AvatarImageOutput: Equatable {
    let data: Data
    let quality: CGFloat
    let pixelSize: CGSize
}

// MARK: - 裁剪几何

/// 裁剪几何（纯函数，与 SwiftUI 界面解耦；IOS-APP-DSN-CR-003 RD-003-2 / TC-003-1）
///
/// 坐标系约定：
/// - 图片以 `scale` 缩放后居中覆盖正方形裁剪框；
/// - `offset` 为图片相对裁剪框中心的平移量（视图单位，向右/向下为正）。
enum CropGeometry {

    /// 图片完全覆盖裁剪框所需的最小缩放
    static func minimumScale(imageSize: CGSize, cropSide: CGFloat) -> CGFloat {
        guard imageSize.width > 0, imageSize.height > 0, cropSide > 0 else { return 1 }
        return max(cropSide / imageSize.width, cropSide / imageSize.height)
    }

    /// 将平移量约束在图片覆盖裁剪框的范围内
    static func clampOffset(
        _ offset: CGSize,
        imageSize: CGSize,
        cropSide: CGFloat,
        scale: CGFloat
    ) -> CGSize {
        guard imageSize.width > 0, imageSize.height > 0, cropSide > 0, scale > 0 else { return .zero }
        let renderedWidth = imageSize.width * scale
        let renderedHeight = imageSize.height * scale
        let maxX = max(0, (renderedWidth - cropSide) / 2)
        let maxY = max(0, (renderedHeight - cropSide) / 2)
        return CGSize(
            width: min(max(offset.width, -maxX), maxX),
            height: min(max(offset.height, -maxY), maxY)
        )
    }

    /// 裁剪框映射到源图（像素）的矩形：宽高相等且不越界
    static func sourceRect(
        imageSize: CGSize,
        cropSide: CGFloat,
        scale: CGFloat,
        offset: CGSize
    ) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0, cropSide > 0, scale > 0 else { return .zero }

        let side = min(min(cropSide / scale, imageSize.width), imageSize.height)
        let clamped = clampOffset(offset, imageSize: imageSize, cropSide: cropSide, scale: scale)
        let x = (imageSize.width - side) / 2 - clamped.width / scale
        let y = (imageSize.height - side) / 2 - clamped.height / scale
        let clampedX = min(max(x, 0), max(0, imageSize.width - side))
        let clampedY = min(max(y, 0), max(0, imageSize.height - side))
        return CGRect(x: clampedX, y: clampedY, width: side, height: side)
    }
}

// MARK: - 处理器

/// 头像预处理：裁剪输出、等比缩放、JPEG 编码与大小收敛
protocol AvatarImageProcessing {
    func makeJPEG(from input: AvatarCropInput) -> Result<AvatarImageOutput, AvatarImageError>
}

struct AvatarImageProcessor: AvatarImageProcessing {

    /// 统一输出边长
    static let maxPixelSide: CGFloat = 1024
    /// 上传大小上限 10 MiB
    static let maxBytes: Int = 10 * 1024 * 1024
    /// 质量递减阶梯
    static let qualityLadder: [CGFloat] = [0.8, 0.6, 0.4]

    func makeJPEG(from input: AvatarCropInput) -> Result<AvatarImageOutput, AvatarImageError> {
        return Self.makeJPEG(
            from: input.image,
            cropSide: input.cropSide,
            scale: input.scale,
            offset: input.offset,
            maxBytes: Self.maxBytes
        )
    }

    /// 可注入 `maxBytes`，便于测试质量递减与超限分支
    static func makeJPEG(
        from image: UIImage,
        cropSide: CGFloat,
        scale: CGFloat,
        offset: CGSize = .zero,
        maxBytes: Int = AvatarImageProcessor.maxBytes
    ) -> Result<AvatarImageOutput, AvatarImageError> {
        guard let normalized = normalized(image), let cgImage = normalized.cgImage else {
            return .failure(.decodeFailed)
        }

        let pixelSize = CGSize(width: cgImage.width, height: cgImage.height)
        guard pixelSize.width >= 1, pixelSize.height >= 1 else {
            return .failure(.decodeFailed)
        }

        let rect = CropGeometry.sourceRect(imageSize: pixelSize, cropSide: cropSide, scale: scale, offset: offset)
        guard rect.width >= 1, rect.height >= 1 else {
            return .failure(.decodeFailed)
        }

        let padded = CGRect(x: rect.minX, y: rect.minY, width: max(1, rect.width), height: max(1, rect.height)).integral
        let cropRect = padded.intersection(CGRect(origin: .zero, size: pixelSize))
        guard !cropRect.isEmpty, let cropped = cgImage.cropping(to: cropRect) else {
            return .failure(.decodeFailed)
        }

        let side = Int(maxPixelSide)
        guard let squared = square(cropped, side: side) else {
            return .failure(.renderFailed)
        }

        for quality in qualityLadder {
            guard let data = squared.jpegData(compressionQuality: quality) else {
                return .failure(.renderFailed)
            }
            if data.count <= maxBytes {
                return .success(
                    AvatarImageOutput(
                        data: data,
                        quality: quality,
                        pixelSize: CGSize(width: side, height: side)
                    )
                )
            }
        }

        return .failure(.tooLarge(maxBytes: maxBytes))
    }

    // MARK: - Private

    /// 统一方向与缩放，保证裁剪坐标与像素一致
    private static func normalized(_ image: UIImage) -> UIImage? {
        guard image.size.width > 0, image.size.height > 0 else { return nil }
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        let result = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
        return result.cgImage == nil ? nil : result
    }

    /// 等比缩放并居中裁成正方形
    private static func square(_ image: CGImage, side: Int) -> UIImage? {
        let source = CGSize(width: image.width, height: image.height)
        let scale = max(CGFloat(side) / source.width, CGFloat(side) / source.height)
        let drawSize = CGSize(width: source.width * scale, height: source.height * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: side, height: side), format: format)
        return renderer.image { _ in
            UIImage(cgImage: image).draw(
                in: CGRect(
                    x: (CGFloat(side) - drawSize.width) / 2,
                    y: (CGFloat(side) - drawSize.height) / 2,
                    width: drawSize.width,
                    height: drawSize.height
                )
            )
        }
    }
}
