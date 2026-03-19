//
//  QRCodeUtil.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import UIKit
import CoreImage

struct QRCodeUtil {
    
    private static let context = CIContext()
    
    /// 生成二维码
    static func generateQRCode(from string: String, size: CGSize = CGSize(width: 250, height: 250)) -> UIImage? {
        let data = string.data(using: String.Encoding.utf8)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel")
            
            if let outputImage = filter.outputImage {
                // 1. 获取高清二维码图像
                let scaleX = size.width / outputImage.extent.size.width
                let scaleY = size.height / outputImage.extent.size.height
                let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
                
                // 2. 将 CIImage 转换为 CGImage (关键步骤，解决 CIImage 直接转 UIImage 在某些场景下不显示的问题)
                if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
                    return UIImage(cgImage: cgImage)
                }
            }
        }
        
        return nil
    }
    
}
