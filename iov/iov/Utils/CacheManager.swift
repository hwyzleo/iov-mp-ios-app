//
//  CacheManager.swift
//  iov
//
//  Created by Gemini on 2026/3/23.
//

import Foundation
import Kingfisher

struct CacheManager {
    
    /// 获取缓存大小（字节）
    static func getCacheSize(completion: @escaping (UInt) -> Void) {
        ImageCache.default.calculateDiskStorageSize { result in
            switch result {
            case .success(let size):
                completion(size)
            case .failure:
                completion(0)
            }
        }
    }
    
    /// 格式化缓存大小为 MB 字符串
    static func formatCacheSize(_ size: UInt) -> String {
        let mbSize = Double(size) / 1024 / 1024
        if mbSize < 0.1 {
            return "0 MB"
        }
        return String(format: "%.1f MB", mbSize)
    }
    
    /// 清除缓存
    static func clearCache(completion: @escaping () -> Void) {
        ImageCache.default.clearDiskCache {
            ImageCache.default.clearMemoryCache()
            completion()
        }
    }
}
