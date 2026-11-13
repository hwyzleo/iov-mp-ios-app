//
//  BaseAPI.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import Foundation
import Alamofire
import UIKit

// TSP 公共请求头（不含凭证）
var tspBaseHeaders: HTTPHeaders {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""

    return [
        "X-Device-Id": getDeviceId(),
        "X-Platform": "ios",
        "X-Os-Version": UIDevice.current.systemVersion,
        "X-App-Version": appVersion,
        "X-Client-Id": AppConfig.tspClientId,
        "X-Client-Type": "MOBILE"
    ]
}

// TSP 请求头（凭证仅从 Keychain 会话读取）
var tspHeaders: HTTPHeaders {
    let token = AuthEnvironment.shared.sessionRepository.currentAccessToken()

    var headers = tspBaseHeaders
    if !token.isEmpty {
        headers["Authorization"] = "Bearer \(token)"
    }

    return headers
}

/// TSP 管理
class TspManager {
    
    // POST 请求
    static func requestPost<T: Codable>(path: String, parameters: Parameters, headers: HTTPHeaders? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        ensureTokenValid { result in
            switch result {
            case .success:
                performRequestPost(path: path, parameters: parameters, extraHeaders: headers, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    static func requestGet<T: Codable>(path: String, parameters: Parameters, completion: @escaping (Result<T, Error>) -> Void) {
        ensureTokenValid { result in
            switch result {
            case .success:
                performRequestGet(path: path, parameters: parameters, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    static func requestPut<T: Codable>(path: String, parameters: Parameters, completion: @escaping (Result<T, Error>) -> Void) {
        ensureTokenValid { result in
            switch result {
            case .success:
                performRequestPut(path: path, parameters: parameters, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    // 确保 token 有效（单飞刷新由 TokenRefreshCoordinator 负责）
    static func ensureTokenValid(completion: @escaping (Result<Void, Error>) -> Void) {
        let repository = AuthEnvironment.shared.sessionRepository
        guard repository.hasSession() else {
            completion(.success(()))
            return
        }

        guard repository.isAccessTokenExpiring(within: 300) else {
            completion(.success(()))
            return
        }

        SafeLog.log("access_token 即将过期，开始刷新")
        AuthEnvironment.shared.refreshCoordinator.refresh { result in
            switch result {
            case .success:
                completion(.success(()))
            case let .failure(error):
                // 会话失效由 TokenRefreshCoordinator 统一发布 sessionExpired 事件
                SafeLog.log("access_token 刷新失败:", error.logCategory)
                completion(.failure(error))
            }
        }
    }
    
    // 实际执行 POST 请求
    private static func performRequestPost<T: Codable>(path: String, parameters: Parameters, extraHeaders: HTTPHeaders? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        var headers = tspHeaders
        if let extraHeaders = extraHeaders {
            extraHeaders.forEach { headers[$0.name] = $0.value }
        }
        SafeLog.log("request post tsp:", path, SafeLog.redacted(parameters: parameters), SafeLog.redacted(headers: headers))
        NetworkManager.shared.requestPost(path: AppGlobalState.shared.tspUrl + path, parameters: parameters, headers: headers) { result in
            switch result {
            case let .success(data):
                let parseResult: Result<T, Error> = parseData(data)
                completion(parseResult)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    // 实际执行 GET 请求
    private static func performRequestGet<T: Codable>(path: String, parameters: Parameters, completion: @escaping (Result<T, Error>) -> Void) {
        SafeLog.log("request get tsp:", path, SafeLog.redacted(parameters: parameters), SafeLog.redacted(headers: tspHeaders))
        NetworkManager.shared.requestGet(path: AppGlobalState.shared.tspUrl + path, parameters: parameters, headers: tspHeaders) { result in
            switch result {
            case let .success(data):
                let parseResult: Result<T, Error> = parseData(data)
                completion(parseResult)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    // 实际执行 PUT 请求
    private static func performRequestPut<T: Codable>(path: String, parameters: Parameters, completion: @escaping (Result<T, Error>) -> Void) {
        SafeLog.log("request put tsp:", path, SafeLog.redacted(parameters: parameters), SafeLog.redacted(headers: tspHeaders))
        NetworkManager.shared.requestPut(path: AppGlobalState.shared.tspUrl + path, parameters: parameters, headers: tspHeaders) { result in
            switch result {
            case let .success(data):
                let parseResult: Result<T, Error> = parseData(data)
                completion(parseResult)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    // json -> model
    static func parseData<T: Decodable>(_ data: Data) -> Result<T, Error> {
        let decoder = makeDecoder()

        let dataStr = String(data: data, encoding: .utf8) ?? "<unreadable response>"
        SafeLog.log("response tsp:", SafeLog.redacted(responseBody: dataStr))

        if let rawResponse = try? decoder.decode(TspResponse<AnyCodable>.self, from: data),
           rawResponse.code == AuthServerCode.sessionExpired {
            DispatchQueue.main.async {
                AuthEnvironment.shared.handleSessionExpired()
            }
        }
        
        do {
            return .success(try decoder.decode(T.self, from: data))
        } catch {
            // 外层结构解码失败也要能看到原因，避免又变成“请求异常”而无迹可循
            SafeLog.log("❌ 响应解码失败:", String(describing: error))
            let error = NSError(domain: "NetworkAPIError", code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Can not parse data"])
            return .failure(error)
        }
    }
    
    /// 统一响应解码器
    ///
    /// 日期策略需要兼容后端实际返回格式：
    /// - ISO-8601 字符串，如 `2026-11-12T07:24:49.000+00:00`（带毫秒，带时区偏移）
    /// - 毫秒 / 秒时间戳
    /// - Foundation 默认的“2001 基准秒”（保持与原 `.deferredToDate` 行为兼容）
    ///
    /// 背景：`JSONDecoder` 默认 `.deferredToDate` 只认 Double，遇到字符串会直接解码失败；
    /// 而 `TspResponse.data` 使用 `try?` 静默处理错误，最终表现为「HTTP 200 但提示请求异常」。
    static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            
            if let text = try? container.decode(String.self) {
                if let date = parseDate(from: text) {
                    return date
                }
                throw DecodingError.dataCorruptedError(in: container,
                                                       debugDescription: "无法解析的日期字符串: \(text)")
            }
            
            let value = try container.decode(Double.self)
            if value >= 1_000_000_000_000 {
                return Date(timeIntervalSince1970: value / 1000)   // 毫秒时间戳
            }
            if value >= 1_000_000_000 {
                return Date(timeIntervalSince1970: value)          // 秒时间戳
            }
            return Date(timeIntervalSinceReferenceDate: value)     // Foundation 默认行为
        }
        return decoder
    }
    
    /// 解析字符串日期（ISO-8601 / 常见日期格式），供自定义日期策略与 `FlexibleTimestamp` 复用
    static func parseDate(from text: String) -> Date? {
        // ISO8601DateFormatter / DateFormatter 非线程安全，这里按需创建（日期字段很少，开销可忽略）
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = fractional.date(from: text) { return date }
        
        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]
        if let date = plain.date(from: text) { return date }
        
        for format in ["yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd'T'HH:mm:ss", "yyyy/MM/dd HH:mm:ss"] {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(identifier: "UTC")
            formatter.dateFormat = format
            if let date = formatter.date(from: text) { return date }
        }
        return nil
    }
    
    // model -> dic
    static func model2Dic<T: Encodable>(_ model: T) -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(model) else {
            return nil
        }
        guard let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any] else {
            return nil
        }
        return dict
    }

}
